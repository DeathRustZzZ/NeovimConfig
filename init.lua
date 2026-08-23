vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Конфиг не использует remote-plugin providers. Их автоопределение только замедляет
-- запуск и создаёт ложные checkhealth warnings на чистой машине.
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

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
