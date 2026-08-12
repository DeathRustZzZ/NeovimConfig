local M = {}

local state = {
    qdbus = nil,
    english_index = nil,
    russian_indices = {},
    restore_index = nil,
    transition = 0,
}

local function command_output(cmd, callback)
    if vim.system then
        local ok = pcall(vim.system, cmd, { text = true }, function(result)
            vim.schedule(function()
                callback(result.code == 0 and (result.stdout or "") or nil)
            end)
        end)
        if not ok then
            vim.schedule(function() callback(nil) end)
        end
        return
    end

    local stdout = {}
    local job_id = vim.fn.jobstart(cmd, {
        stdout_buffered = true,
        on_stdout = function(_, data)
            stdout = data or {}
        end,
        on_exit = function(_, exit_code)
            vim.schedule(function()
                callback(exit_code == 0 and table.concat(stdout, "\n") or nil)
            end)
        end,
    })
    if job_id <= 0 then
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

local function detect_layouts(callback)
    -- KDE хранит порядок XKB-раскладок в kxkbrc; D-Bus setLayout работает с нулевыми индексами.
    command_output({
        "kreadconfig6",
        "--file",
        "kxkbrc",
        "--group",
        "Layout",
        "--key",
        "LayoutList",
    }, function(output)
        local layouts = split_csv(output)
        state.english_index = nil
        state.russian_indices = {}

        for index, layout in ipairs(layouts) do
            local dbus_index = index - 1
            if layout == "us" then
                state.english_index = dbus_index
            elseif layout == "ru" then
                state.russian_indices[dbus_index] = true
            end
        end

        callback(state.english_index ~= nil and next(state.russian_indices) ~= nil)
    end)
end

local function get_layout(callback)
    command_output({
        state.qdbus,
        "org.kde.keyboard",
        "/Layouts",
        "org.kde.KeyboardLayouts.getLayout",
    }, function(output)
        callback(output and tonumber(vim.trim(output)) or nil)
    end)
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
    }, function() end)
end

local function leave_input_mode()
    state.transition = state.transition + 1
    local transition = state.transition

    get_layout(function(current_index)
        if transition ~= state.transition then
            return
        end
        state.restore_index = state.russian_indices[current_index] and current_index or nil
        set_layout(state.english_index)
    end)
end

local function enter_input_mode()
    -- Инвалидируем незавершённый D-Bus запрос выхода из Insert Mode.
    state.transition = state.transition + 1
    if state.restore_index then
        set_layout(state.restore_index)
    end
end

local function is_input_mode(mode)
    -- Обрабатываем Insert, Replace и Virtual Replace без CursorMoved/polling.
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

    -- При старте Neovim находится в Normal Mode, поэтому сразу приводим раскладку к английской.
    set_layout(state.english_index)
end

function M.setup()
    -- В этой системе раскладкой управляет KDE/XKB, а не fcitx5 или ibus.
    if not tostring(vim.env.XDG_CURRENT_DESKTOP or ""):find("KDE", 1, true) then
        return
    end

    state.qdbus = vim.fn.exepath("qdbus6")
    if state.qdbus == "" or vim.fn.executable("kreadconfig6") ~= 1 then
        return
    end

    detect_layouts(function(found)
        if found then
            enable_autocmds()
        end
    end)
end

return M
