local function copy_whole_buffer_to_clipboard()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local text = table.concat(lines, "\n")
    vim.fn.setreg("+", text)
    vim.fn.setreg('"', text)
    vim.notify("Copied buffer to clipboard (+)", vim.log.levels.INFO)
end

local ui = require("config.ui")
local translator = require("config.translator")
local hover_translator = require("config.hover_translator")

local function map(mode, lhs, rhs, desc, opts)
    local base = { desc = desc, silent = true }
    vim.keymap.set(mode, lhs, rhs, opts and vim.tbl_extend("force", base, opts) or base)
end

local function smart_close()
    local wins = vim.api.nvim_tabpage_list_wins(0)
    if #wins > 1 then
        vim.cmd("close")
        return
    end

    local listed = vim.fn.getbufinfo({ buflisted = 1 })
    if #listed > 1 then
        vim.cmd("bdelete")
        return
    end

    local cur = vim.api.nvim_get_current_buf()
    vim.cmd("enew")
    pcall(vim.cmd, "bdelete " .. cur)
end

local function graphify(args)
    if vim.fn.executable("graphify") ~= 1 then
        vim.notify("Команда `graphify` не найдена. Установите пакет graphifyy.", vim.log.levels.WARN)
        return
    end

    local target = args and args ~= "" and args or "."
    vim.cmd("botright split")
    vim.cmd("resize 15")
    vim.cmd("enew")
    local job_id = vim.fn.jobstart({ "graphify", target }, {
        cwd = vim.fn.getcwd(),
        term = true,
    })
    if job_id <= 0 then
        vim.notify("Не удалось запустить `graphify`.", vim.log.levels.ERROR)
        return
    end
    vim.cmd("startinsert")
end

vim.api.nvim_create_user_command("Graphify", function(opts)
    graphify(opts.args)
end, {
    nargs = "?",
    complete = "dir",
    desc = "Построить Graphify knowledge graph для директории",
})

map("n", "<leader>w", "<cmd>w<cr>", "Сохранить файл")
map("n", "<M-s>", "<cmd>w<cr>", "Сохранить файл (Cmd+S)")
map("i", "<M-s>", "<C-o>:w<cr>", "Сохранить файл (Cmd+S)")
map("v", "<M-s>", "<Esc><cmd>w<cr>", "Сохранить файл (Cmd+S)")
map("n", "<C-s>", "<cmd>w<cr>", "Сохранить файл (Ctrl+S)")
map("i", "<C-s>", "<C-o>:w<cr>", "Сохранить файл (Ctrl+S)")
map("v", "<C-s>", "<Esc><cmd>w<cr>", "Сохранить файл (Ctrl+S)")
map("n", "<leader>q", smart_close, "Закрыть окно/буфер (без выхода из Neovim)")
map("n", "<leader>Q", "<cmd>qa<cr>", "Выйти из Neovim")
map("n", "<leader>cl", copy_whole_buffer_to_clipboard, "Скопировать весь буфер в буфер обмена")
map("n", "<leader>ag", function() graphify(".") end, "AI: Graphify текущий проект")

map("i", "jk", "<Esc>", "Выйти из режима вставки")

map("n", "<leader>dn", function()
    vim.diagnostic.jump({ count = 1, float = true })
end, "Следующая диагностика")
map("n", "<leader>dp", function()
    vim.diagnostic.jump({ count = -1, float = true })
end, "Предыдущая диагностика")
map("n", "<leader>dd", vim.diagnostic.open_float, "Диагностика строки")
map("n", "<leader>lt", hover_translator.translate, "LSP: перевести hover")

map("n", "<leader>tr", function()
    local word = vim.fn.expand("<cword>")
    translator.translate_and_notify(word or "", "Нет слова под курсором")
end, "Перевести слово на русский")

map("n", "<leader>tl", function()
    translator.translate_and_notify(vim.api.nvim_get_current_line(), "Строка пустая")
end, "Перевести строку на русский")

map("n", "<leader>ut", ui.cycle_preset, "Переключить UI-пресет")
map("n", "<leader>u1", function() ui.set_preset("glass") end, "UI-пресет: glass")
map("n", "<leader>u2", function() ui.set_preset("solid") end, "UI-пресет: solid")
map("n", "<leader>u3", function() ui.set_preset("high_contrast") end, "UI-пресет: high contrast")

map("n", "<C-h>", "<C-w>h", "Окно слева")
map("n", "<C-j>", "<C-w>j", "Окно снизу")
map("n", "<C-k>", "<C-w>k", "Окно сверху")
map("n", "<C-l>", "<C-w>l", "Окно справа")
map("n", "<M-h>", "<C-w>h", "Окно слева (Cmd+H)")
map("n", "<M-j>", "<C-w>j", "Окно снизу (Cmd+J)")
map("n", "<M-k>", "<C-w>k", "Окно сверху (Cmd+K)")
map("n", "<M-l>", "<C-w>l", "Окно справа (Cmd+L)")

map("t", "<C-h>", [[<C-\><C-n><C-w>h]], "Из терминала в окно слева")
map("t", "<C-j>", [[<C-\><C-n><C-w>j]], "Из терминала в окно снизу")
map("t", "<C-k>", [[<C-\><C-n><C-w>k]], "Из терминала в окно сверху")
map("t", "<C-l>", [[<C-\><C-n><C-w>l]], "Из терминала в окно справа")
map("t", "<M-h>", [[<C-\><C-n><C-w>h]], "Из терминала в окно слева (Cmd+H)")
map("t", "<M-j>", [[<C-\><C-n><C-w>j]], "Из терминала в окно снизу (Cmd+J)")
map("t", "<M-k>", [[<C-\><C-n><C-w>k]], "Из терминала в окно сверху (Cmd+K)")
map("t", "<M-l>", [[<C-\><C-n><C-w>l]], "Из терминала в окно справа (Cmd+L)")
