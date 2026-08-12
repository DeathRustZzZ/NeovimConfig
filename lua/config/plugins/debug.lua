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
    },

    -- --------------------------------------------------------
    -- DAP core: отладка (breakpoints/continue/step)
    -- Hotkeys: <leader>db/<leader>dc/<leader>di/<leader>do/<leader>dO
    -- --------------------------------------------------------
    {
        "mfussenegger/nvim-dap",
        keys = {
            { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "DAP: переключить брейкпоинт" },
            {
                "<leader>dB",
                function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end,
                desc = "DAP: условный брейкпоинт",
            },
            { "<leader>dc", function() require("dap").continue() end, desc = "DAP: продолжить" },
            { "<leader>di", function() require("dap").step_into() end, desc = "DAP: шаг внутрь" },
            { "<leader>do", function() require("dap").step_over() end, desc = "DAP: шаг через" },
            { "<leader>dO", function() require("dap").step_out() end, desc = "DAP: шаг наружу" },
            { "<leader>dr", function() require("dap").repl.toggle() end, desc = "DAP: REPL" },
        },
    },

    -- --------------------------------------------------------
    -- DAP UI: окна стека/переменных/консоли для дебага
    -- Hotkeys: <leader>du
    -- --------------------------------------------------------
    {
        "leoluz/nvim-dap-go",
        ft = { "go" },
        dependencies = { "mfussenegger/nvim-dap" },
        config = function()
            require("dap-go").setup({
                delve = {
                    detached = vim.fn.has("win32") == 0,
                },
            })
        end,
    },

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
    -- Rust adapter берём из rustaceanvim, чтобы не дублировать интеграцию с rust-analyzer.
    -- Hotkeys: <leader>tn/<leader>tf/<leader>ts/<leader>to
    -- --------------------------------------------------------
    {
        "nvim-neotest/neotest",
        dependencies = {
            "nvim-neotest/nvim-nio",
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            "fredrikaverpil/neotest-golang",
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
                    require("rustaceanvim.neotest"),
                    require("neotest-golang")({
                        go_test_args = { "-v", "-race", "-count=1", "-timeout=60s" },
                        dap_go_enabled = true,
                    }),
                },
            })
        end,
    },
}
