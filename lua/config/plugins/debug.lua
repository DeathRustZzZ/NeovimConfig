return {
    -- --------------------------------------------------------
    -- RustOwl: подсказки по ownership/lifetimes прямо в коде
    -- --------------------------------------------------------
    {
        "cordx56/rustowl",
        ft = { "rust" },
        cond = function()
            local path = vim.fn.exepath("rustowl")
            return path ~= nil and path ~= ""
        end,
        enabled = function()
            local path = vim.fn.exepath("rustowl")
            return path ~= nil and path ~= ""
        end,
    },

    -- --------------------------------------------------------
    -- Ferris: дополнительные rust-analyzer utilities
    -- --------------------------------------------------------
    {
        "vxpm/ferris.nvim",
        ft = { "rust" },
        opts = {},
    },

    -- --------------------------------------------------------
    -- Go DAP: запуск программ и отладка Go-тестов через Delve.
    -- Общие breakpoint/continue/step клавиши находятся в nvim-dap ниже.
    -- --------------------------------------------------------
    {
        "leoluz/nvim-dap-go",
        ft = { "go" },
        dependencies = { "mfussenegger/nvim-dap" },
        keys = {
            {
                "<leader>dT",
                function() require("dap-go").debug_test() end,
                desc = "Go DAP: ближайший тест",
            },
            {
                "<leader>dL",
                function() require("dap-go").debug_last_test() end,
                desc = "Go DAP: повторить тест",
            },
        },
        config = function()
            local delve_path = vim.fn.exepath("dlv")
            require("dap-go").setup({
                delve = {
                    path = delve_path ~= "" and delve_path or "dlv",
                    initialize_timeout_sec = 20,
                    port = "${port}",
                    args = {},
                    build_flags = {},
                    detached = vim.fn.has("win32") == 0,
                },
                tests = {
                    verbose = true,
                },
            })
        end,
    },

    -- --------------------------------------------------------
    -- DAP core: отладка (breakpoints/continue/step)
    -- Hotkeys: <leader>db/<leader>dc/<leader>di/<leader>do/<leader>dO
    -- --------------------------------------------------------
    {
        "mfussenegger/nvim-dap",
        keys = {
            { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "DAP: переключить брейкпоинт" },
            { "<leader>dc", function() require("dap").continue() end, desc = "DAP: продолжить" },
            { "<leader>di", function() require("dap").step_into() end, desc = "DAP: шаг внутрь" },
            { "<leader>do", function() require("dap").step_over() end, desc = "DAP: шаг через" },
            { "<leader>dO", function() require("dap").step_out() end, desc = "DAP: шаг наружу" },
        },
        config = function()
            local dap = require("dap")
            local ok_registry, registry = pcall(require, "mason-registry")
            local ok_mason_settings, mason_settings = pcall(require, "mason.settings")

            if ok_registry and ok_mason_settings and registry.has_package("codelldb") then
                local codelldb_pkg = registry.get_package("codelldb")
                if not codelldb_pkg:is_installed() then return end

                local extension_path = mason_settings.current.install_root_dir .. "/packages/codelldb/extension/"
                local codelldb_path = extension_path .. "adapter/codelldb"

                dap.adapters.codelldb = {
                    type = "server",
                    port = "${port}",
                    executable = {
                        command = codelldb_path,
                        args = { "--port", "${port}" },
                    },
                }

                dap.configurations.rust = {
                    {
                        name = "Launch file",
                        type = "codelldb",
                        request = "launch",
                        program = function()
                            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
                        end,
                        cwd = "${workspaceFolder}",
                        stopOnEntry = false,
                    },
                }
            end
        end,
    },

    -- --------------------------------------------------------
    -- DAP UI: окна стека/переменных/консоли для дебага
    -- Hotkeys: <leader>du
    -- --------------------------------------------------------
    {
        "rcarriga/nvim-dap-ui",
        dependencies = {
            "mfussenegger/nvim-dap",
            "nvim-neotest/nvim-nio",
        },
        keys = {
            { "<leader>du", function() require("dapui").toggle({}) end, desc = "DAP: показать/скрыть UI" },
        },
        config = function()
            local dap = require("dap")
            local dapui = require("dapui")
            dapui.setup()

            dap.listeners.after.event_initialized["dapui_config"] = function()
                dapui.open()
            end
            dap.listeners.before.event_terminated["dapui_config"] = function()
                dapui.close()
            end
            dap.listeners.before.event_exited["dapui_config"] = function()
                dapui.close()
            end
        end,
    },

    -- --------------------------------------------------------
    -- DAP virtual text: inline значения переменных при отладке
    -- Hotkeys/commands: работает автоматически в debug-сессии
    -- --------------------------------------------------------
    {
        "theHamsta/nvim-dap-virtual-text",
        event = "VeryLazy",
        dependencies = { "mfussenegger/nvim-dap" },
        opts = {},
    },

    -- --------------------------------------------------------
    -- Neotest: запуск и просмотр тестов
    -- + Rust/Go adapters.
    -- Hotkeys: <leader>tn/<leader>tf/<leader>ta/<leader>tL/<leader>ts/<leader>to
    -- --------------------------------------------------------
    {
        "nvim-neotest/neotest",
        dependencies = {
            "nvim-neotest/nvim-nio",
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            "rouge8/neotest-rust",
            "nvim-neotest/neotest-go",
        },
        keys = {
            {
                "<leader>tn",
                function() require("neotest").run.run() end,
                desc = "Тест: ближайший",
            },
            {
                "<leader>tf",
                function() require("neotest").run.run(vim.fn.expand("%")) end,
                desc = "Тест: текущий файл",
            },
            {
                "<leader>ta",
                function()
                    local filename = vim.api.nvim_buf_get_name(0)
                    local start_dir = filename ~= "" and vim.fs.dirname(filename) or vim.fn.getcwd()
                    local root = vim.fs.root(start_dir, { "Cargo.toml", "go.work", "go.mod" })
                        or vim.fn.getcwd()
                    require("neotest").run.run(root)
                end,
                desc = "Тест: весь проект",
            },
            {
                "<leader>tL",
                function() require("neotest").run.run_last() end,
                desc = "Тест: повторить последний",
            },
            {
                "<leader>ts",
                function() require("neotest").summary.toggle() end,
                desc = "Тест: сводка",
            },
            {
                "<leader>to",
                function() require("neotest").output_panel.toggle() end,
                desc = "Тест: панель вывода",
            },
        },
        config = function()
            require("neotest").setup({
                adapters = {
                    require("neotest-rust")({}),
                    require("neotest-go")({
                        experimental = {
                            test_table = true,
                        },
                        args = { "-count=1", "-timeout=60s" },
                        recursive_run = true,
                    }),
                },
            })
        end,
    },
}
