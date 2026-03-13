local M = {}

function M.ensure_lazy()
    local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
    local uv = vim.uv or vim.loop

    if not uv.fs_stat(lazypath) then
        if vim.fn.executable("git") ~= 1 then
            vim.api.nvim_echo({
                { "lazy.nvim не найден, а git недоступен.\n", "ErrorMsg" },
                { "Установите git и перезапустите Neovim.\n", "Normal" },
            }, true, {})
            return false
        end

        local out = vim.fn.system({
            "git",
            "clone",
            "--filter=blob:none",
            "https://github.com/folke/lazy.nvim.git",
            "--branch=stable",
            lazypath,
        })

        if vim.v.shell_error ~= 0 then
            vim.api.nvim_echo({
                { "Не удалось установить lazy.nvim:\n", "ErrorMsg" },
                { out .. "\n", "Normal" },
            }, true, {})
            return false
        end
    end

    vim.opt.rtp:prepend(lazypath)
    return true
end

return M
