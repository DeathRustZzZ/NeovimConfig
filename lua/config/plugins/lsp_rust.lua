return {
    -- LSP базовая конфигурация (кроме Rust)
    -- ВАЖНО: rust_analyzer здесь НЕ настраиваем — его полностью ведёт rustaceanvim,
    -- иначе будет двойной attach и конфликт настроек.
    -- --------------------------------------------------------
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            if vim.fn.exepath("rustowl") == "" and type(vim.lsp.enable) == "function" then
                pcall(vim.lsp.enable, "rustowl", false)
            end

            local function client_supports_inlay_hints(client)
                if not client then return false end
                if client.supports_method then
                    return client:supports_method("textDocument/inlayHint")
                end
                return client.server_capabilities and client.server_capabilities.inlayHintProvider
            end

            local function set_inlay_hints(bufnr, value)
                if not vim.lsp.inlay_hint then return end
                local ok = pcall(vim.lsp.inlay_hint.enable, value, { bufnr = bufnr })
                if not ok then
                    pcall(vim.lsp.inlay_hint.enable, bufnr, value)
                end
            end

            local function inlay_hints_enabled(bufnr)
                if not vim.lsp.inlay_hint then return false end
                local ok, enabled = pcall(vim.lsp.inlay_hint.is_enabled, { bufnr = bufnr })
                if ok then return enabled end
                ok, enabled = pcall(vim.lsp.inlay_hint.is_enabled, bufnr)
                return ok and enabled or false
            end

            local function buffer_supports_inlay_hints(bufnr)
                for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
                    if client_supports_inlay_hints(client) then
                        return true
                    end
                end
                return false
            end

            vim.diagnostic.config({
                virtual_text = true,
                signs = true,
                underline = true,
                update_in_insert = false,
                severity_sort = true,
                float = { border = "rounded" },
            })

            local lsp_attach_group = vim.api.nvim_create_augroup("UserLspAttachMaps", { clear = true })
            vim.api.nvim_create_autocmd("LspAttach", {
                group = lsp_attach_group,
                callback = function(args)
                    local opts = { buffer = args.buf }
                    local client = vim.lsp.get_client_by_id(args.data.client_id)
                    local navic_ok, navic = pcall(require, "nvim-navic")
                    vim.keymap.set("n", "gd", vim.lsp.buf.definition,
                        vim.tbl_extend("force", opts, { desc = "LSP: перейти к определению" }))
                    vim.keymap.set("n", "gD", vim.lsp.buf.declaration,
                        vim.tbl_extend("force", opts, { desc = "LSP: перейти к объявлению" }))
                    vim.keymap.set("n", "gi", vim.lsp.buf.implementation,
                        vim.tbl_extend("force", opts, { desc = "LSP: перейти к реализации" }))
                    vim.keymap.set("n", "gr", vim.lsp.buf.references,
                        vim.tbl_extend("force", opts, { desc = "LSP: показать ссылки" }))
                    vim.keymap.set("n", "gy", vim.lsp.buf.type_definition,
                        vim.tbl_extend("force", opts, { desc = "LSP: перейти к типу" }))
                    vim.keymap.set("n", "K", vim.lsp.buf.hover,
                        vim.tbl_extend("force", opts, { desc = "LSP: подсказка" }))
                    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename,
                        vim.tbl_extend("force", opts, { desc = "LSP: переименовать" }))
                    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action,
                        vim.tbl_extend("force", opts, { desc = "LSP: действия с кодом" }))
                    vim.keymap.set("n", "<leader>ls", function()
                        local ok, builtin = pcall(require, "telescope.builtin")
                        if ok then
                            builtin.lsp_document_symbols()
                        else
                            vim.lsp.buf.document_symbol()
                        end
                    end, vim.tbl_extend("force", opts, { desc = "LSP: символы документа" }))
                    vim.keymap.set("n", "<leader>lS", function()
                        local ok, builtin = pcall(require, "telescope.builtin")
                        if ok then
                            builtin.lsp_workspace_symbols()
                        else
                            vim.lsp.buf.workspace_symbol()
                        end
                    end, vim.tbl_extend("force", opts, { desc = "LSP: символы workspace" }))
                    vim.keymap.set("n", "<leader>li", vim.lsp.buf.incoming_calls,
                        vim.tbl_extend("force", opts, { desc = "LSP: incoming calls" }))
                    vim.keymap.set("n", "<leader>lo", vim.lsp.buf.outgoing_calls,
                        vim.tbl_extend("force", opts, { desc = "LSP: outgoing calls" }))

                    if client_supports_inlay_hints(client) then
                        set_inlay_hints(args.buf, true)
                    end

                    if navic_ok and client and client.server_capabilities and client.server_capabilities.documentSymbolProvider then
                        pcall(navic.attach, client, args.buf)
                    end

                    vim.keymap.set("n", "<leader>uh", function()
                        if not vim.lsp.inlay_hint then
                            vim.notify("Inlay hints не поддерживаются этой версией Neovim", vim.log.levels.WARN)
                            return
                        end
                        if not buffer_supports_inlay_hints(args.buf) then
                            vim.notify("LSP сервер не поддерживает inlay hints", vim.log.levels.WARN)
                            return
                        end
                        set_inlay_hints(args.buf, not inlay_hints_enabled(args.buf))
                    end, vim.tbl_extend("force", opts, { desc = "Вкл/выкл inlay hints" }))

                    if vim.bo[args.buf].filetype == "rust" then
                        vim.keymap.set("n", "<leader>rh", vim.lsp.buf.hover,
                            vim.tbl_extend("force", opts, { desc = "Rust: документация" }))
                        vim.keymap.set("n", "<leader>ra", vim.lsp.buf.code_action,
                            vim.tbl_extend("force", opts, { desc = "Rust: действия с кодом" }))
                    end
                end,
            })

            local diag_float_group = vim.api.nvim_create_augroup("UserDiagnosticFloat", { clear = true })
            local diag_float_wins = {}
            vim.api.nvim_create_autocmd("CursorHold", {
                group = diag_float_group,
                callback = function()
                    if vim.api.nvim_get_mode().mode ~= "n" then return end

                    local bufnr = vim.api.nvim_get_current_buf()
                    local line = vim.api.nvim_win_get_cursor(0)[1] - 1
                    if vim.tbl_isempty(vim.diagnostic.get(bufnr, { lnum = line })) then return end

                    local winid = diag_float_wins[bufnr]
                    if winid and vim.api.nvim_win_is_valid(winid) then return end

                    local new_winid = vim.diagnostic.open_float(bufnr, {
                        scope = "line",
                        focusable = false,
                        border = "rounded",
                        source = "if_many",
                    })
                    if type(new_winid) == "number" then
                        diag_float_wins[bufnr] = new_winid
                    end
                end,
            })
            vim.api.nvim_create_autocmd({ "CursorMoved", "InsertEnter", "BufLeave" }, {
                group = diag_float_group,
                callback = function(ev)
                    local winid = diag_float_wins[ev.buf]
                    if not winid then return end
                    if vim.api.nvim_win_is_valid(winid) then
                        pcall(vim.api.nvim_win_close, winid, true)
                    end
                    diag_float_wins[ev.buf] = nil
                end,
            })

            local capabilities = vim.lsp.protocol.make_client_capabilities()
            local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
            if ok_cmp then
                capabilities = cmp_lsp.default_capabilities(capabilities)
            end

            local servers = {
                lua_ls = {
                    capabilities = capabilities,
                    settings = {
                        Lua = {
                            diagnostics = { globals = { "vim" } },
                            completion = { callSnippet = "Replace" },
                        },
                    },
                },
                taplo = {
                    capabilities = capabilities,
                },
                gopls = {
                    capabilities = capabilities,
                    settings = {
                        gopls = {
                            gofumpt = false,
                            staticcheck = true,
                            semanticTokens = true,
                            usePlaceholders = true,
                            completeUnimported = true,
                            analyses = {
                                nilness = true,
                                shadow = true,
                                unusedparams = true,
                                unusedwrite = true,
                            },
                            codelenses = {
                                gc_details = true,
                                generate = true,
                                regenerate_cgo = true,
                                run_govulncheck = true,
                                test = true,
                                tidy = true,
                                upgrade_dependency = true,
                                vendor = true,
                            },
                            hints = {
                                assignVariableTypes = true,
                                compositeLiteralFields = true,
                                compositeLiteralTypes = true,
                                constantValues = true,
                                functionTypeParameters = true,
                                parameterNames = true,
                                rangeVariableTypes = true,
                            },
                        },
                    },
                },
            }

            local lsp_config_mt = type(vim.lsp.config) == "table" and getmetatable(vim.lsp.config) or nil
            local use_new_lsp_api = type(vim.lsp.enable) == "function"
                and (type(vim.lsp.config) == "function" or (lsp_config_mt and type(lsp_config_mt.__call) == "function"))
            local ok_lspconfig, lspconfig = pcall(require, "lspconfig")

            for server, config in pairs(servers) do
                if use_new_lsp_api then
                    vim.lsp.config(server, config)
                    vim.lsp.enable(server)
                elseif ok_lspconfig then
                    -- Avoid deprecated lspconfig metatable access on Neovim 0.11+
                    -- (lspconfig[server] triggers vim.deprecate with traceback).
                    local ok_server, server_config = pcall(require, "lspconfig.configs." .. server)
                    if ok_server and server_config and type(server_config.setup) == "function" then
                        server_config.setup(config)
                    end
                end
            end
        end,
    },

    -- --------------------------------------------------------
    -- Rust LSP/IDE: rustaceanvim (стабильнее и проще поддержки для Rust)
    -- Выбран вместо ручной настройки rust_analyzer в lspconfig, чтобы не дублировать LSP клиент.
    -- Hotkeys/commands: <leader>rr/<leader>rd, :RustLsp runnables/debuggables
    -- --------------------------------------------------------
    {
        "mrcjkb/rustaceanvim",
        version = "^6",
        ft = { "rust" },
        init = function()
            vim.g.rustaceanvim = {
                server = {
                    default_settings = {
                        ["rust-analyzer"] = {
                            cargo = { allFeatures = true },
                            procMacro = {
                                enable = true,
                                attributes = { enable = true },
                            },
                            checkOnSave = true,
                            check = { command = "clippy" },
                        },
                    },
                },
            }
        end,
        config = function()
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "rust",
                callback = function(ev)
                    local opts = { buffer = ev.buf }
                    vim.keymap.set("n", "<leader>rr", function()
                        vim.cmd("RustLsp runnables")
                    end, vim.tbl_extend("force", opts, { desc = "Rust: запускаемые цели" }))
                    vim.keymap.set("n", "<leader>rd", function()
                        vim.cmd("RustLsp debuggables")
                    end, vim.tbl_extend("force", opts, { desc = "Rust: отладочные цели" }))
                end,
            })
        end,
    },

    -- --------------------------------------------------------
    -- Overseer: task runner (RustRover-like Run/Build/Test/Clippy)
    -- Hotkeys: <leader>rR/<leader>rt/<leader>rc/<leader>rb/<leader>rp
    -- --------------------------------------------------------
    {
        "stevearc/overseer.nvim",
        cmd = { "OverseerOpen", "OverseerToggle", "OverseerRunCmd" },
        keys = {
            { "<leader>rp", "<cmd>OverseerToggle<cr>", desc = "Панель задач (Overseer)" },
            { "<leader>rb", "<cmd>OverseerRunCmd cargo build<cr>", desc = "Rust: собрать проект" },
            { "<leader>rt", "<cmd>OverseerRunCmd cargo test<cr>", desc = "Rust: запустить тесты" },
            { "<leader>rc", "<cmd>OverseerRunCmd cargo clippy --all-targets --all-features<cr>", desc = "Rust: проверить clippy" },
            { "<leader>rR", "<cmd>OverseerRunCmd cargo run<cr>", desc = "Rust: запустить" },
        },
        opts = {
            strategy = "toggleterm",
            templates = { "builtin" },
            task_list = {
                direction = "right",
                min_width = 42,
                max_width = 58,
                default_detail = 1,
            },
        },
    },
}
