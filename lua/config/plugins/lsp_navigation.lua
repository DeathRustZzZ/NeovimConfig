return {
    -- --------------------------------------------------------
    -- Lspsaga: единый UI для finder, hover, rename, actions и call hierarchy.
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
}
