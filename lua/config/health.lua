local M = {}

local function executable(name, purpose, required)
    local path = vim.fn.exepath(name)
    if path ~= "" then
        vim.health.ok(("%s: %s"):format(name, path))
    elseif required then
        vim.health.error(("%s не найден (%s)"):format(name, purpose))
    else
        vim.health.warn(("%s не найден (%s)"):format(name, purpose))
    end
end

function M.check()
    local platform = require("config.platform")

    vim.health.start("Платформа")
    if platform.is_macos then
        vim.health.ok("macOS")
        executable("im-select", "автопереключение системной раскладки; установка описана в MACOS_M1_MIGRATION.md", false)
    elseif platform.is_linux then
        vim.health.ok("Linux")
        if tostring(vim.env.XDG_CURRENT_DESKTOP or ""):find("KDE", 1, true) then
            executable("qdbus6", "автопереключение KDE-раскладки", false)
            executable("kreadconfig6", "чтение списка KDE-раскладок", false)
        else
            vim.health.info("Автопереключение раскладки настроено только для KDE")
        end
    else
        vim.health.warn("Непроверенная операционная система")
    end

    vim.health.start("Базовые инструменты")
    executable("git", "установка и работа плагинов", true)
    executable("rg", "Telescope live_grep", true)
    executable("fd", "быстрый поиск файлов", false)
    executable("make", "сборка telescope-fzf-native", false)
    executable("lazygit", "Git UI", false)
    executable("trans", "перевод текста", false)
    executable("graphify", "knowledge graph", false)
    executable("codex", "Sidekick/Codex", false)
    executable("tmux", "сохранение Sidekick-сессий между перезапусками", false)

    vim.health.start("Языковые инструменты")
    executable("tree-sitter", "установка Treesitter-парсеров", true)
    executable("rust-analyzer", "Rust LSP", false)
    executable("cargo", "Rust build/test", false)
    executable("gopls", "Go LSP", false)
    executable("goimports", "Go formatting/imports", false)
    executable("dlv", "Go debugging", false)
    executable("taplo", "TOML LSP/formatting", false)
    executable("stylua", "Lua formatting", false)
    executable("codelldb", "Rust debugging", false)

    local expected = {
        "rust", "toml", "lua", "vim", "vimdoc", "query", "json", "yaml",
        "markdown", "markdown_inline", "go", "gomod", "gosum", "gowork", "bash",
        "javascript", "typescript",
    }
    local ok, installed = pcall(function() return require("nvim-treesitter").get_installed() end)
    if ok then
        local present = {}
        for _, language in ipairs(installed) do
            present[language] = true
        end
        local missing = vim.tbl_filter(function(language) return not present[language] end, expected)
        if #missing == 0 then
            vim.health.ok("Все настроенные Treesitter-парсеры установлены")
        else
            vim.health.error("Отсутствуют Treesitter-парсеры: " .. table.concat(missing, ", "))
        end
    else
        vim.health.error("Не удалось прочитать список Treesitter-парсеров: " .. tostring(installed))
    end
end

return M
