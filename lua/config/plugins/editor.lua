return {
    -- --------------------------------------------------------
    -- Treesitter: умная подсветка/отступы
    -- + textobjects: удобные движения/объекты по функциям/блокам
    -- --------------------------------------------------------
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        event = { "BufReadPost", "BufNewFile" },
        dependencies = {
            "HiPhish/rainbow-delimiters.nvim",
        },
        config = function()
            local ok, configs = pcall(require, "nvim-treesitter.configs")
            if not ok then return end

            configs.setup({
                ensure_installed = {
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
                },
                highlight = { enable = true },
                indent = { enable = true },
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
            local ok, configs = pcall(require, "nvim-treesitter.configs")
            if not ok then return end

            configs.setup({
                textobjects = {
                    select = {
                        enable = true,
                        lookahead = true,
                        keymaps = {
                            ["af"] = "@function.outer",
                            ["if"] = "@function.inner",
                            ["ac"] = "@class.outer",
                            ["ic"] = "@class.inner",
                        },
                    },
                    move = {
                        enable = true,
                        set_jumps = true,
                        goto_next_start = { ["]m"] = "@function.outer" },
                        goto_previous_start = { ["[m"] = "@function.outer" },
                    },
                },
            })
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
        config = function()
            require("gitsigns").setup()
            vim.keymap.set("n", "<leader>hs", require("gitsigns").stage_hunk, { desc = "Добавить hunk в индекс" })
            vim.keymap.set("n", "<leader>hr", require("gitsigns").reset_hunk, { desc = "Откатить hunk" })
            vim.keymap.set("n", "<leader>hp", require("gitsigns").preview_hunk, { desc = "Предпросмотр hunk" })
            vim.keymap.set("n", "<leader>hb", require("gitsigns").blame_line, { desc = "Blame строки" })
        end,
    },

    -- --------------------------------------------------------
    -- Diffview: удобный git diff/история в отдельном UI
    -- Hotkeys: <leader>gd/<leader>gD/<leader>gH
    -- --------------------------------------------------------
    {
        "sindrets/diffview.nvim",
        cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
        keys = {
            { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Открыть diff" },
            { "<leader>gD", "<cmd>DiffviewClose<cr>", desc = "Закрыть diff" },
            { "<leader>gH", "<cmd>DiffviewFileHistory %<cr>", desc = "История файла" },
        },
        opts = {},
    },

    -- --------------------------------------------------------
    -- Neogit: IDE-подобный git UI (commit/push/pull/stash/rebase/cherrypick)
    -- Hotkeys: <leader>gg/<leader>gc/<leader>gp/<leader>gP/<leader>gl
    -- --------------------------------------------------------
    {
        "NeogitOrg/neogit",
        cmd = "Neogit",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "sindrets/diffview.nvim",
        },
        keys = {
            { "<leader>gg", "<cmd>Neogit kind=split<cr>", desc = "Git статус (Neogit)" },
            { "<leader>gc", "<cmd>Neogit commit<cr>", desc = "Git commit (Neogit)" },
            { "<leader>gp", "<cmd>Neogit push<cr>", desc = "Git push (Neogit)" },
            { "<leader>gP", "<cmd>Neogit pull<cr>", desc = "Git pull (Neogit)" },
            { "<leader>gl", "<cmd>Neogit log<cr>", desc = "Git лог (Neogit)" },
        },
        opts = {
            kind = "split",
            integrations = {
                diffview = true,
            },
            signs = {
                section = { "", "" },
                item = { "", "" },
                hunk = { "", "" },
            },
        },
    },

    -- --------------------------------------------------------
    -- LazyGit integration: быстрый TUI для git внутри Neovim
    -- Hotkeys: <leader>lg
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
            { "<leader>lg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
        },
    },

    -- --------------------------------------------------------
    -- Git conflict helper: навигация и принятие ours/theirs/both
    -- Hotkeys: <leader>gco/<leader>gct/<leader>gcb/<leader>gcn/<leader>gcp
    -- --------------------------------------------------------
    {
        "akinsho/git-conflict.nvim",
        version = "*",
        event = "BufReadPost",
        keys = {
            { "<leader>gco", "<cmd>GitConflictChooseOurs<cr>", desc = "Конфликт: выбрать ours" },
            { "<leader>gct", "<cmd>GitConflictChooseTheirs<cr>", desc = "Конфликт: выбрать theirs" },
            { "<leader>gcb", "<cmd>GitConflictChooseBoth<cr>", desc = "Конфликт: выбрать оба" },
            { "<leader>gcn", "<cmd>GitConflictNextConflict<cr>", desc = "Конфликт: следующий" },
            { "<leader>gcp", "<cmd>GitConflictPrevConflict<cr>", desc = "Конфликт: предыдущий" },
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
        "ThePrimeagen/git-worktree.nvim",
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
            require("git-worktree").setup()
            pcall(function()
                require("telescope").load_extension("git_worktree")
            end)
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
    -- Комментарии: gc (line), gcip (block) и т.п.
    -- --------------------------------------------------------
    {
        "numToStr/Comment.nvim",
        event = "VeryLazy",
        config = function()
            require("Comment").setup()
        end,
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
    -- Hotkeys: <leader>at/<leader>tg/<leader>tf
    -- --------------------------------------------------------
    {
        "akinsho/toggleterm.nvim",
        version = "*",
        cmd = { "ToggleTerm", "TermExec" },
        keys = {
            { "<leader>at", "<cmd>ToggleTerm<cr>", desc = "Показать/скрыть терминал" },
            { "<leader>tg", "<cmd>ToggleTerm direction=float<cr>", desc = "Терминал (float)" },
            { "<leader>tf", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "Терминал (горизонтальный)" },
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
            vim.keymap.set("i", "<C-l>", 'copilot#Accept("\\<CR>")', {
                expr = true,
                replace_keycodes = false,
                silent = true,
                desc = "Copilot: принять",
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
    -- AI: OpenAI Codex (через Codex CLI вне Neovim)
    -- Hotkeys: <leader>ax
    -- --------------------------------------------------------
    {
        "johnseth97/codex.nvim",
        cmd = { "CodexToggle" },
        keys = {
            { "<leader>ax", "<cmd>CodexToggle<cr>", desc = "AI: показать/скрыть Codex" },
        },
        opts = {},
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
