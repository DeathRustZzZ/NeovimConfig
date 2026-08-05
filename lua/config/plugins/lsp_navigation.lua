return {
    -- --------------------------------------------------------
    -- Glance: preview definitions/references/implementations without jumping away.
    -- Hotkeys: <leader>ld/<leader>lR/<leader>ly/<leader>lm, :Glance
    -- --------------------------------------------------------
    {
        "DNLHC/glance.nvim",
        cmd = "Glance",
        keys = {
            { "<leader>ld", "<cmd>Glance definitions<cr>", desc = "LSP: preview definitions (Glance)" },
            { "<leader>lR", "<cmd>Glance references<cr>", desc = "LSP: preview references (Glance)" },
            { "<leader>ly", "<cmd>Glance type_definitions<cr>", desc = "LSP: preview type definitions (Glance)" },
            { "<leader>lm", "<cmd>Glance implementations<cr>", desc = "LSP: preview implementations (Glance)" },
        },
        opts = {
            height = 18,
            zindex = 45,
            preserve_win_context = true,
            detached = function(winid)
                return vim.api.nvim_win_get_width(winid) < 120
            end,
            preview_win_opts = {
                cursorline = true,
                number = true,
                wrap = true,
            },
            border = {
                enable = true,
                top_char = "─",
                bottom_char = "─",
            },
            list = {
                position = "right",
                width = 0.34,
            },
            folds = {
                folded = false,
            },
            use_trouble_qf = true,
        },
    },

    -- --------------------------------------------------------
    -- Lspsaga: richer LSP UI for finder, hover, rename, actions and call hierarchy.
    -- Hotkeys: <leader>lf/<leader>lp/<leader>lP/<leader>lh/<leader>la/<leader>ln/<leader>lc/<leader>lC
    -- --------------------------------------------------------
    {
        "nvimdev/lspsaga.nvim",
        event = "LspAttach",
        cmd = "Lspsaga",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-tree/nvim-web-devicons",
        },
        keys = {
            { "<leader>lf", "<cmd>Lspsaga finder tyd+ref+imp+def<cr>", desc = "LSP: finder (Saga)" },
            { "<leader>lp", "<cmd>Lspsaga peek_definition<cr>", desc = "LSP: peek definition (Saga)" },
            { "<leader>lP", "<cmd>Lspsaga peek_type_definition<cr>", desc = "LSP: peek type definition (Saga)" },
            { "<leader>lh", "<cmd>Lspsaga hover_doc<cr>", desc = "LSP: hover (Saga)" },
            { "<leader>la", "<cmd>Lspsaga code_action<cr>", mode = { "n", "x" }, desc = "LSP: code action (Saga)" },
            { "<leader>ln", "<cmd>Lspsaga rename<cr>", desc = "LSP: rename (Saga)" },
            { "<leader>lc", "<cmd>Lspsaga incoming_calls<cr>", desc = "LSP: incoming calls (Saga)" },
            { "<leader>lC", "<cmd>Lspsaga outgoing_calls<cr>", desc = "LSP: outgoing calls (Saga)" },
        },
        opts = {
            ui = {
                border = "rounded",
                title = true,
                devicon = true,
            },
            symbol_in_winbar = {
                enable = false,
            },
            lightbulb = {
                enable = false,
            },
            finder = {
                default = "tyd+ref+imp+def",
                layout = "float",
            },
            callhierarchy = {
                layout = "float",
            },
            definition = {
                width = 0.65,
                height = 0.55,
                keys = {
                    edit = "o",
                    vsplit = "v",
                    split = "s",
                    tabe = "t",
                    quit = "q",
                    close = "<Esc>",
                },
            },
            rename = {
                in_select = true,
                auto_save = false,
            },
            code_action = {
                show_server_name = true,
                extend_gitsigns = true,
            },
        },
    },

    -- --------------------------------------------------------
    -- Calltree: explorable callers/callees tree via LSP Call Hierarchy.
    -- Hotkeys: <leader>lI/<leader>lO/<leader>lT, :LTPanel
    -- --------------------------------------------------------
    {
        "ldelossa/litee.nvim",
        lazy = true,
        opts = {
            notify = { enabled = false },
            panel = {
                orientation = "right",
                panel_size = 38,
            },
            tree = {
                icon_set = "codicons",
                indent_guides = true,
            },
        },
        config = function(_, opts)
            require("litee.lib").setup(opts)
        end,
    },
    {
        "ldelossa/litee-calltree.nvim",
        dependencies = {
            "ldelossa/litee.nvim",
        },
        event = "LspAttach",
        keys = {
            { "<leader>lI", vim.lsp.buf.incoming_calls, desc = "LSP: calltree incoming" },
            { "<leader>lO", vim.lsp.buf.outgoing_calls, desc = "LSP: calltree outgoing" },
            { "<leader>lT", "<cmd>LTPanel<cr>", desc = "LSP: toggle Calltree panel" },
        },
        opts = {
            resolve_symbols = true,
            jump_mode = "invoking",
            hide_cursor = true,
            map_resize_keys = false,
            on_open = "panel",
            keymaps = {
                expand = "zo",
                collapse = "zc",
                toggle = "zt",
                jump = "<CR>",
                jump_split = "s",
                jump_vsplit = "v",
                jump_tab = "t",
                hover = "i",
                details = "d",
                close = "X",
                help = "?",
                hide = "<Esc>",
                switch = "S",
                focus = "f",
            },
        },
        config = function(_, opts)
            require("litee.calltree").setup(opts)
        end,
    },
}
