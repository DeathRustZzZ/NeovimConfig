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

local function client_supports_inlay_hints(client)
    if not client then return false end
    if client.supports_method then
        return client:supports_method("textDocument/inlayHint")
    end
    return client.server_capabilities and client.server_capabilities.inlayHintProvider
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
            { "<leader>GR", vim.lsp.buf.rename, desc = "Go: rename" },
            {
                "<leader>Gh",
                function()
                    local bufnr = vim.api.nvim_get_current_buf()
                    set_inlay_hints(bufnr, not inlay_hints_enabled(bufnr))
                end,
                desc = "Go: inlay hints",
            },
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
                lsp_inlay_hints = { enable = true },
                lsp_format_on_save = false,
                luasnip = false,
                dap_debug = false,
                trouble = true,
            })

            local go_hints_group = vim.api.nvim_create_augroup("UserGoInlayHints", { clear = true })
            vim.api.nvim_create_autocmd("LspAttach", {
                group = go_hints_group,
                callback = function(args)
                    if vim.bo[args.buf].filetype ~= "go" then return end

                    local client = vim.lsp.get_client_by_id(args.data.client_id)
                    if not client_supports_inlay_hints(client) then return end

                    set_inlay_hints(args.buf, true)
                    vim.keymap.set("n", "<leader>Gh", function()
                        set_inlay_hints(args.buf, not inlay_hints_enabled(args.buf))
                    end, { buffer = args.buf, desc = "Go: inlay hints" })
                end,
            })
        end,
    },
}
