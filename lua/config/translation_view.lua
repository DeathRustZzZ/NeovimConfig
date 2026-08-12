local M = {}

local active_window = nil

local function as_lines(value)
    if type(value) == "table" then
        return vim.deepcopy(value)
    end
    return vim.split(tostring(value or ""), "\n", { plain = true })
end

local function section(title, value)
    local lines = { "## " .. title, "" }
    vim.list_extend(lines, as_lines(value))
    return lines
end

local function has_content(value)
    if type(value) == "table" then
        return #value > 0
    end
    return value ~= nil and tostring(value) ~= ""
end

local function wrapped_height(lines, width)
    local height = 0
    for _, line in ipairs(lines) do
        height = height + math.max(1, math.ceil(vim.fn.strdisplaywidth(line) / math.max(width - 2, 1)))
    end
    return height
end

local function close_active()
    if active_window and vim.api.nvim_win_is_valid(active_window) then
        vim.api.nvim_win_close(active_window, true)
    end
    active_window = nil
end

function M.open(original, translated, opts)
    opts = opts or {}
    close_active()

    local lines = {}
    if opts.original_first then
        vim.list_extend(lines, section(opts.original_title or "Оригинал", original))
        vim.list_extend(lines, { "", "---", "" })
        vim.list_extend(lines, section(opts.translation_title or "Перевод", translated))
    else
        vim.list_extend(lines, section(opts.translation_title or "Перевод", translated))
        if has_content(original) then
            vim.list_extend(lines, { "", "---", "" })
            vim.list_extend(lines, section(opts.original_title or "Оригинал", original))
        end
    end

    local max_width = math.max(vim.o.columns - 4, 1)
    local width = math.min(math.max(math.floor(vim.o.columns * 0.75), 30), max_width)
    local max_height = math.max(vim.o.lines - vim.o.cmdheight - 4, 1)
    local height = math.min(math.max(wrapped_height(lines, width), 3), math.floor(max_height * 0.8))
    height = math.max(math.min(height, max_height), 1)

    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.bo[bufnr].buftype = "nofile"
    vim.bo[bufnr].bufhidden = "wipe"
    vim.bo[bufnr].swapfile = false
    vim.bo[bufnr].filetype = "markdown"
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
    vim.bo[bufnr].modifiable = false

    active_window = vim.api.nvim_open_win(bufnr, true, {
        relative = "editor",
        row = math.max(math.floor((vim.o.lines - height) / 2) - 1, 0),
        col = math.max(math.floor((vim.o.columns - width) / 2), 0),
        width = width,
        height = height,
        style = "minimal",
        border = "rounded",
        title = opts.title or " Перевод ",
        title_pos = "center",
    })

    vim.wo[active_window].wrap = true
    vim.wo[active_window].linebreak = true
    vim.wo[active_window].conceallevel = 2

    local close = function()
        close_active()
    end
    vim.keymap.set("n", "q", close, { buffer = bufnr, silent = true, desc = "Закрыть перевод" })
    vim.keymap.set("n", "<Esc>", close, { buffer = bufnr, silent = true, desc = "Закрыть перевод" })

    return bufnr, active_window
end

return M
