local translator = require("config.translator")

local M = {}

local translation_heading = "## Перевод"

local function is_valid_float(winid)
    if not winid or not vim.api.nvim_win_is_valid(winid) then
        return false
    end

    local ok, config = pcall(vim.api.nvim_win_get_config, winid)
    return ok and config.relative ~= ""
end

local function hover_from_noice()
    local ok, docs = pcall(require, "noice.lsp.docs")
    if not ok or not docs._messages then
        return nil
    end

    local message = docs._messages.hover
    if not message or type(message.win) ~= "function" then
        return nil
    end

    local ok_win, winid = pcall(message.win, message)
    if not ok_win or not is_valid_float(winid) then
        return nil
    end

    return {
        winid = winid,
        bufnr = vim.api.nvim_win_get_buf(winid),
    }
end

local function hover_from_lspsaga()
    local ok, hover = pcall(require, "lspsaga.hover")
    if not ok or not is_valid_float(hover.winid) then
        return nil
    end

    return {
        winid = hover.winid,
        bufnr = hover.bufnr or vim.api.nvim_win_get_buf(hover.winid),
    }
end

local function hover_from_standard_lsp()
    for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if is_valid_float(winid) then
            local ok = pcall(vim.api.nvim_win_get_var, winid, "textDocument/hover")
            if ok then
                return {
                    winid = winid,
                    bufnr = vim.api.nvim_win_get_buf(winid),
                }
            end
        end
    end

    for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if is_valid_float(winid) then
            local bufnr = vim.api.nvim_win_get_buf(winid)
            local filetype = vim.bo[bufnr].filetype
            local buftype = vim.bo[bufnr].buftype
            if buftype == "nofile" and (filetype == "markdown" or filetype == "noice") then
                return {
                    winid = winid,
                    bufnr = bufnr,
                }
            end
        end
    end

    return nil
end

local function find_hover()
    return hover_from_noice() or hover_from_lspsaga() or hover_from_standard_lsp()
end

local function trim_empty_lines(lines)
    local first = 1
    while first <= #lines and vim.trim(lines[first]) == "" do
        first = first + 1
    end

    local last = #lines
    while last >= first and vim.trim(lines[last]) == "" do
        last = last - 1
    end

    local result = {}
    for i = first, last do
        result[#result + 1] = lines[i]
    end
    return result
end

local function has_translation(lines)
    for _, line in ipairs(lines) do
        if vim.trim(line) == translation_heading then
            return true
        end
    end
    return false
end

local function original_lines(lines)
    local result = {}
    for _, line in ipairs(lines) do
        if vim.trim(line) == translation_heading then
            break
        end
        result[#result + 1] = line
    end
    return trim_empty_lines(result)
end

local function split_translation(text)
    return trim_empty_lines(vim.split(text, "\n", { plain = true }))
end

local function wrapped_height(lines, width)
    local height = 0
    width = math.max(width, 1)

    for _, line in ipairs(lines) do
        local line_width = vim.fn.strdisplaywidth(line:gsub("%z", "\n"))
        height = height + math.max(1, math.ceil(line_width / width))
    end

    return height
end

local function resize_hover(winid, bufnr)
    if not is_valid_float(winid) or not vim.api.nvim_buf_is_valid(bufnr) then
        return
    end

    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local current_height = vim.api.nvim_win_get_height(winid)
    local width = vim.api.nvim_win_get_width(winid)
    local max_height = math.max(current_height, math.floor((vim.o.lines - vim.o.cmdheight - 2) * 0.8))
    local next_height = math.min(max_height, math.max(current_height, wrapped_height(lines, width)))

    pcall(vim.api.nvim_win_set_config, winid, { height = next_height })
end

local function append_translation(target, translated)
    if not is_valid_float(target.winid) or not vim.api.nvim_buf_is_valid(target.bufnr) then
        vim.notify("Hover уже закрыт, перевод некуда вставить.", vim.log.levels.WARN)
        return
    end

    local translation_lines = split_translation(translated)
    if #translation_lines == 0 then
        vim.notify("Переводчик вернул пустой результат.", vim.log.levels.WARN)
        return
    end

    local block = { "", "---", "", translation_heading, "" }
    vim.list_extend(block, translation_lines)

    local was_modifiable = vim.bo[target.bufnr].modifiable
    vim.bo[target.bufnr].modifiable = true
    local ok, err = pcall(vim.api.nvim_buf_set_lines, target.bufnr, -1, -1, false, block)
    vim.bo[target.bufnr].modifiable = was_modifiable

    if not ok then
        vim.notify(
            "Не удалось вставить перевод в hover: " .. tostring(err),
            vim.log.levels.ERROR
        )
        return
    end

    resize_hover(target.winid, target.bufnr)
end

function M.translate()
    local target = find_hover()
    if not target or not is_valid_float(target.winid) or not vim.api.nvim_buf_is_valid(target.bufnr) then
        vim.notify(
            "Окно LSP hover не найдено. Сначала откройте hover через K или <leader>lh.",
            vim.log.levels.WARN
        )
        return
    end

    local lines = vim.api.nvim_buf_get_lines(target.bufnr, 0, -1, false)
    if has_translation(lines) then
        vim.notify("Перевод уже добавлен в текущий hover.", vim.log.levels.INFO)
        return
    end

    local source_lines = original_lines(lines)
    if #source_lines == 0 then
        vim.notify("В hover нет текста для перевода.", vim.log.levels.WARN)
        return
    end

    translator.translate(table.concat(source_lines, "\n"), {
        empty_message = "В hover нет текста для перевода.",
        on_success = function(translated)
            append_translation(target, translated)
        end,
    })
end

return M
