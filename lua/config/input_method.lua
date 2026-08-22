local M = {}
local platform = require("config.platform")

local state = {
    backend = nil,
    english = nil,
    russian = {},
    restore = nil,
    transition = 0,
}

local function command_output(cmd, callback)
    local ok = pcall(vim.system, cmd, { text = true }, function(result)
        vim.schedule(function()
            callback(result.code == 0 and vim.trim(result.stdout or "") or nil)
        end)
    end)
    if not ok then
        vim.schedule(function() callback(nil) end)
    end
end

local function split_csv(value)
    local result = {}
    for item in tostring(value or ""):gmatch("[^,]+") do
        result[#result + 1] = vim.trim(item)
    end
    return result
end

local function setup_kde(callback)
    local qdbus = vim.fn.exepath("qdbus6")
    if qdbus == "" or vim.fn.executable("kreadconfig6") ~= 1 then
        callback(false)
        return
    end

    command_output({
        "kreadconfig6", "--file", "kxkbrc", "--group", "Layout", "--key", "LayoutList",
    }, function(output)
        local layouts = split_csv(output)
        for index, layout in ipairs(layouts) do
            local dbus_index = tostring(index - 1)
            if layout == "us" then
                state.english = dbus_index
            elseif layout == "ru" then
                state.russian[dbus_index] = true
            end
        end

        if not state.english or not next(state.russian) then
            callback(false)
            return
        end

        state.backend = {
            get = function(done)
                command_output({ qdbus, "org.kde.keyboard", "/Layouts", "org.kde.KeyboardLayouts.getLayout" }, done)
            end,
            set = function(layout)
                command_output({ qdbus, "org.kde.keyboard", "/Layouts", "org.kde.KeyboardLayouts.setLayout", layout }, function() end)
            end,
        }
        callback(true)
    end)
end

local function is_macos_english(source)
    return source == "com.apple.keylayout.ABC"
        or source == "com.apple.keylayout.US"
        or source == "com.apple.keylayout.USInternational-PC"
end

local function setup_macos(callback)
    local im_select = vim.fn.exepath("im-select")
    if im_select == "" then
        callback(false)
        return
    end

    state.english = vim.env.NVIM_ENGLISH_INPUT_SOURCE or "com.apple.keylayout.ABC"
    state.backend = {
        get = function(done)
            command_output({ im_select }, done)
        end,
        set = function(layout)
            command_output({ im_select, layout }, function() end)
        end,
    }

    state.russian = setmetatable({}, {
        __index = function(_, source)
            return source ~= nil and source ~= "" and not is_macos_english(source)
        end,
    })
    callback(true)
end

local function leave_input_mode()
    state.transition = state.transition + 1
    local transition = state.transition

    state.backend.get(function(current)
        if transition ~= state.transition then
            return
        end
        state.restore = state.russian[current] and current or nil
        state.backend.set(state.english)
    end)
end

local function enter_input_mode()
    state.transition = state.transition + 1
    if state.restore then
        state.backend.set(state.restore)
    end
end

local function is_input_mode(mode)
    return mode:sub(1, 1) == "i" or mode:sub(1, 1) == "R"
end

local function enable_autocmds()
    local group = vim.api.nvim_create_augroup("UserInputMethodLayout", { clear = true })
    vim.api.nvim_create_autocmd("ModeChanged", {
        group = group,
        pattern = "*",
        callback = function()
            local old_mode = vim.v.event.old_mode or ""
            local new_mode = vim.v.event.new_mode or ""
            local was_input = is_input_mode(old_mode)
            local is_input = is_input_mode(new_mode)

            if was_input and not is_input then
                leave_input_mode()
            elseif not was_input and is_input then
                enter_input_mode()
            end
        end,
    })

    state.backend.set(state.english)
end

function M.setup()
    local setup_backend
    if platform.is_macos then
        setup_backend = setup_macos
    elseif tostring(vim.env.XDG_CURRENT_DESKTOP or ""):find("KDE", 1, true) then
        setup_backend = setup_kde
    else
        return
    end

    setup_backend(function(found)
        if found then
            enable_autocmds()
        end
    end)
end

return M
