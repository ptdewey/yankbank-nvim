local M = {}

local state = require("yankbank.state")

-- default plugin keymaps
local default_keymaps = {
    navigation_next = "j",
    navigation_prev = "k",
    paste = "<CR>",
    paste_back = "P",
    yank = "yy",
    close = { "<Esc>", "<C-c>", "q" },
}

-- define default yank register
local default_registers = {
    yank_register = "+",
}

function M.setup()
    local opts = state.get_opts()
    -- merge default and options keymap tables
    opts.keymaps =
        vim.tbl_deep_extend("force", default_keymaps, opts.keymaps or {})
    -- merge default and options register tables
    opts.registers =
        vim.tbl_deep_extend("force", default_registers, opts.registers or {})

    -- check table for number behavior option (prefix or jump, default to prefix)
    opts.num_behavior = opts.num_behavior or "prefix"

    state.set_opts(opts)
end

--- reformat yanks table for popup
---@return table, table
local function get_display_lines()
    local display_lines = {}
    local line_yank_map = {}
    local yank_num = 0

    local yanks = state.get_yanks()
    local opts = state.get_opts()

    -- calculate the maximum width needed for the yank numbers
    local max_digits = #tostring(#yanks)

    -- assumes yanks is table of strings
    for i, yank in ipairs(yanks) do
        yank_num = yank_num + 1

        local yank_lines = yank
        if type(yank) == "string" then
            -- remove trailing newlines
            yank = yank:gsub("\n$", "")
            yank_lines = vim.split(yank, "\n", { plain = true })
        end

        local leading_space, leading_space_length

        -- determine the number of leading whitespaces on the first line
        if #yank_lines > 0 then
            leading_space = yank_lines[1]:match("^(%s*)")
            leading_space_length = #leading_space
        end

        for j, line in ipairs(yank_lines) do
            if j == 1 then
                -- Format the line number with uniform spacing
                local lineNumber =
                    string.format("%" .. max_digits .. "d: ", yank_num)
                line = line:sub(leading_space_length + 1)
                table.insert(display_lines, lineNumber .. line)
            else
                -- Remove the same amount of leading whitespace as on the first line
                line = line:sub(leading_space_length + 1)
                -- Use spaces equal to the line number's reserved space to align subsequent lines
                table.insert(
                    display_lines,
                    string.rep(" ", max_digits + 2) .. line
                )
            end
            table.insert(line_yank_map, i)
        end

        if i < #yanks then
            -- Add a visual separator between yanks, aligned with the yank content
            if opts.sep ~= "" then
                table.insert(
                    display_lines,
                    string.rep(" ", max_digits + 2) .. opts.sep
                )
            end
            table.insert(line_yank_map, false)
        end
    end

    return display_lines, line_yank_map
end

--- Container class for YankBank buffer related variables
---@class YankBankBufData
---@field bufnr integer
---@field display_lines table
---@field line_yank_map table
---@field win_id integer

---create new buffer and reformat yank table for ui
---@return YankBankBufData?
function M.create_and_fill_buffer()
    -- stop if yanks or register types table is empty
    local yanks = state.get_yanks()
    local reg_types = state.get_reg_types()
    if #yanks == 0 or #reg_types == 0 then
        print("No yanks to show.")
        return nil
    end

    -- create new buffer
    local bufnr = vim.api.nvim_create_buf(false, true)

    -- set buffer type same as current window for syntax highlighting
    local current_filetype = vim.bo.filetype
    vim.api.nvim_set_option_value("filetype", current_filetype, { buf = bufnr })

    local display_lines, line_yank_map = get_display_lines()

    -- replace current buffer contents with updated table
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, display_lines)

    ---@type YankBankBufData
    return {
        bufnr = bufnr,
        display_lines = display_lines,
        line_yank_map = line_yank_map,
        win_id = -1,
    }
end

---Calculate size and create popup window from bufnr
---@param b YankBankBufData
---@return integer
function M.open_window(b)
    -- set maximum window width based on number of lines
    local max_width = 0
    if b.display_lines and #b.display_lines > 0 then
        for _, line in ipairs(b.display_lines) do
            max_width = math.max(max_width, #line)
        end
    else
        max_width = vim.api.nvim_get_option_value("columns", {})
    end

    -- define buffer window width and height based on number of columns
    -- FIX: long enough entries will cause window to go below end of screen
    -- FIX: wrapping long lines will cause entries below to not show in menu (requires scrolling to see)
    local width =
        math.min(max_width, vim.api.nvim_get_option_value("columns", {}) - 4)
    local height = math.min(
        b.display_lines and #b.display_lines or 1,
        vim.api.nvim_get_option_value("lines", {}) - 10
    )

    -- open window
    local win_id = vim.api.nvim_open_win(b.bufnr, true, {
        relative = "editor",
        width = width,
        height = height,
        col = math.floor(
            (vim.api.nvim_get_option_value("columns", {}) - width) / 2
        ),
        row = math.floor(
            (vim.api.nvim_get_option_value("lines", {}) - height) / 2
        ),
        border = "rounded",
        style = "minimal",
    })

    -- Highlight current line
    vim.api.nvim_set_option_value("cursorline", true, { win = win_id })

    return win_id
end

--- Set key mappings for the popup window
---@param b YankBankBufData
function M.set_keymaps(b)
    -- key mappings for selection and closing the popup
    local map_opts = { noremap = true, silent = true, buffer = b.bufnr }
    local opts = state.get_opts()

    local helpers = require("yankbank.helpers")

    -- popup buffer navigation binds
    if opts.num_behavior == "prefix" then
        vim.keymap.set("n", opts.keymaps.navigation_next, function()
            local count = vim.v.count1 > 0 and vim.v.count1 or 1
            helpers.next_numbered_item(count)
            return ""
        end, { noremap = true, silent = true, buffer = b.bufnr })
        vim.keymap.set("n", opts.keymaps.navigation_prev, function()
            local count = vim.v.count1 > 0 and vim.v.count1 or 1
            helpers.prev_numbered_item(count)
            return ""
        end, map_opts)
    else
        vim.keymap.set(
            "n",
            opts.keymaps.navigation_next,
            helpers.next_numbered_item,
            map_opts
        )
        vim.keymap.set(
            "n",
            opts.keymaps.navigation_prev,
            helpers.prev_numbered_item,
            map_opts
        )
    end

    -- map number keys to jump to entry if num_behavior is 'jump'
    if opts.num_behavior == "jump" then
        for i = 1, opts.max_entries do
            vim.keymap.set("n", tostring(i), function()
                local target_line = nil
                for line_num, yank_num in pairs(b.line_yank_map) do
                    if yank_num == i then
                        target_line = line_num
                        break
                    end
                end
                if target_line then
                    vim.api.nvim_win_set_cursor(b.win_id, { target_line, 0 })
                end
            end, map_opts)
        end
    end

    -- bind paste behavior
    vim.keymap.set("n", opts.keymaps.paste, function()
        local cursor = vim.api.nvim_win_get_cursor(b.win_id)[1]
        -- use the mapping to find the original yank
        local yankIndex = b.line_yank_map[cursor]
        if yankIndex then
            -- close window upon selection
            vim.api.nvim_win_close(b.win_id, true)
            helpers.smart_paste(
                state.get_yanks()[yankIndex],
                state.get_reg_types()[yankIndex],
                true
            )
        else
            print("Error: Invalid selection")
        end
    end, map_opts)
    -- paste backwards
    vim.keymap.set("n", opts.keymaps.paste_back, function()
        local cursor = vim.api.nvim_win_get_cursor(b.win_id)[1]
        -- use the mapping to find the original yank
        local yankIndex = b.line_yank_map[cursor]
        if yankIndex then
            -- close window upon selection
            vim.api.nvim_win_close(b.win_id, true)
            helpers.smart_paste(
                state.get_yanks()[yankIndex],
                state.get_reg_types()[yankIndex],
                false
            )
        else
            print("Error: Invalid selection")
        end
    end, map_opts)

    -- bind yank behavior
    vim.keymap.set("n", opts.keymaps.yank, function()
        local cursor = vim.api.nvim_win_get_cursor(b.win_id)[1]
        local yankIndex = b.line_yank_map[cursor]
        if yankIndex then
            vim.fn.setreg(
                opts.registers.yank_register,
                state.get_yanks()[yankIndex]
            )
            vim.api.nvim_win_close(b.win_id, true)
        end
    end, map_opts)

    -- close popup keybinds
    -- REFACTOR: check if close keybind is string, handle differently
    for _, map in ipairs(opts.keymaps.close) do
        vim.keymap.set("n", map, function()
            vim.api.nvim_win_close(b.win_id, true)
        end, map_opts)
    end
end

return M
