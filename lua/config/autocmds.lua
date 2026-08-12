local ui = require("config.ui")

local ui_highlight_group = vim.api.nvim_create_augroup("UserUiHighlights", { clear = true })
vim.api.nvim_create_autocmd("ColorScheme", {
    group = ui_highlight_group,
    callback = ui.apply_highlights,
})

local swap_guard_group = vim.api.nvim_create_augroup("UserSwapGuard", { clear = true })
vim.api.nvim_create_autocmd("SwapExists", {
    group = swap_guard_group,
    callback = function()
        local swap_path = vim.v.swapname ~= "" and vim.v.swapname or "[unknown swap]"
        -- Keep SwapExists side effects minimal; interactive prompts here can break :edit callers (e.g. neo-tree).
        vim.v.swapchoice = "o"
        vim.schedule(function()
            vim.notify(
                "Найден swap: " .. swap_path .. ". Файл открыт только для чтения (можно :recover при необходимости).",
                vim.log.levels.WARN
            )
        end)
    end,
})

local maintenance_group = vim.api.nvim_create_augroup("UserMaintenanceChecks", { clear = true })
vim.api.nvim_create_autocmd("VimEnter", {
    group = maintenance_group,
    once = true,
    callback = function()
        local stamp = vim.fn.stdpath("state") .. "/maintenance_check.timestamp"
        local week_seconds = 7 * 24 * 60 * 60
        local now = os.time()

        local last = 0
        local file = io.open(stamp, "r")
        if file then
            local content = file:read("*a")
            file:close()
            last = tonumber(content) or 0
        end

        if now - last < week_seconds then
            return
        end

        local write_file = io.open(stamp, "w")
        if write_file then
            write_file:write(tostring(now))
            write_file:close()
        end

        pcall(vim.cmd, "silent! Lazy check")
        vim.schedule(function()
            vim.notify("Плановая проверка: выполнен Lazy check. Запустите :checkhealth для полной диагностики.",
                vim.log.levels.INFO)
        end)
    end,
})

local git_group = vim.api.nvim_create_augroup("UserGitEditing", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
    group = git_group,
    pattern = "gitcommit",
    callback = function()
        vim.opt_local.spell = true
        vim.opt_local.wrap = true
        vim.opt_local.linebreak = true
        vim.opt_local.textwidth = 72
        vim.opt_local.colorcolumn = "73"
    end,
})

ui.apply_highlights()
