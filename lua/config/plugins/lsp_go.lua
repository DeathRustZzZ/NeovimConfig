local function go_cmd(command, missing)
    return function()
        local cmd_name = command:match("^(%S+)")
        if cmd_name and vim.fn.exists(":" .. cmd_name) == 2 then
            vim.cmd(command)
            return
        end
        vim.notify(missing or ("Команда :" .. command .. " недоступна"), vim.log.levels.WARN)
    end
end

return {
    -- --------------------------------------------------------
    -- Go IDE support: gopls + go.nvim utilities without taking over LSP/formatting.
    -- --------------------------------------------------------
    {
        "ray-x/go.nvim",
        ft = { "go", "gomod", "gowork", "gosum" },
        dependencies = {
            "ray-x/guihua.lua",
            "neovim/nvim-lspconfig",
            "nvim-treesitter/nvim-treesitter",
            "mfussenegger/nvim-dap",
        },
        cmd = {
            "GoTest",
            "GoTestFunc",
            "GoTestFile",
            "GoTestPkg",
            "GoCoverage",
            "GoGenerate",
            "GoVet",
            "GoModTidy",
            "GoImports",
            "GoFillStruct",
            "GoImpl",
            "GoAddTag",
            "GoRmTag",
            "GoCodeAction",
        },
        keys = {
            { "<leader>Gt", go_cmd("GoTest"), desc = "Go: test ./..." },
            { "<leader>Gn", go_cmd("GoTestFunc"), desc = "Go: тест текущей функции" },
            { "<leader>Gf", go_cmd("GoTestFile"), desc = "Go: тест текущего файла" },
            { "<leader>Gp", go_cmd("GoTestPkg"), desc = "Go: тест пакета" },
            { "<leader>Gb", go_cmd("GoTest -bench=."), desc = "Go: benchmarks" },
            { "<leader>Gc", go_cmd("GoCoverage"), desc = "Go: coverage" },
            { "<leader>GG", go_cmd("GoGenerate"), desc = "Go: generate" },
            { "<leader>Gv", go_cmd("GoVet"), desc = "Go: vet" },
            { "<leader>Gm", go_cmd("GoModTidy"), desc = "Go: mod tidy" },
            { "<leader>Gi", go_cmd("GoImports"), desc = "Go: organize imports" },
            { "<leader>Gs", go_cmd("GoFillStruct"), desc = "Go: fill struct" },
            { "<leader>GI", go_cmd("GoImpl"), desc = "Go: implement interface" },
            { "<leader>Ga", go_cmd("GoAddTag"), desc = "Go: add tags" },
            { "<leader>GA", go_cmd("GoRmTag"), desc = "Go: remove tags" },
        },
        config = function()
            require("go").setup({
                go = "go",
                gofmt = "gofmt",
                goimports = "goimports",
                fillstruct = "gopls",
                tag_transform = "snakecase",
                test_runner = "go",
                run_in_floaterm = false,
                lsp_cfg = false,
                lsp_keymaps = false,
                lsp_inlay_hints = { enable = false },
                lsp_format_on_save = false,
                luasnip = false,
                dap_debug = false,
                trouble = true,
            })
        end,
    },
}
