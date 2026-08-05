vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config.options")
require("config.ui").apply_options()

if not require("config.bootstrap").ensure_lazy() then
    return
end

require("lazy").setup("config.plugins", {
    checker = { enabled = true, notify = false },
})

require("config.autocmds")
-- Управление раскладкой привязано к режимам Neovim, поэтому подключается после базовых autocmd.
require("config.input_method").setup()
require("config.keymaps")
