local M = {}

M.presets = {
    glass = {
        transparent = true,
        normal_bg = "NONE",
        winblend = 10,
        pumblend = 10,
        float_bg = "NONE",
        float_border = "#cba6f7",
        cursorline = "#313244",
        visual = "#45475a",
        context_bg = "#1e1e2e",
        indent = "#45475a",
        indent_scope = "#cba6f7",
    },
    solid = {
        transparent = false,
        normal_bg = "#1e1e2e",
        winblend = 0,
        pumblend = 0,
        float_bg = "#1e1e2e",
        float_border = "#89b4fa",
        cursorline = "#313244",
        visual = "#585b70",
        context_bg = "#181825",
        indent = "#313244",
        indent_scope = "#89b4fa",
    },
    high_contrast = {
        transparent = false,
        normal_bg = "#11111b",
        winblend = 0,
        pumblend = 0,
        float_bg = "#11111b",
        float_border = "#f9e2af",
        cursorline = "#3a3f58",
        visual = "#585b70",
        context_bg = "#0f1017",
        indent = "#3c3f56",
        indent_scope = "#f9e2af",
    },
}

local order = { "glass", "solid", "high_contrast" }

local function current_name()
    if M.presets[vim.g.user_ui_preset] then
        return vim.g.user_ui_preset
    end
    vim.g.user_ui_preset = "glass"
    return "glass"
end

function M.current()
    return M.presets[current_name()]
end

function M.is_transparent()
    return M.current().transparent
end

function M.apply_options()
    local preset = M.current()
    vim.opt.winblend = preset.winblend
    vim.opt.pumblend = preset.pumblend
end

function M.apply_highlights()
    local preset = M.current()
    vim.api.nvim_set_hl(0, "Normal", { bg = preset.normal_bg })
    vim.api.nvim_set_hl(0, "NormalNC", { bg = preset.normal_bg })
    vim.api.nvim_set_hl(0, "SignColumn", { bg = preset.normal_bg })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = preset.float_bg })
    vim.api.nvim_set_hl(0, "FloatBorder", { fg = preset.float_border, bg = preset.float_bg })
    vim.api.nvim_set_hl(0, "CursorLine", { bg = preset.cursorline })
    vim.api.nvim_set_hl(0, "Visual", { bg = preset.visual })
    vim.api.nvim_set_hl(0, "TreesitterContext", { bg = preset.context_bg })
    vim.api.nvim_set_hl(0, "TreesitterContextLineNumber", { fg = preset.float_border, bg = preset.context_bg })
    vim.api.nvim_set_hl(0, "IblIndent", { fg = preset.indent, nocombine = true })
    vim.api.nvim_set_hl(0, "IblScope", { fg = preset.indent_scope, nocombine = true })
    vim.api.nvim_set_hl(0, "RainbowDelimiterRed", { fg = "#f38ba8", nocombine = true })
    vim.api.nvim_set_hl(0, "RainbowDelimiterYellow", { fg = "#f9e2af", nocombine = true })
    vim.api.nvim_set_hl(0, "RainbowDelimiterBlue", { fg = "#89b4fa", nocombine = true })
    vim.api.nvim_set_hl(0, "RainbowDelimiterOrange", { fg = "#fab387", nocombine = true })
    vim.api.nvim_set_hl(0, "RainbowDelimiterGreen", { fg = "#a6e3a1", nocombine = true })
    vim.api.nvim_set_hl(0, "RainbowDelimiterViolet", { fg = "#cba6f7", nocombine = true })
    vim.api.nvim_set_hl(0, "RainbowDelimiterCyan", { fg = "#94e2d5", nocombine = true })
end

function M.notify_options()
    local bg = M.current().float_bg
    return {
        timeout = 2500,
        background_colour = bg == "NONE" and "#1e1e2e" or bg,
        render = "wrapped-compact",
        stages = "slide",
    }
end

function M.reload_colors()
    M.apply_options()
    pcall(vim.cmd.colorscheme, "catppuccin")
    M.apply_highlights()
    if package.loaded.notify then
        require("notify").setup(M.notify_options())
    end
end

function M.set_preset(name)
    if not M.presets[name] then
        return
    end
    vim.g.user_ui_preset = name
    M.reload_colors()
    vim.notify("UI preset: " .. name, vim.log.levels.INFO)
end

function M.cycle_preset()
    local name = current_name()
    local idx = 1
    for i, preset_name in ipairs(order) do
        if preset_name == name then
            idx = i
            break
        end
    end
    local next_name = order[(idx % #order) + 1]
    M.set_preset(next_name)
end

return M
