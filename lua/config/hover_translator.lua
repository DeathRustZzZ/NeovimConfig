local translator = require("config.translator")
local translation_view = require("config.translation_view")

local M = {}

local generation = 0
local active_lsp_requests = {}

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

local function hover_clients(bufnr)
    local clients = {}
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
        if client:supports_method("textDocument/hover", bufnr) then
            clients[#clients + 1] = client
        end
    end
    return clients
end

local function cancel_lsp_requests()
    for _, request in ipairs(active_lsp_requests) do
        pcall(request.client.cancel_request, request.client, request.id)
    end
    active_lsp_requests = {}
end

local function capture_context()
    local winid = vim.api.nvim_get_current_win()
    local bufnr = vim.api.nvim_get_current_buf()
    return {
        winid = winid,
        bufnr = bufnr,
        cursor = vim.api.nvim_win_get_cursor(winid),
        changedtick = vim.api.nvim_buf_get_changedtick(bufnr),
    }
end

local function context_is_current(context)
    return vim.api.nvim_win_is_valid(context.winid)
        and vim.api.nvim_buf_is_valid(context.bufnr)
        and vim.api.nvim_get_current_win() == context.winid
        and vim.api.nvim_win_get_buf(context.winid) == context.bufnr
        and vim.api.nvim_buf_get_changedtick(context.bufnr) == context.changedtick
        and vim.deep_equal(vim.api.nvim_win_get_cursor(context.winid), context.cursor)
end

local function markdown_prose(lines)
    local prose = {}
    local in_code_block = false

    for _, original_line in ipairs(lines) do
        local line = original_line
        local trimmed = vim.trim(line)
        if trimmed:match("^```") or trimmed:match("^~~~") then
            in_code_block = not in_code_block
        elseif not in_code_block then
            line = line:gsub("!%[[^%]]*%]%([^%)]+%)", "")
            line = line:gsub("%[([^%]]+)%]%([^%)]+%)", "%1")
            line = line:gsub("`[^`]+`", "")
            line = line:gsub("^%s*#+%s*", "")
            line = line:gsub("^%s*>%s?", "")
            line = line:gsub("^%s*[%-%*+]%s+", "")
            line = vim.trim(line)

            if line ~= "" and not line:match("^[-=_]+$") then
                prose[#prose + 1] = line
            end
        end
    end

    return table.concat(prose, "\n")
end

local function error_message(err)
    local message = type(err) == "table" and err.message or vim.inspect(err)
    return tostring(message or "неизвестная ошибка")
end

function M.translate()
    generation = generation + 1
    local current_generation = generation
    cancel_lsp_requests()
    translator.cancel("hover")

    local context = capture_context()
    local clients = hover_clients(context.bufnr)
    if #clients == 0 then
        vim.notify("Подключённый LSP сервер не поддерживает hover.", vim.log.levels.WARN)
        return
    end

    local pending = #clients
    local responses = {}
    local errors = {}
    local finished = false

    local function finish()
        if finished or pending > 0 or current_generation ~= generation then
            return
        end
        finished = true
        active_lsp_requests = {}

        if not context_is_current(context) then
            vim.notify("Перевод hover отменён: позиция курсора изменилась.", vim.log.levels.INFO)
            return
        end

        local source_lines = {}
        local prose_parts = {}
        local response_count = 0
        for index = 1, #clients do
            local response = responses[index]
            if response then
                response_count = response_count + 1
                if #clients > 1 then
                    vim.list_extend(source_lines, { "## " .. clients[index].name, "" })
                end
                vim.list_extend(source_lines, response)
                vim.list_extend(source_lines, { "" })

                local prose = markdown_prose(response)
                if prose ~= "" then
                    prose_parts[#prose_parts + 1] = prose
                end
            end
        end
        source_lines = trim_empty_lines(source_lines)

        if response_count == 0 then
            local message = errors[1] and (": " .. errors[1]) or ""
            vim.notify("Не удалось получить LSP hover" .. message, vim.log.levels.WARN)
            return
        end

        local prose = table.concat(prose_parts, "\n\n")
        if prose == "" then
            vim.notify("В LSP hover нет обычного текста для перевода — только код.", vim.log.levels.INFO)
            return
        end

        translator.translate(prose, {
            request_key = "hover",
            on_success = function(translated)
                if current_generation ~= generation or not context_is_current(context) then
                    return
                end
                translation_view.open(source_lines, translated, {
                    title = " LSP перевод ",
                    original_first = true,
                    original_title = "LSP hover",
                })
            end,
        })
    end

    for index, client in ipairs(clients) do
        local params = vim.lsp.util.make_position_params(context.winid, client.offset_encoding)
        local requested, request_id = client:request("textDocument/hover", params, function(err, result)
            vim.schedule(function()
                if current_generation ~= generation then
                    return
                end

                if err then
                    errors[#errors + 1] = error_message(err)
                elseif result and result.contents then
                    local ok, lines = pcall(vim.lsp.util.convert_input_to_markdown_lines, result.contents)
                    if ok then
                        lines = trim_empty_lines(lines)
                        if #lines > 0 then
                            responses[index] = lines
                        end
                    else
                        errors[#errors + 1] = tostring(lines)
                    end
                end

                pending = pending - 1
                finish()
            end)
        end, context.bufnr)

        if requested and request_id then
            active_lsp_requests[#active_lsp_requests + 1] = {
                client = client,
                id = request_id,
            }
        else
            pending = pending - 1
        end
    end

    finish()
end

return M
