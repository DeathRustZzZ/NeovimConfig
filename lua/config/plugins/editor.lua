local function diffview_open_upstream()
    local upstream = vim.fn.systemlist({ "git", "rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{upstream}" })[1]
    if vim.v.shell_error ~= 0 or upstream == nil or upstream == "" then
        vim.notify("Git: у текущей ветки не настроен upstream.", vim.log.levels.WARN)
        return
    end

    vim.cmd("DiffviewOpen " .. upstream .. "...HEAD")
end

return {
    -- --------------------------------------------------------
    -- Treesitter: умная подсветка/отступы
    -- + textobjects: удобные движения/объекты по функциям/блокам
    -- --------------------------------------------------------
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        lazy = false,
        config = function()
            local languages = {
                "rust",
                "toml",
                "lua",
                "vim",
                "vimdoc",
                "query",
                "json",
                "yaml",
                "markdown",
                "go",
                "gomod",
                "gosum",
                "gowork",
                "bash",
                "javascript",
                "typescript",
            }

            require("nvim-treesitter").setup({
                install_dir = vim.fn.stdpath("data") .. "/site",
            })

            vim.api.nvim_create_autocmd("FileType", {
                group = vim.api.nvim_create_augroup("UserTreesitterStart", { clear = true }),
                pattern = languages,
                callback = function()
                    pcall(vim.treesitter.start)
                    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end,
            })
        end,
    },
    {
        "HiPhish/rainbow-delimiters.nvim",
        init = function()
            local ok, rainbow_delimiters = pcall(require, "rainbow-delimiters")
            if not ok then return end

            vim.g.rainbow_delimiters = {
                strategy = {
                    [""] = rainbow_delimiters.strategy["global"],
                    vim = rainbow_delimiters.strategy["local"],
                },
                query = {
                    [""] = "rainbow-delimiters",
                    lua = "rainbow-blocks",
                },
                highlight = {
                    "RainbowDelimiterRed",
                    "RainbowDelimiterYellow",
                    "RainbowDelimiterBlue",
                    "RainbowDelimiterOrange",
                    "RainbowDelimiterGreen",
                    "RainbowDelimiterViolet",
                    "RainbowDelimiterCyan",
                },
            }
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            require("nvim-treesitter-textobjects").setup({
                select = {
                    lookahead = true,
                },
                move = {
                    set_jumps = true,
                },
            })

            vim.keymap.set({ "x", "o" }, "af", function()
                require("nvim-treesitter-textobjects.select").select_textobject("@function.outer", "textobjects")
            end, { desc = "Treesitter: выбрать функцию" })
            vim.keymap.set({ "x", "o" }, "if", function()
                require("nvim-treesitter-textobjects.select").select_textobject("@function.inner", "textobjects")
            end, { desc = "Treesitter: внутри функции" })
            vim.keymap.set({ "x", "o" }, "ac", function()
                require("nvim-treesitter-textobjects.select").select_textobject("@class.outer", "textobjects")
            end, { desc = "Treesitter: выбрать класс/тип" })
            vim.keymap.set({ "x", "o" }, "ic", function()
                require("nvim-treesitter-textobjects.select").select_textobject("@class.inner", "textobjects")
            end, { desc = "Treesitter: внутри класса/типа" })
            vim.keymap.set({ "n", "x", "o" }, "]m", function()
                require("nvim-treesitter-textobjects.move").goto_next_start("@function.outer", "textobjects")
            end, { desc = "Treesitter: следующая функция" })
            vim.keymap.set({ "n", "x", "o" }, "[m", function()
                require("nvim-treesitter-textobjects.move").goto_previous_start("@function.outer", "textobjects")
            end, { desc = "Treesitter: предыдущая функция" })
        end,
    },

    -- --------------------------------------------------------
    -- Treesitter context: закрепляет текущую функцию/блок сверху
    -- Hotkeys: <leader>uc
    -- --------------------------------------------------------
    {
        "nvim-treesitter/nvim-treesitter-context",
        event = { "BufReadPost", "BufNewFile" },
        keys = {
            { "<leader>uc", "<cmd>TSContextToggle<cr>", desc = "Вкл/выкл контекст treesitter" },
        },
        opts = {
            max_lines = 5,
            multiline_threshold = 8,
            mode = "cursor",
            separator = "─",
            zindex = 19,
        },
    },

    -- --------------------------------------------------------
    -- Indent guides: линии отступов (ibl)
    -- Hotkeys/commands: :IBLToggle
    -- --------------------------------------------------------
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        event = { "BufReadPost", "BufNewFile" },
        opts = {
            indent = {
                char = "▏",
                highlight = "IblIndent",
            },
            scope = {
                enabled = true,
                show_start = false,
                show_end = false,
                highlight = "IblScope",
            },
        },
    },

    -- --------------------------------------------------------
    -- Illuminate: подсветка всех вхождений символа под курсором
    -- Hotkeys: <leader>un/<leader>up
    -- --------------------------------------------------------
    {
        "RRethy/vim-illuminate",
        event = { "BufReadPost", "BufNewFile" },
        keys = {
            {
                "<leader>un",
                function() require("illuminate").goto_next_reference(false) end,
                desc = "Следующее упоминание символа",
            },
            {
                "<leader>up",
                function() require("illuminate").goto_prev_reference(false) end,
                desc = "Предыдущее упоминание символа",
            },
        },
        config = function()
            require("illuminate").configure({
                delay = 180,
                large_file_cutoff = 3000,
            })
        end,
    },

    -- --------------------------------------------------------
    -- Flash: быстрые прыжки по экрану (быстрее, чем easymotion/leap)
    -- Hotkeys: <leader>jj/<leader>jt
    -- --------------------------------------------------------
    {
        "folke/flash.nvim",
        event = "VeryLazy",
        keys = {
            {
                "<leader>jj",
                function() require("flash").jump() end,
                desc = "Быстрый прыжок",
            },
            {
                "<leader>jt",
                function() require("flash").treesitter() end,
                desc = "Прыжок по treesitter",
            },
        },
        opts = {},
    },

    -- --------------------------------------------------------
    -- Git: изменения в файле (hunks), blame, stage/undo
    -- --------------------------------------------------------
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPost", "BufNewFile" },
        keys = {
            { "]h", function() require("gitsigns").nav_hunk("next") end, desc = "Git: следующий hunk" },
            { "[h", function() require("gitsigns").nav_hunk("prev") end, desc = "Git: предыдущий hunk" },
            { "<leader>ghs", function() require("gitsigns").stage_hunk() end, desc = "Git: stage hunk" },
            { "<leader>ghr", function() require("gitsigns").reset_hunk() end, desc = "Git: reset hunk" },
            { "<leader>ghS", function() require("gitsigns").stage_buffer() end, desc = "Git: stage buffer" },
            { "<leader>ghR", function() require("gitsigns").reset_buffer() end, desc = "Git: reset buffer" },
            { "<leader>ghu", function() require("gitsigns").undo_stage_hunk() end, desc = "Git: undo stage hunk" },
            { "<leader>ghp", function() require("gitsigns").preview_hunk() end, desc = "Git: preview hunk" },
            { "<leader>ghb", function() require("gitsigns").blame_line({ full = true }) end, desc = "Git: blame line" },
            { "<leader>ghB", function() require("gitsigns").toggle_current_line_blame() end, desc = "Git: toggle line blame" },
            { "<leader>ghd", function() require("gitsigns").diffthis() end, desc = "Git: diff this" },
            { "<leader>ghD", function() require("gitsigns").diffthis("~") end, desc = "Git: diff this ~" },
            { "<leader>ghq", function() require("gitsigns").setqflist("all") end, desc = "Git: hunks в quickfix" },
            {
                "<leader>ghs",
                function() require("gitsigns").stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end,
                mode = "x",
                desc = "Git: stage selected hunks",
            },
            {
                "<leader>ghr",
                function() require("gitsigns").reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end,
                mode = "x",
                desc = "Git: reset selected hunks",
            },
        },
        config = function()
            require("gitsigns").setup({
                signs = {
                    add = { text = "▌" },
                    change = { text = "▌" },
                    delete = { text = "▸" },
                    topdelete = { text = "▾" },
                    changedelete = { text = "▌" },
                    untracked = { text = "▌" },
                },
                signs_staged = {
                    add = { text = "│" },
                    change = { text = "│" },
                    delete = { text = "▸" },
                    topdelete = { text = "▾" },
                    changedelete = { text = "│" },
                    untracked = { text = "│" },
                },
                current_line_blame = false,
                current_line_blame_opts = {
                    delay = 500,
                    virt_text_pos = "eol",
                },
                preview_config = {
                    border = "rounded",
                    style = "minimal",
                    relative = "cursor",
                    row = 0,
                    col = 1,
                },
                attach_to_untracked = true,
            })
        end,
    },

    -- --------------------------------------------------------
    -- Diffview: удобный git diff/история в отдельном UI
    -- --------------------------------------------------------
    {
        "sindrets/diffview.nvim",
        cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
        keys = {
            { "<leader>gdw", "<cmd>DiffviewOpen<cr>", desc = "Git: diff workspace" },
            { "<leader>gds", "<cmd>DiffviewOpen --staged<cr>", desc = "Git: diff staged" },
            { "<leader>gdm", diffview_open_upstream, desc = "Git: diff branch upstream" },
            { "<leader>gdf", "<cmd>DiffviewFileHistory %<cr>", desc = "Git: история файла" },
            { "<leader>gdh", "<cmd>DiffviewFileHistory<cr>", desc = "Git: история проекта" },
            { "<leader>gD", "<cmd>DiffviewClose<cr>", desc = "Git: закрыть diff" },
        },
        opts = {
            enhanced_diff_hl = true,
            view = {
                default = { layout = "diff2_horizontal" },
                merge_tool = { layout = "diff3_horizontal" },
            },
        },
    },

    -- --------------------------------------------------------
    -- LazyGit integration: основной TUI для git внутри Neovim
    -- --------------------------------------------------------
    {
        "kdheepak/lazygit.nvim",
        cmd = {
            "LazyGit",
            "LazyGitConfig",
            "LazyGitCurrentFile",
            "LazyGitFilter",
            "LazyGitFilterCurrentFile",
        },
        dependencies = { "nvim-lua/plenary.nvim" },
        keys = {
            { "<leader>gg", "<cmd>LazyGit<cr>", desc = "Git: LazyGit" },
            { "<leader>gf", "<cmd>LazyGitCurrentFile<cr>", desc = "Git: LazyGit current file" },
        },
    },

    -- --------------------------------------------------------
    -- Git conflict helper: навигация и принятие ours/theirs/both
    -- --------------------------------------------------------
    {
        "akinsho/git-conflict.nvim",
        version = "*",
        event = "BufReadPost",
        keys = {
            { "<leader>gxo", "<cmd>GitConflictChooseOurs<cr>", desc = "Git conflict: выбрать ours" },
            { "<leader>gxt", "<cmd>GitConflictChooseTheirs<cr>", desc = "Git conflict: выбрать theirs" },
            { "<leader>gxb", "<cmd>GitConflictChooseBoth<cr>", desc = "Git conflict: выбрать оба" },
            { "<leader>gxn", "<cmd>GitConflictNextConflict<cr>", desc = "Git conflict: следующий" },
            { "<leader>gxp", "<cmd>GitConflictPrevConflict<cr>", desc = "Git conflict: предыдущий" },
        },
        opts = {
            default_mappings = false,
            disable_diagnostics = true,
        },
    },

    -- --------------------------------------------------------
    -- Git worktrees: параллельная работа с несколькими ветками
    -- Hotkeys: <leader>gw/<leader>gW
    -- --------------------------------------------------------
    {
        "polarmutex/git-worktree.nvim",
        version = "^2",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope.nvim",
        },
        keys = {
            {
                "<leader>gw",
                function() require("telescope").extensions.git_worktree.git_worktrees() end,
                desc = "Список worktree",
            },
            {
                "<leader>gW",
                function() require("telescope").extensions.git_worktree.create_git_worktree() end,
                desc = "Создать worktree",
            },
        },
        config = function()
            local hooks = require("git-worktree.hooks")
            local config = require("git-worktree.config")
            hooks.register(hooks.type.SWITCH, hooks.builtins.update_current_buffer_on_switch)
            hooks.register(hooks.type.DELETE, function()
                vim.cmd(config.update_on_change_command)
            end)
            require("telescope").load_extension("git_worktree")
        end,
    },

    -- --------------------------------------------------------
    -- GitHub PR/issues review inside Neovim
    -- Hotkeys: <leader>go/<leader>gr
    -- --------------------------------------------------------
    {
        "pwntester/octo.nvim",
        cmd = "Octo",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "nvim-telescope/telescope.nvim",
            "MunifTanjim/nui.nvim",
        },
        keys = {
            { "<leader>go", "<cmd>Octo<cr>", desc = "GitHub: панель Octo" },
            { "<leader>gr", "<cmd>Octo review start<cr>", desc = "GitHub: начать review" },
        },
        opts = {},
    },

    -- --------------------------------------------------------
    -- Surround: быстро оборачивать текст () [] "" '' и т.д.
    -- Примеры:
    --  ysiw"   — обернуть слово в кавычки
    --  ds"     — удалить кавычки
    --  cs"'    — заменить " на '
    -- --------------------------------------------------------
    {
        "kylechui/nvim-surround",
        event = "VeryLazy",
        config = function()
            require("nvim-surround").setup()
        end,
    },

    -- --------------------------------------------------------
    -- Автопары: скобки/кавычки автоматически
    -- + интеграция с nvim-cmp (подтверждаешь completion — ставится )
    -- --------------------------------------------------------
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function()
            local npairs = require("nvim-autopairs")
            npairs.setup()
        end,
    },

    -- --------------------------------------------------------
    -- TODO/FIXME подсветка и список
    -- --------------------------------------------------------
    {
        "folke/todo-comments.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            require("todo-comments").setup()
            vim.keymap.set("n", "<leader>td", "<cmd>TodoTelescope<cr>", { desc = "TODO/FIXME (Telescope)" })
        end,
    },

    -- --------------------------------------------------------
    -- Harpoon: быстрый список важных файлов/прыжки по ним
    -- Hotkeys: <leader>ha/<leader>hh/<leader>h1..h4
    -- --------------------------------------------------------
    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        dependencies = { "nvim-lua/plenary.nvim" },
        keys = {
            {
                "<leader>ha",
                function() require("harpoon"):list():append() end,
                desc = "Harpoon: добавить файл",
            },
            {
                "<leader>hh",
                function() require("harpoon").ui:toggle_quick_menu(require("harpoon"):list()) end,
                desc = "Harpoon: меню",
            },
            {
                "<leader>h1",
                function() require("harpoon"):list():select(1) end,
                desc = "Harpoon: файл 1",
            },
            {
                "<leader>h2",
                function() require("harpoon"):list():select(2) end,
                desc = "Harpoon: файл 2",
            },
            {
                "<leader>h3",
                function() require("harpoon"):list():select(3) end,
                desc = "Harpoon: файл 3",
            },
            {
                "<leader>h4",
                function() require("harpoon"):list():select(4) end,
                desc = "Harpoon: файл 4",
            },
        },
        config = function()
            require("harpoon"):setup()
        end,
    },

    -- --------------------------------------------------------
    -- Toggleterm: быстрый терминал внутри Neovim
    -- Hotkeys: <leader>tg/<leader>th
    -- --------------------------------------------------------
    {
        "akinsho/toggleterm.nvim",
        version = "*",
        cmd = { "ToggleTerm", "TermExec" },
        keys = {
            { "<leader>tg", "<cmd>ToggleTerm direction=float<cr>", desc = "Терминал (float)" },
            { "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "Терминал (горизонтальный)" },
        },
        opts = {
            open_mapping = nil,
            shade_terminals = true,
            direction = "float",
            float_opts = {
                border = "rounded",
            },
        },
    },

    -- --------------------------------------------------------
    -- AI: GitHub Copilot inline completion
    -- Требует Node.js >= 18 и авторизацию через :Copilot setup
    -- --------------------------------------------------------
    {
        "github/copilot.vim",
        event = "InsertEnter",
        init = function()
            vim.g.copilot_no_tab_map = true
            vim.g.copilot_enabled = true
        end,
        config = function()
            vim.keymap.set("i", "<C-g>", "<Plug>(copilot-suggest)", {
                silent = true,
                desc = "Copilot: показать подсказку (ручной запуск)",
            })
            vim.keymap.set("i", "<M-g>", "<Plug>(copilot-suggest)", {
                silent = true,
                desc = "Copilot: показать подсказку (Cmd+G)",
            })
            vim.keymap.set("i", "<C-l>", 'copilot#Accept("\\<CR>")', {
                expr = true,
                replace_keycodes = false,
                silent = true,
                desc = "Copilot: принять",
            })
            vim.keymap.set("i", "<M-l>", 'copilot#Accept("\\<CR>")', {
                expr = true,
                replace_keycodes = false,
                silent = true,
                desc = "Copilot: принять (Cmd+L)",
            })
            vim.keymap.set("i", "<M-]>", "<Plug>(copilot-next)", { silent = true, desc = "Copilot: следующая подсказка" })
            vim.keymap.set("i", "<M-[>", "<Plug>(copilot-previous)",
                { silent = true, desc = "Copilot: предыдущая подсказка" })
            vim.keymap.set("i", "<C-]>", "<Plug>(copilot-dismiss)", { silent = true, desc = "Copilot: скрыть" })
        end,
    },

    -- --------------------------------------------------------
    -- AI: Copilot Chat (требует установленный Copilot)
    -- Hotkeys: <leader>ac/<leader>ae/<leader>ar/<leader>af
    -- --------------------------------------------------------
    {
        "CopilotC-Nvim/CopilotChat.nvim",
        dependencies = {
            "github/copilot.vim",
            "nvim-lua/plenary.nvim",
        },
        cmd = { "CopilotChat", "CopilotChatToggle", "CopilotChatExplain", "CopilotChatReview", "CopilotChatFix" },
        keys = {
            { "<leader>ac", "<cmd>CopilotChatToggle<cr>", mode = "n", desc = "AI: показать/скрыть чат" },
            { "<leader>ae", "<cmd>CopilotChatExplain<cr>", mode = { "n", "x" }, desc = "AI: объяснить выделение" },
            { "<leader>ar", "<cmd>CopilotChatReview<cr>", mode = { "n", "x" }, desc = "AI: ревью кода" },
            { "<leader>af", "<cmd>CopilotChatFix<cr>", mode = { "n", "x" }, desc = "AI: исправить код" },
        },
        opts = {},
    },

    -- --------------------------------------------------------
    -- AI CLI: Codex и другие агенты прямо внутри Neovim.
    -- Sidekick передаёт агенту файл/позицию/выделение, следит за изменениями
    -- на диске и сохраняет CLI-сессию между перезапусками Neovim через tmux.
    -- NES отключён: inline-подсказки уже предоставляет copilot.vim.
    -- --------------------------------------------------------
    {
        "folke/sidekick.nvim",
        cmd = { "Sidekick" },
        keys = {
            {
                "<C-.>",
                function() require("sidekick.cli").focus({ name = "codex" }) end,
                mode = { "n", "t", "i", "x" },
                desc = "AI: фокус/скрыть Codex",
            },
            {
                "<leader>ax",
                function() require("sidekick.cli").toggle({ name = "codex", focus = true }) end,
                desc = "AI: показать/скрыть Codex",
            },
            {
                "<leader>as",
                function() require("sidekick.cli").select({ filter = { installed = true }, focus = true }) end,
                desc = "AI: выбрать агента/сессию",
            },
            {
                "<leader>at",
                function() require("sidekick.cli").send({ name = "codex", msg = "{this}" }) end,
                mode = { "n", "x" },
                desc = "AI: добавить текущий контекст",
            },
            {
                "<leader>av",
                function() require("sidekick.cli").send({ name = "codex", msg = "{selection}" }) end,
                mode = "x",
                desc = "AI: отправить выделенный текст",
            },
            {
                "<leader>ab",
                function() require("sidekick.cli").send({ name = "codex", msg = "{file}" }) end,
                desc = "AI: добавить текущий файл",
            },
            {
                "<leader>ap",
                function()
                    require("sidekick.cli").prompt(function(_, text)
                        if text then
                            require("sidekick.cli").send({ name = "codex", text = text })
                        end
                    end)
                end,
                mode = { "n", "x" },
                desc = "AI: выбрать готовый промпт",
            },
        },
        opts = {
            nes = { enabled = false },
            copilot = {
                status = { enabled = false },
            },
            cli = {
                watch = true,
                picker = "telescope",
                win = {
                    layout = "right",
                    split = { width = 80, height = 20 },
                },
                mux = {
                    backend = "tmux",
                    enabled = vim.fn.executable("tmux") == 1,
                    create = "terminal",
                },
            },
        },
    },

    -- --------------------------------------------------------
    -- Trouble: панель diagnostics/references/quickfix/locationlist
    -- Hotkeys: <leader>xx/<leader>xw/<leader>xd/<leader>xq/<leader>xl
    -- --------------------------------------------------------
    {
        "folke/trouble.nvim",
        cmd = "Trouble",
        keys = {
            { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Диагностика (Trouble)" },
            { "<leader>xw", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Диагностика буфера" },
            { "<leader>xd", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "LSP: ссылки/определения" },
            { "<leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "Список quickfix" },
            { "<leader>xl", "<cmd>Trouble loclist toggle<cr>", desc = "Список location" },
        },
        opts = {
            focus = true,
        },
    },

}
