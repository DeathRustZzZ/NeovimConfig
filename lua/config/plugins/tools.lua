return {
    -- Completion: nvim-cmp + LSP/paths/buffer/snippets + lspkind
    -- --------------------------------------------------------
    {
        "L3MON4D3/LuaSnip",
        event = "InsertEnter",
        dependencies = {
            -- friendly-snippets: готовые сниппеты для популярных языков
            -- Hotkeys/commands: используется через completion + Tab/S-Tab
            "rafamadriz/friendly-snippets",
        },
        config = function()
            require("luasnip.loaders.from_vscode").lazy_load()
            require("luasnip.loaders.from_lua").lazy_load({
                paths = { vim.fn.stdpath("config") .. "/lua/config/snippets" },
            })
        end,
    },
    { "hrsh7th/cmp-nvim-lsp", lazy = true },
    {
        -- cmp-buffer: completion по словам из текущих открытых буферов
        -- Hotkeys/commands: доступно в popup completion
        "hrsh7th/cmp-buffer",
        event = "InsertEnter",
    },
    {
        -- cmp-path: completion путей в строках/командах
        -- Hotkeys/commands: доступно в popup completion
        "hrsh7th/cmp-path",
        event = "InsertEnter",
    },
    {
        -- cmp_luasnip: completion из LuaSnip сниппетов
        -- Hotkeys/commands: Tab/S-Tab для перехода по плейсхолдерам
        "saadparwaiz1/cmp_luasnip",
        event = "InsertEnter",
    },
    {
        -- lspkind: иконки типов символов в completion меню
        -- Hotkeys/commands: используется внутри nvim-cmp
        "onsails/lspkind.nvim",
        event = "InsertEnter",
    },
    {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "saadparwaiz1/cmp_luasnip",
            "L3MON4D3/LuaSnip",
            "onsails/lspkind.nvim",
        },
        config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")
            local lspkind = require("lspkind")

            cmp.setup({
                snippet = {
                    expand = function(args) luasnip.lsp_expand(args.body) end,
                },
                mapping = cmp.mapping.preset.insert({
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                }),
                formatting = {
                    format = lspkind.cmp_format({
                        mode = "symbol_text",
                        maxwidth = 50,
                        ellipsis_char = "...",
                    }),
                },
                sources = {
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                    { name = "path" },
                    { name = "buffer" },
                },
            })

            local ok_cmp_autopairs, cmp_autopairs = pcall(require, "nvim-autopairs.completion.cmp")
            if ok_cmp_autopairs then
                cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
            end
        end,
    },

    -- --------------------------------------------------------
    -- Rust crates: версии/апдейты в Cargo.toml + встроенный LSP crates.nvim
    -- Hotkeys: <leader>cp/<leader>ch/<leader>cd/<leader>cu/<leader>cU
    -- --------------------------------------------------------
    {
        "saecki/crates.nvim",
        event = { "BufRead Cargo.toml", "BufNewFile Cargo.toml" },
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local crates = require("crates")

            crates.setup({
                lsp = {
                    enabled = true,
                    actions = true,
                    completion = true,
                    hover = true,
                },
            })

            vim.keymap.set("n", "<leader>cp", "<cmd>CratesShowPopup<cr>", { desc = "Crates: всплывающее окно" })
            vim.keymap.set("n", "<leader>ch", "<cmd>CratesShowPopup<cr>", { desc = "Crates: всплывающее окно" })
            vim.keymap.set("n", "<leader>cd", function()
                if crates.open_documentation and pcall(crates.open_documentation) then
                    return
                end

                local token = vim.fn.expand("<cWORD>") or ""
                local crate = token:match("([%w_-]+)")
                if not crate or crate == "" then
                    vim.notify("Crate под курсором не найден", vim.log.levels.WARN)
                    return
                end

                local url = ("https://docs.rs/%s"):format(crate)
                if vim.ui and vim.ui.open then
                    vim.ui.open(url)
                else
                    vim.fn.jobstart({ "xdg-open", url }, { detach = true })
                end
            end, { desc = "Crates: открыть docs.rs" })
            vim.keymap.set("n", "<leader>cu", "<cmd>CratesUpdate<cr>", { desc = "Crates: обновить текущий" })
            vim.keymap.set("n", "<leader>cU", "<cmd>CratesUpdateAll<cr>", { desc = "Crates: обновить все" })
        end,
    },

    -- --------------------------------------------------------
    -- Форматирование: Conform.nvim
    -- Для Rust будет rustfmt, для TOML taplo, для Lua stylua
    -- + автоформат при сохранении
    -- --------------------------------------------------------
    {
        "stevearc/conform.nvim",
        event = { "BufWritePre" },
        config = function()
            local conform = require("conform")

            conform.setup({
                formatters_by_ft = {
                    rust = { "rustfmt" },
                    toml = { "taplo" },
                    lua = { "stylua" },
                },
                format_on_save = function(_)
                    return {
                        timeout_ms = 1500,
                        lsp_fallback = true,
                    }
                end,
            })

            vim.keymap.set("n", "<leader>f", function()
                conform.format({ async = true, lsp_fallback = true })
            end, { desc = "Форматировать файл" })
        end,
    },

    -- --------------------------------------------------------
    -- Mason: менеджер LSP/DAP/линтеров/форматтеров
    -- Hotkeys/commands: <leader>pm, :Mason, :MasonInstall
    -- --------------------------------------------------------
    {
        "williamboman/mason.nvim",
        cmd = { "Mason", "MasonInstall", "MasonUpdate" },
        keys = {
            { "<leader>pm", "<cmd>Mason<cr>", desc = "Менеджер пакетов (Mason)" },
        },
        opts = {
            ui = {
                border = "rounded",
            },
        },
    },

    -- --------------------------------------------------------
    -- mason-lspconfig: мост между mason и nvim-lspconfig
    -- Hotkeys/commands: работает автоматически после установки серверов
    -- --------------------------------------------------------
    {
        "williamboman/mason-lspconfig.nvim",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "williamboman/mason.nvim",
            "neovim/nvim-lspconfig",
        },
        opts = {
            automatic_enable = false,
            ensure_installed = { "lua_ls", "taplo" },
        },
    },

    -- --------------------------------------------------------
    -- mason-tool-installer: автоустановка CLI инструментов
    -- Hotkeys/commands: :MasonToolsInstall, :MasonToolsUpdate
    -- --------------------------------------------------------
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        event = "VeryLazy",
        dependencies = { "williamboman/mason.nvim" },
        opts = {
            ensure_installed = {
                "rust-analyzer",
                "codelldb",
                "taplo",
                "stylua",
            },
            auto_update = false,
            run_on_start = false,
            start_delay = 3000,
        },
    },

}
