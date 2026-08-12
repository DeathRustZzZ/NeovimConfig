local translator = require("config.translator")

local M = {}

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
    for index = first, last do
        result[#result + 1] = lines[index]
    end
    return result
end

local function hover_client(bufnr)
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
        if client:supports_method("textDocument/hover", bufnr) then
            return client
        end
    end
end

local function show_translation(source_lines, translated)
    local translation_lines = trim_empty_lines(vim.split(translated, "\n", { plain = true }))
    if #translation_lines == 0 then
        vim.notify("Переводчик вернул пустой результат.", vim.log.levels.WARN)
        return
    end

    local contents = vim.deepcopy(source_lines)
    vim.list_extend(contents, { "", "---", "", "## Перевод", "" })
    vim.list_extend(contents, translation_lines)
    vim.lsp.util.open_floating_preview(contents, "markdown", {
        border = "rounded",
        focusable = true,
        max_height = math.floor((vim.o.lines - vim.o.cmdheight - 2) * 0.8),
        max_width = math.floor(vim.o.columns * 0.8),
    })
end

function M.translate()
    local bufnr = vim.api.nvim_get_current_buf()
    local client = hover_client(bufnr)
    if not client then
        vim.notify("Подключённый LSP сервер не поддерживает hover.", vim.log.levels.WARN)
        return
    end

    local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
    local requested = client:request("textDocument/hover", params, function(err, result)
        vim.schedule(function()
            if err then
                local message = type(err) == "table" and err.message or vim.inspect(err)
                vim.notify("Не удалось получить LSP hover: " .. tostring(message), vim.log.levels.ERROR)
                return
            end

            local source_lines = result and result.contents
                and vim.lsp.util.convert_input_to_markdown_lines(result.contents)
                or {}
            source_lines = trim_empty_lines(source_lines)
            if #source_lines == 0 then
                vim.notify("LSP hover не содержит текста для перевода.", vim.log.levels.WARN)
                return
            end

            translator.translate(table.concat(source_lines, "\n"), {
                on_success = function(translated)
                    show_translation(source_lines, translated)
                end,
            })
        end)
    end, bufnr)
    if not requested then
        vim.notify("LSP сервер отклонил запрос hover.", vim.log.levels.WARN)
    end
end

return M
