-- menu.lua
local M = {}

-- import clipboard functions
local clipboard = require("yankbank.clipboard")
local data = require("yankbank.data")
local helpers = require("yankbank.helpers")

-- create new buffer and reformat yank table for ui
function M.create_and_fill_buffer(yanks, max_entries)
    -- check the content of the system clipboard register
    -- TODO: this could be replaced with some sort of polling of the + register
    local text = vim.fn.getreg('+')
    local most_recent_yank = yanks[1] or ""
    if text ~= most_recent_yank then
        clipboard.add_yank(yanks, text, max_entries)
    end

    -- stop if yank table is empty
    if #yanks == 0 then
        print("No yanks to show.")
        return
    end

    -- create new buffer
    local bufnr = vim.api.nvim_create_buf(false, true)

    -- set buffer type same as current window for syntax highlighting
    local current_filetype = vim.bo.filetype
    vim.api.nvim_buf_set_option(bufnr, 'filetype', current_filetype)

    local display_lines, line_yank_map = data.get_display_lines(yanks)

    -- replace current buffer contents with updated table
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, display_lines)

    return bufnr, display_lines, line_yank_map
end

-- Calculate size and create popup window from bufnr
function M.open_window(bufnr, display_lines)
    -- set maximum window width based on number of lines
    local max_width = 0
    for _, line in ipairs(display_lines) do
        max_width = math.max(max_width, #line)
    end

    -- define buffer window width and height based on number of columns
    local width = math.min(max_width + 4, vim.api.nvim_get_option("columns") - 50)
    local height = math.min(#display_lines, vim.api.nvim_get_option("lines") - 4)

    -- open window
    local win_id = vim.api.nvim_open_win(bufnr, true, {
        relative = "editor",
        width = width,
        height = height,
        col = math.floor((vim.api.nvim_get_option("columns") - width) / 2 - 1),
        row = math.floor((vim.api.nvim_get_option("lines") - height) / 2 - 1),
        border = "rounded",
        style = "minimal",
    })

    -- Highlight current line
    vim.api.nvim_win_set_option(win_id, 'cursorline', true)

    return win_id
end

-- Set key mappings for the popup window
-- TODO: configurable options (take in inside setup function)
function M.set_keymaps(win_id, bufnr, yanks, line_yank_map)
    -- Key mappings for selection and closing the popup
    local map_opts = { noremap = true, silent = true, buffer = bufnr }

    -- popup buffer navigation binds
    vim.keymap.set('n', 'j', helpers.next_numbered_item,
        { noremap = true, silent = true, buffer = bufnr })
    vim.keymap.set('n', 'k', helpers.prev_numbered_item,
        { noremap = true, silent = true, buffer = bufnr })

    -- bind paste behavior to enter
    vim.keymap.set('n', '<CR>', function()
        local cursor = vim.api.nvim_win_get_cursor(win_id)[1]
        -- use the mapping to find the original yank
        local yankIndex = line_yank_map[cursor]
        if yankIndex then
            -- retrieve the full yank, including all lines
            local text = yanks[yankIndex]

            -- close window upon selection
            vim.api.nvim_win_close(win_id, true)

            -- call the custom paste function with adjusted indentation
            print(vim.fn.getregtype())
            -- vim.api.nvim_paste(text, false, -1)
            helpers.smart_paste(text)
        else
            print("Error: Invalid selection")
        end
    end, { buffer = bufnr })

    -- close popup keybinds
    local close_maps = { "<Esc>", "<C-c>", "q" }
    for _, map in ipairs(close_maps) do
        vim.keymap.set('n', map, function()
            vim.api.nvim_win_close(win_id, true)
        end, map_opts)
    end
end

return M
