vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config.options")
require("config.ui").apply_options()

if not require("config.bootstrap").ensure_lazy() then
    return
end

require("lazy").setup("config.plugins", {
    -- Фоновая проверка обновлений создаёт лишние сетевые запросы при работе от батареи.
    -- При необходимости её можно включить: NVIM_PLUGIN_CHECK=1 nvim
    checker = { enabled = vim.env.NVIM_PLUGIN_CHECK == "1", notify = false },
    rocks = { enabled = false },
})

require("config.autocmds")
-- Управление раскладкой привязано к режимам Neovim, поэтому подключается после базовых autocmd.
require("config.input_method").setup()
require("config.keymaps")
