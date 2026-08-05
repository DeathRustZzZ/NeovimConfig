local function copy_whole_buffer_to_clipboard()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local text = table.concat(lines, "\n")
    vim.fn.setreg("+", text)
    vim.fn.setreg('"', text)
    vim.notify("Copied buffer to clipboard (+)", vim.log.levels.INFO)
end

local ui = require("config.ui")

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

local function notify_missing_trans()
    vim.notify("Команда `trans` не найдена. Установите translate-shell.", vim.log.levels.WARN)
end

local function graphify(args)
    if vim.fn.executable("graphify") ~= 1 then
        vim.notify("Команда `graphify` не найдена. Установите пакет graphifyy.", vim.log.levels.WARN)
        return
    end

    local target = args and args ~= "" and args or "."
    vim.cmd("botright split")
    vim.cmd("resize 15")
    vim.fn.termopen({ "graphify", target }, {
        cwd = vim.fn.getcwd(),
    })
    vim.cmd("startinsert")
end

vim.api.nvim_create_user_command("Graphify", function(opts)
    graphify(opts.args)
end, {
    nargs = "?",
    complete = "dir",
    desc = "Построить Graphify knowledge graph для директории",
})

local function translate_and_notify(source_text, empty_message)
    local text = source_text:gsub("^%s+", ""):gsub("%s+$", "")
    if text == "" then
        vim.notify(empty_message, vim.log.levels.WARN)
        return
    end

    if vim.fn.executable("trans") ~= 1 then
        notify_missing_trans()
        return
    end

    vim.fn.jobstart({ "trans", "-brief", ":ru", "--", text }, {
        stdout_buffered = true,
        stderr_buffered = true,
        on_stdout = function(_, data)
            local out = table.concat(data or {}, "\n"):gsub("%s+$", "")
            if out ~= "" then
                vim.notify(text .. " -> " .. out, vim.log.levels.INFO)
            end
        end,
        on_stderr = function(_, data)
            local err = table.concat(data or {}, "\n"):gsub("%s+$", "")
            if err ~= "" then
                vim.notify("trans error: " .. err, vim.log.levels.ERROR)
            end
        end,
    })
end

map("n", "<leader>w", "<cmd>w<cr>", "Сохранить файл")
map("n", "<C-s>", "<cmd>w<cr>", "Сохранить файл (Ctrl+S)")
map("i", "<C-s>", "<C-o>:w<cr>", "Сохранить файл (Ctrl+S)")
map("v", "<C-s>", "<Esc><cmd>w<cr>", "Сохранить файл (Ctrl+S)")
map("n", "<leader>q", smart_close, "Закрыть окно/буфер (без выхода из Neovim)")
map("n", "<leader>Q", "<cmd>qa<cr>", "Выйти из Neovim")
map("n", "<leader>cl", copy_whole_buffer_to_clipboard, "Скопировать весь буфер в буфер обмена")
map("n", "<leader>ag", function() graphify(".") end, "AI: Graphify текущий проект")

map("i", "jk", "<Esc>", "Выйти из режима вставки")

map("n", "<leader>dn", vim.diagnostic.goto_next, "Следующая диагностика")
map("n", "<leader>dp", vim.diagnostic.goto_prev, "Предыдущая диагностика")
map("n", "<leader>dd", vim.diagnostic.open_float, "Диагностика строки")

map("n", "<leader>tr", function()
    local word = vim.fn.expand("<cword>")
    translate_and_notify(word or "", "Нет слова под курсором")
end, "Перевести слово на русский")

map("n", "<leader>tl", function()
    translate_and_notify(vim.api.nvim_get_current_line(), "Строка пустая")
end, "Перевести строку на русский")

map("n", "<leader>ut", ui.cycle_preset, "Переключить UI-пресет")
map("n", "<leader>u1", function() ui.set_preset("glass") end, "UI-пресет: glass")
map("n", "<leader>u2", function() ui.set_preset("solid") end, "UI-пресет: solid")
map("n", "<leader>u3", function() ui.set_preset("high_contrast") end, "UI-пресет: high contrast")

map("n", "<C-h>", "<C-w>h", "Окно слева")
map("n", "<C-j>", "<C-w>j", "Окно снизу")
map("n", "<C-k>", "<C-w>k", "Окно сверху")
map("n", "<C-l>", "<C-w>l", "Окно справа")

map("t", "<C-h>", [[<C-\><C-n><C-w>h]], "Из терминала в окно слева")
map("t", "<C-j>", [[<C-\><C-n><C-w>j]], "Из терминала в окно снизу")
map("t", "<C-k>", [[<C-\><C-n><C-w>k]], "Из терминала в окно сверху")
map("t", "<C-l>", [[<C-\><C-n><C-w>l]], "Из терминала в окно справа")
