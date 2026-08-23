local M = {}

local config = {
    command = "trans",
    target = "ru",
    engine = nil,
    engines = { "bing", "google" },
    timeout_ms = 10000,
    cache_size = 100,
}

local active_requests = {}
local cache = {}
local cache_order = {}
local next_request_id = 0

local function trim(text)
    return (text or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function normalize_output(text)
    text = tostring(text or "")
        :gsub("\r\n", "\n")
        :gsub("\r", "\n")
        :gsub("\27%[[0-?]*[ -/]*[@-~]", "")
        :gsub("\\r\\n", "\n")
        :gsub("\\n", "\n")
        :gsub("%z", "")
    return trim(text)
end

local function normalize_error(result)
    if result.code == 124 then
        return "истекло время ожидания перевода"
    end

    local message = trim(result.stderr)
    if message == "" then
        message = result.code == 0 and "переводчик вернул пустой результат"
            or ("процесс завершился с кодом " .. tostring(result.code))
    end
    message = message:gsub("%s+", " ")
    if #message > 320 then
        message = message:sub(1, 317) .. "..."
    end
    return message
end

local function notify_error(message)
    vim.notify("trans: " .. message, vim.log.levels.ERROR)
end

local function cache_get(key)
    if config.cache_size <= 0 then
        return nil
    end
    return cache[key]
end

local function cache_put(key, value)
    if config.cache_size <= 0 then
        return
    end

    if cache[key] then
        for index, cached_key in ipairs(cache_order) do
            if cached_key == key then
                table.remove(cache_order, index)
                break
            end
        end
    end

    cache[key] = value
    cache_order[#cache_order + 1] = key
    while #cache_order > config.cache_size do
        cache[table.remove(cache_order, 1)] = nil
    end
end

local function valid_language(language)
    return type(language) == "string" and language:match("^[%a][%w_+%-]*$") ~= nil
end

local function build_command(opts)
    local command = {
        opts.command or config.command,
        "-brief",
        "-no-ansi",
        "-no-autocorrect",
    }

    local engine = opts.engine or config.engine
    if engine and engine ~= "" then
        vim.list_extend(command, { "-engine", engine })
    end
    if opts.source then
        vim.list_extend(command, { "-source", opts.source })
    end
    vim.list_extend(command, { "-target", opts.target or config.target })
    return command
end

local function report_error(message, callback)
    if type(callback) == "function" then
        callback(message)
    else
        notify_error(message)
    end
end

function M.setup(opts)
    config = vim.tbl_deep_extend("force", config, opts or {})
end

function M.is_available()
    return vim.fn.executable(config.command) == 1
end

function M.notify_missing()
    vim.notify("Команда `" .. config.command .. "` не найдена. Установите translate-shell.", vim.log.levels.WARN)
end

function M.cancel(request_key)
    local request = active_requests[request_key]
    if not request then
        return false
    end

    active_requests[request_key] = nil
    if request.job then
        pcall(request.job.kill, request.job, 15)
    end
    return true
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

    local target = opts.target or config.target
    if not valid_language(target) or (opts.source and not valid_language(opts.source)) then
        report_error("некорректный код языка", opts.on_error)
        return false
    end

    local request_key = opts.request_key
    if request_key then
        M.cancel(request_key)
    end

    next_request_id = next_request_id + 1
    local request_id = next_request_id

    local engines
    if opts.engine or config.engine then
        engines = { opts.engine or config.engine }
    else
        engines = opts.engines or config.engines or { "auto" }
    end
    for _, engine in ipairs(engines) do
        if type(engine) ~= "string" or engine == "" then
            report_error("некорректный движок перевода", opts.on_error)
            return false
        end
    end

    local cache_key = table.concat({
        config.command,
        table.concat(engines, ","),
        opts.source or "auto",
        target,
        text,
    }, "\0")
    local cached = not opts.no_cache and cache_get(cache_key) or nil
    if cached then
        if request_key then
            active_requests[request_key] = { id = request_id }
        end
        vim.schedule(function()
            if request_key then
                local active = active_requests[request_key]
                if not active or active.id ~= request_id then
                    return
                end
                active_requests[request_key] = nil
            end
            if type(opts.on_success) == "function" then
                opts.on_success(cached, text)
            end
        end)
        return true
    end

    local request = { id = request_id }
    if request_key then
        active_requests[request_key] = request
    end

    local function is_current()
        if not request_key then
            return true
        end
        local active = active_requests[request_key]
        return active ~= nil and active.id == request_id
    end

    local function finish()
        if request_key and is_current() then
            active_requests[request_key] = nil
        end
    end

    local last_error
    local function attempt(index)
        if not is_current() then
            return nil
        end

        local command_opts = vim.tbl_extend("force", opts, {
            target = target,
            engine = engines[index],
        })
        local ok, job_or_error = pcall(vim.system, build_command(command_opts), {
            text = true,
            stdin = text,
            timeout = opts.timeout_ms or config.timeout_ms,
        }, function(result)
            vim.schedule(function()
                if not is_current() then
                    return
                end

                local translated = normalize_output(result.stdout)
                if result.code == 0 and translated ~= "" then
                    finish()
                    if not opts.no_cache then
                        cache_put(cache_key, translated)
                    end
                    if type(opts.on_success) == "function" then
                        opts.on_success(translated, text)
                    end
                    return
                end

                last_error = engines[index] .. ": " .. normalize_error(result)
                if index < #engines then
                    attempt(index + 1)
                    return
                end

                finish()
                report_error(last_error, opts.on_error)
            end)
        end)

        if not ok then
            last_error = engines[index] .. ": не удалось запустить переводчик: " .. tostring(job_or_error)
            if index < #engines then
                return attempt(index + 1)
            end
            finish()
            report_error(last_error, opts.on_error)
            return nil
        end

        request.job = job_or_error
        return job_or_error
    end

    return attempt(1) or false
end

function M.translate_and_notify(source_text, empty_message)
    return M.translate(source_text, {
        empty_message = empty_message,
        request_key = "word",
        on_success = function(translated, original)
            vim.notify(original .. " → " .. translated, vim.log.levels.INFO)
        end,
    })
end

return M
