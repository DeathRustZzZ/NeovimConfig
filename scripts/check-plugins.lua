local config = vim.fn.stdpath("config") .. "/init.lua"
vim.go.loadplugins = true
local ok, err = pcall(dofile, config)
if not ok then
    error("Не удалось загрузить конфиг: " .. tostring(err))
end

local lazy_config = require("lazy.core.config")
local loader = require("lazy.core.loader")
local plugin_names = vim.tbl_keys(lazy_config.plugins)

loader.load(plugin_names, { start = "config audit" }, { force = true })

local failures = {}
for name, plugin in pairs(lazy_config.plugins) do
    if plugin.enabled ~= false and plugin._.loaded then
        local commands = type(plugin.cmd) == "table" and plugin.cmd or { plugin.cmd }
        for _, command in ipairs(commands) do
            if type(command) == "string" and vim.fn.exists(":" .. command) ~= 2 then
                failures[#failures + 1] = ("%s: команда :%s не зарегистрирована"):format(name, command)
            end
        end
    end
end

if #failures > 0 then
    for _, failure in ipairs(failures) do
        io.stderr:write(failure .. "\n")
    end
    vim.cmd.cquit(1)
end

print(("Plugin check: загружено %d specs, команды зарегистрированы"):format(vim.tbl_count(lazy_config.plugins)))
vim.cmd.quitall()
