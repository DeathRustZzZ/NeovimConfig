local M = {}

local state = {
    enabled = false,
    qdbus = nil,
    english_index = nil,
    russian_indices = {},
    restore_index = nil,
}

local function command_output(cmd, timeout_ms)
    -- Используем vim.system без shell, чтобы D-Bus вызовы были быстрыми и безопасными для автокоманд.
    if vim.system then
        local ok, obj = pcall(vim.system, cmd, { text = true })
        if not ok then
            return nil
        end

        local result = obj:wait(timeout_ms or 100)
        if not result or result.code == nil then
            pcall(function()
                obj:kill(15)
            end)
            return nil
        end

        if result.code ~= 0 then
            return nil
        end

        return result.stdout or ""
    end

    -- Fallback для старых версий Neovim, где vim.system ещё недоступен.
    local output = vim.fn.system(cmd)
    if vim.v.shell_error ~= 0 then
        return nil
    end

    return output
end

local function split_csv(value)
    local result = {}
    for item in tostring(value or ""):gmatch("[^,]+") do
        result[#result + 1] = vim.trim(item)
    end
    return result
end

local function detect_layouts()
    -- KDE хранит порядок XKB-раскладок в kxkbrc; D-Bus setLayout работает с нулевыми индексами.
    local output = command_output({
        "kreadconfig6",
        "--file",
        "kxkbrc",
        "--group",
        "Layout",
        "--key",
        "LayoutList",
    })

    local layouts = split_csv(output)
    if #layouts == 0 then
        return false
    end

    for index, layout in ipairs(layouts) do
        local dbus_index = index - 1
        if layout == "us" then
            state.english_index = dbus_index
        elseif layout == "ru" then
            state.russian_indices[dbus_index] = true
        end
    end

    return state.english_index ~= nil and next(state.russian_indices) ~= nil
end

local function get_layout()
    local output = command_output({
        state.qdbus,
        "org.kde.keyboard",
        "/Layouts",
        "org.kde.KeyboardLayouts.getLayout",
    })

    return output and tonumber(vim.trim(output)) or nil
end

local function set_layout(index)
    if index == nil then
        return
    end

    -- Ошибки D-Bus намеренно глушим: переключение раскладки не должно спамить уведомлениями.
    command_output({
        state.qdbus,
        "org.kde.keyboard",
        "/Layouts",
        "org.kde.KeyboardLayouts.setLayout",
        tostring(index),
    })
end

local function leave_input_mode()
    local current_index = get_layout()
    state.restore_index = state.russian_indices[current_index] and current_index or nil
    set_layout(state.english_index)
end

local function enter_input_mode()
    if state.restore_index then
        set_layout(state.restore_index)
    end
end

local function is_input_mode(mode)
    -- Обрабатываем Insert, Replace и Virtual Replace без CursorMoved/polling.
    return mode:sub(1, 1) == "i" or mode:sub(1, 1) == "R"
end

function M.setup()
    -- В этой системе раскладкой управляет KDE/XKB, а не fcitx5 или ibus.
    if not tostring(vim.env.XDG_CURRENT_DESKTOP or ""):find("KDE", 1, true) then
        return
    end

    state.qdbus = vim.fn.exepath("qdbus6")
    if state.qdbus == "" or vim.fn.executable("kreadconfig6") ~= 1 or not detect_layouts() then
        return
    end

    state.enabled = true

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

    -- При старте Neovim находится в Normal Mode, поэтому сразу приводим раскладку к английской.
    set_layout(state.english_index)
end

return M
