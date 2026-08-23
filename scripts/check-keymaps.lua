local original_set = vim.keymap.set
local seen = {}
local duplicates = {}

local function modes(value)
    return type(value) == "table" and value or { value }
end

local function mapping_scope(opts)
    if not opts or opts.buffer == nil or opts.buffer == false then
        return "global"
    end
    return "buffer:" .. tostring(opts.buffer)
end

vim.keymap.set = function(mode, lhs, rhs, opts)
    for _, current_mode in ipairs(modes(mode)) do
        local key = table.concat({ current_mode, mapping_scope(opts), lhs }, "\0")
        local source = debug.getinfo(2, "S").short_src
        local current = {
            desc = opts and opts.desc or "[без описания]",
            source = source,
        }

        if seen[key] then
            duplicates[#duplicates + 1] = {
                mode = current_mode,
                lhs = lhs,
                scope = mapping_scope(opts),
                previous = seen[key],
                current = current,
            }
        else
            seen[key] = current
        end
    end

    return original_set(mode, lhs, rhs, opts)
end

local config = vim.fn.stdpath("config") .. "/init.lua"
vim.go.loadplugins = true
local ok, err = pcall(dofile, config)
vim.keymap.set = original_set

if not ok then
    error("Не удалось загрузить конфиг: " .. tostring(err))
end

if #duplicates > 0 then
    for _, duplicate in ipairs(duplicates) do
        io.stderr:write(string.format(
            "Конфликт [%s, %s] %s: %s (%s) -> %s (%s)\n",
            duplicate.mode,
            duplicate.scope,
            duplicate.lhs,
            duplicate.previous.desc,
            duplicate.previous.source,
            duplicate.current.desc,
            duplicate.current.source
        ))
    end
    vim.cmd.cquit(1)
end

print("Keymap check: конфликтов нет")
vim.cmd.quitall()
