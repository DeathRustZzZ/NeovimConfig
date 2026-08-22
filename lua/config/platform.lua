local M = {}

M.is_macos = vim.fn.has("macunix") == 1
M.is_linux = vim.fn.has("linux") == 1

local path_separator = package.config:sub(1, 1) == "\\" and ";" or ":"

function M.prepend_to_path(path)
    if vim.fn.isdirectory(path) ~= 1 then
        return
    end

    local entries = vim.split(vim.env.PATH or "", path_separator, { plain = true, trimempty = true })
    if not vim.list_contains(entries, path) then
        vim.env.PATH = path .. path_separator .. (vim.env.PATH or "")
    end
end

function M.setup_path()
    -- GUI-клиенты macOS не всегда наследуют PATH интерактивного shell.
    if M.is_macos then
        M.prepend_to_path("/opt/homebrew/bin")
        M.prepend_to_path("/opt/homebrew/sbin")
        M.prepend_to_path("/usr/local/bin") -- Homebrew на Intel Mac и пользовательские CLI.
    end

    -- Mason остаётся lazy-loaded, но его CLI нужны Treesitter/LSP сразу.
    M.prepend_to_path(vim.fn.stdpath("data") .. "/mason/bin")
end

function M.open_url(url)
    if vim.ui and vim.ui.open then
        local ok = pcall(vim.ui.open, url)
        if ok then
            return true
        end
    end

    local opener = M.is_macos and "open" or "xdg-open"
    if vim.fn.executable(opener) ~= 1 then
        vim.notify("Не найдена команда для открытия URL: " .. opener, vim.log.levels.WARN)
        return false
    end

    return vim.fn.jobstart({ opener, url }, { detach = true }) > 0
end

return M
