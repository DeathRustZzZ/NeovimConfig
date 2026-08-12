local M = {}

local function trim(text)
    return (text or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

function M.is_available()
    return vim.fn.executable("trans") == 1
end

function M.notify_missing()
    vim.notify("Команда `trans` не найдена. Установите translate-shell.", vim.log.levels.WARN)
end

function M.translate(source_text, opts)
    opts = opts or {}

    local text = trim(source_text)
    if text == "" then
        if opts.empty_message then
            vim.notify(opts.empty_message, vim.log.levels.WARN)
        end
        return false
    end

    if not M.is_available() then
        M.notify_missing()
        return false
    end

    local target = opts.target or "ru"
    local on_success = opts.on_success
    local on_error = opts.on_error

    local ok = pcall(vim.system, { "trans", "-brief", ":" .. target, "--", text }, { text = true }, function(result)
        vim.schedule(function()
            local translated = trim(result.stdout)
            if result.code == 0 and translated ~= "" then
                if type(on_success) == "function" then
                    on_success(translated, text)
                end
                return
            end

            local err = trim(result.stderr)
            if err == "" then
                err = result.code == 0 and "переводчик вернул пустой результат"
                    or ("процесс завершился с кодом " .. tostring(result.code))
            end
            if type(on_error) == "function" then
                on_error(err)
            else
                vim.notify("trans error: " .. err, vim.log.levels.ERROR)
            end
        end)
    end)

    if not ok then
        vim.notify("Не удалось запустить команду `trans`.", vim.log.levels.ERROR)
        return false
    end

    return true
end

function M.translate_and_notify(source_text, empty_message)
    return M.translate(source_text, {
        empty_message = empty_message,
        on_success = function(translated, original)
            vim.notify(original .. " -> " .. translated, vim.log.levels.INFO)
        end,
    })
end

return M
