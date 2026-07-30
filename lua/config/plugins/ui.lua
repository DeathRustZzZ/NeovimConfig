return {
    -- --------------------------------------------------------
    -- Which-key: подсказки хоткеев после нажатия leader (Space)
    -- --------------------------------------------------------
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
            preset = "classic",
            delay = 250,
            win = {
                border = "rounded",
                wo = { winblend = 0 },
            },
            icons = {
                breadcrumb = "»",
                separator = "→",
                group = "+",
            },
            spec = {
                { "<leader>a", group = "AI" },
                { "<leader>b", group = "Буферы" },
                { "<leader>c", group = "Cargo/Crates" },
                { "<leader>d", group = "Диагностика/Отладка" },
                { "<leader>f", group = "Поиск/Форматирование" },
                { "<leader>G", group = "Go" },
                { "<leader>g", group = "Git" },
                { "<leader>h", group = "Harpoon/Hunks" },
                { "<leader>l", group = "LSP" },
                { "<leader>p", group = "Пакеты" },
                { "<leader>r", group = "Rust/Runner" },
                { "<leader>t", group = "Терминал/Тесты/Заметки" },
                { "<leader>u", group = "Интерфейс" },
                { "<leader>x", group = "Trouble/Списки" },
            },
        },
    },

    {
        "goolord/alpha-nvim",
        event = "VimEnter",
        cond = function()
            return vim.fn.argc() == 0
        end,
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            local dashboard = require("alpha.themes.dashboard")
            dashboard.section.header.val = {
                "███╗   ██╗██╗   ██╗██╗███╗   ███╗",
                "████╗  ██║██║   ██║██║████╗ ████║",
                "██╔██╗ ██║██║   ██║██║██╔████╔██║",
                "██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║",
                "██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║",
                "╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝",
            }
            dashboard.section.buttons.val = {
                dashboard.button("e", "  New file", "<cmd>ene<CR>"),
                dashboard.button("f", "  Find file", "<cmd>Telescope find_files<CR>"),
                dashboard.button("r", "  Recent files", "<cmd>Telescope oldfiles<CR>"),
                dashboard.button("p", "  Plugins", "<cmd>Lazy<CR>"),
                dashboard.button("q", "  Quit", "<cmd>qa<CR>"),
            }
            require("alpha").setup(dashboard.config)
        end,
    },

    {
        "echasnovski/mini.animate",
        event = "VeryLazy",
        config = function()
            local animate = require("mini.animate")
            animate.setup({
                cursor = { enable = false },
                scroll = {
                    timing = animate.gen_timing.linear({ duration = 80, unit = "total" }),
                },
                resize = {
                    timing = animate.gen_timing.linear({ duration = 80, unit = "total" }),
                },
                open = {
                    timing = animate.gen_timing.linear({ duration = 120, unit = "total" }),
                },
                close = {
                    timing = animate.gen_timing.linear({ duration = 120, unit = "total" }),
                },
            })
        end,
    },

    -- --------------------------------------------------------
    -- Тема (грузим сразу, первой): Catppuccin (lavender + glass)
    -- --------------------------------------------------------
    {
        "catppuccin/nvim",
        name = "catppuccin",
        lazy = false,
        priority = 1000,
        config = function()
            local ui = require("config.ui")
            require("catppuccin").setup({
                flavour = "mocha",
                transparent_background = ui.is_transparent(),
                integrations = {
                    cmp = true,
                    gitsigns = true,
                    telescope = true,
                    notify = true,
                    which_key = true,
                    neotree = true,
                    trouble = true,
                    bufferline = true,
                    lualine = true,
                },
                highlight_overrides = {
                    mocha = function(colors)
                        return {
                            CursorLine = { bg = ui.current().cursorline or colors.surface0 },
                            Visual = { bg = ui.current().visual or colors.surface1 },
                            RainbowDelimiterRed = { fg = colors.red },
                            RainbowDelimiterYellow = { fg = colors.yellow },
                            RainbowDelimiterBlue = { fg = colors.blue },
                            RainbowDelimiterOrange = { fg = colors.peach },
                            RainbowDelimiterGreen = { fg = colors.green },
                            RainbowDelimiterViolet = { fg = colors.mauve },
                            RainbowDelimiterCyan = { fg = colors.teal },
                        }
                    end,
                },
            })
            vim.cmd.colorscheme("catppuccin")
        end,
    },

    -- Иконки (для neo-tree, lualine, telescope, bufferline)
    { "nvim-tree/nvim-web-devicons", lazy = true },
    { "MunifTanjim/nui.nvim",        lazy = true },

    -- --------------------------------------------------------
    -- UI уведомления: красивый notify + переопределение vim.notify
    -- Hotkeys/commands: :Notifications
    -- --------------------------------------------------------
    {
        "rcarriga/nvim-notify",
        event = "VeryLazy",
        config = function()
            local ui = require("config.ui")
            local notify = require("notify")
            local bg = ui.current().float_bg
            notify.setup({
                timeout = 2500,
                background_colour = bg == "NONE" and "#1e1e2e" or bg,
                render = "wrapped-compact",
                stages = "slide",
            })
            vim.notify = notify
        end,
    },

    -- --------------------------------------------------------
    -- UI для vim.ui.select/input (лучше интерфейс команд/меню)
    -- Hotkeys/commands: используется автоматически через vim.ui.select/input
    -- --------------------------------------------------------
    {
        "stevearc/dressing.nvim",
        event = "VeryLazy",
        opts = {
            input = {
                border = "rounded",
                relative = "cursor",
            },
            select = {
                backend = { "telescope", "builtin" },
                builtin = {
                    border = "rounded",
                },
            },
        },
    },

    -- --------------------------------------------------------
    -- Noice: красивый UI для cmdline/messages/lsp hover/signature
    -- --------------------------------------------------------
    {
        "folke/noice.nvim",
        event = "VeryLazy",
        dependencies = {
            "MunifTanjim/nui.nvim",
            "rcarriga/nvim-notify",
        },
        opts = {
            presets = {
                bottom_search = true,
                command_palette = true,
                long_message_to_split = true,
            },
            lsp = {
                progress = { enabled = false },
            },
            views = {
                cmdline_popup = {
                    border = {
                        style = "rounded",
                        padding = { 0, 1 },
                    },
                },
                popupmenu = {
                    border = {
                        style = "rounded",
                        padding = { 0, 1 },
                    },
                },
            },
        },
    },

    -- --------------------------------------------------------
    -- LSP прогресс внизу (легковесный индикатор задач)
    -- Hotkeys/commands: :Fidget
    -- --------------------------------------------------------
    {
        "j-hui/fidget.nvim",
        event = "LspAttach",
        opts = {
            notification = {
                window = { winblend = 0 },
            },
        },
    },

    -- --------------------------------------------------------
    -- Lualine: статуслайн
    -- --------------------------------------------------------
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        event = "VimEnter",
        config = function()
            require("lualine").setup({
                options = {
                    theme = "auto",
                    section_separators = { left = "", right = "" },
                    component_separators = { left = "│", right = "│" },
                },
                sections = {
                    lualine_a = { { "mode", icon = "" } },
                    lualine_b = { { "branch", icon = "" }, "diff" },
                    lualine_c = {
                        {
                            "filename",
                            path = 1,
                            symbols = { modified = " ●", readonly = " ", unnamed = "[No Name]" },
                        },
                    },
                    lualine_x = { "diagnostics", "encoding", "filetype" },
                    lualine_y = { "progress" },
                    lualine_z = { "location" },
                },
            })
        end,
    },

    -- --------------------------------------------------------
    -- Bufferline: вкладки-буферы с диагностикой
    -- Hotkeys: <leader>bp/<leader>bn/<leader>bd
    -- --------------------------------------------------------
    {
        "akinsho/bufferline.nvim",
        event = "VeryLazy",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        init = function()
            vim.g.user_smart_bdelete = function()
                local listed = vim.fn.getbufinfo({ buflisted = 1 })
                if #listed <= 1 then
                    local cur = vim.api.nvim_get_current_buf()
                    vim.cmd("enew")
                    pcall(vim.cmd, "bdelete " .. cur)
                    return
                end
                vim.cmd("bdelete")
            end
        end,
        keys = {
            { "<leader>bp", "<cmd>BufferLineCyclePrev<cr>", desc = "Предыдущий буфер" },
            { "<leader>bn", "<cmd>BufferLineCycleNext<cr>", desc = "Следующий буфер" },
            {
                "<leader>bd",
                function()
                    if type(vim.g.user_smart_bdelete) == "function" then
                        vim.g.user_smart_bdelete()
                    else
                        vim.cmd("bdelete")
                    end
                end,
                desc = "Закрыть буфер",
            },
            { "<leader>bP", "<cmd>BufferLineTogglePin<cr>", desc = "Закрепить/открепить буфер" },
        },
        config = function()
            require("bufferline").setup({
                options = {
                    diagnostics = "nvim_lsp",
                    always_show_bufferline = true,
                    separator_style = "slant",
                    hover = {
                        enabled = true,
                        delay = 120,
                        reveal = { "close" },
                    },
                    diagnostics_indicator = function(_, _, diag)
                        local icons = { error = " ", warning = " ", info = " " }
                        local out = ""
                        for level, icon in pairs(icons) do
                            if diag[level] and diag[level] > 0 then
                                out = out .. icon .. diag[level] .. " "
                            end
                        end
                        return vim.trim(out)
                    end,
                    offsets = {
                        {
                            filetype = "neo-tree",
                            text = "File Explorer",
                            highlight = "Directory",
                            text_align = "left",
                        },
                    },
                },
            })
        end,
    },

    -- --------------------------------------------------------
    -- Neo-tree: современное файловое дерево слева
    -- --------------------------------------------------------
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        init = function()
            -- Disable netrw early to avoid conflicts when opening directories/files.
            vim.g.loaded_netrw = 1
            vim.g.loaded_netrwPlugin = 1

            -- If Neovim is started with a directory (e.g. `nvim .`), open Neo-tree instead
            -- of leaving a blank buffer as the only window.
            if vim.fn.argc() == 1 then
                local arg = vim.fn.argv(0)
                if arg ~= "" and vim.fn.isdirectory(arg) == 1 then
                    local startup_buf = vim.api.nvim_get_current_buf()
                    vim.api.nvim_create_autocmd("VimEnter", {
                        once = true,
                        callback = function()
                            local escaped_arg = vim.fn.fnameescape(arg)
                            local ok_cd, cd_err = pcall(vim.cmd, "cd " .. escaped_arg)
                            if not ok_cd then
                                vim.notify("Не удалось перейти в директорию: " .. tostring(cd_err), vim.log.levels.WARN)
                                return
                            end

                            if vim.fn.exists(":Neotree") == 0 then
                                vim.notify("Команда :Neotree недоступна на VimEnter, пропускаю автооткрытие дерева.",
                                    vim.log.levels.WARN)
                                return
                            end

                            local ok_tree, tree_err = pcall(vim.cmd, "Neotree position=left dir=" .. escaped_arg)
                            if not ok_tree then
                                vim.notify("Не удалось открыть Neo-tree: " .. tostring(tree_err), vim.log.levels.WARN)
                                return
                            end

                            -- Remove the initial empty [No Name] buffer created by `nvim <dir>`.
                            vim.schedule(function()
                                if not vim.api.nvim_buf_is_valid(startup_buf) then return end
                                local name = vim.api.nvim_buf_get_name(startup_buf)
                                local lines = vim.api.nvim_buf_get_lines(startup_buf, 0, 1, false)
                                local first_line = lines[1] or ""
                                local is_empty_unnamed = (name == "")
                                    and (vim.bo[startup_buf].buftype == "")
                                    and (vim.bo[startup_buf].modified == false)
                                    and (vim.api.nvim_buf_line_count(startup_buf) <= 1)
                                    and (first_line == "")

                                if is_empty_unnamed then
                                    pcall(vim.api.nvim_buf_delete, startup_buf, { force = true })
                                end
                            end)
                        end,
                    })
                end
            end
        end,
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
        },
        keys = {
            { "<leader>e", "<cmd>Neotree toggle position=left<cr>", desc = "Показать/скрыть дерево файлов" },
            { "<leader>E", "<cmd>Neotree reveal position=left<cr>", desc = "Показать текущий файл в дереве" },
        },
        opts = {
            -- Avoid quit warnings when Neo-tree is the last window and there are unsaved buffers.
            close_if_last_window = false,
            filesystem = {
                use_libuv_file_watcher = false,
                follow_current_file = { enabled = true },
                window = {
                    position = "left",
                    width = 32,
                    mappings = {
                        ["w"] = "open",
                        ["K"] = "noop",
                    },
                },
            },
            default_component_configs = {
                indent = {
                    indent_size = 2,
                    padding = 1,
                    with_markers = true,
                    indent_marker = "│",
                    last_indent_marker = "└",
                    expander_collapsed = "",
                    expander_expanded = "",
                    expander_highlight = "NeoTreeExpander",
                },
            },
            window = {
                position = "left",
                width = 32,
            },
        },
    },

    -- --------------------------------------------------------
    -- Aerial: структура файла (символы/функции/типы) в отдельной панели
    -- Hotkeys: <leader>o
    -- --------------------------------------------------------
    {
        "stevearc/aerial.nvim",
        cmd = { "AerialToggle", "AerialOpen", "AerialNavToggle" },
        dependencies = {
            "nvim-tree/nvim-web-devicons",
            "nvim-treesitter/nvim-treesitter",
        },
        keys = {
            { "<leader>o", "<cmd>AerialToggle right<cr>", desc = "Структура файла (Aerial)" },
        },
        opts = {
            layout = {
                default_direction = "right",
                min_width = 28,
            },
            show_guides = true,
            filter_kind = false,
        },
    },

    -- --------------------------------------------------------
    -- Telescope: поиск файлов/текста
    -- + fzf-native: ускоряет сортировку/поиск (очень заметно)
    -- --------------------------------------------------------
    { "nvim-lua/plenary.nvim",                  lazy = true },
    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope-fzf-native.nvim",
            "nvim-telescope/telescope-ui-select.nvim",
        },
        cmd = "Telescope",
        keys = {
            { "<leader>ff", function() require("telescope.builtin").find_files() end, desc = "Найти файлы" },
            { "<leader>fg", function() require("telescope.builtin").live_grep() end, desc = "Поиск по проекту" },
            { "<leader>fb", function() require("telescope.builtin").buffers() end, desc = "Буферы" },
            { "<leader>fh", function() require("telescope.builtin").help_tags() end, desc = "Справка" },
        },
        config = function()
            local telescope = require("telescope")
            telescope.setup({
                defaults = {
                    sorting_strategy = "ascending",
                    layout_config = { prompt_position = "top" },
                    border = true,
                    borderchars = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
                    winblend = 0,
                },
                extensions = {
                    ["ui-select"] = require("telescope.themes").get_dropdown({}),
                },
            })
            pcall(telescope.load_extension, "fzf")
            pcall(telescope.load_extension, "ui-select")
        end,
    },
    {
        "nvim-telescope/telescope-fzf-native.nvim",
        enabled = function()
            return vim.fn.executable("make") == 1
        end,
        build = "make", -- нужен make (base-devel на Arch)
    },
    { "nvim-telescope/telescope-ui-select.nvim" },
}
