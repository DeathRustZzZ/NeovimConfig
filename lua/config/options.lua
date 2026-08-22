vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true
vim.opt.mouse = "a"
vim.opt.updatetime = 400
vim.opt.timeoutlen = 400
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.scrolloff = 6
vim.opt.wrap = false
vim.opt.confirm = true
vim.opt.undofile = true
vim.opt.completeopt = { "menu", "menuone", "noselect" }

vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.smartindent = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

require("config.platform").setup_path()

if vim.fn.has("clipboard") == 1 then
    vim.opt.clipboard = "unnamedplus"
end

if vim.g.neovide or vim.fn.has("gui_running") == 1 then
    vim.opt.guifont = "JetBrainsMono Nerd Font:h12"
end
