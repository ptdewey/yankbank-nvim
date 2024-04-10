-- helpers.lua
local M = {}

-- navigate to the next numbered item
---@param steps integer
function M.next_numbered_item(steps)
    steps = steps or 1 -- Default to 1 if no steps are provided
    local current_line = vim.api.nvim_win_get_cursor(0)[1]
    local total_lines = vim.api.nvim_buf_line_count(0)
    local jumps_made = 0
    local last_entry = current_line
    for i = current_line + 1, total_lines do
        local line = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]
        if line:match("^%s*%d+:") and jumps_made < steps then
            jumps_made = jumps_made + 1
            last_entry = i
            if jumps_made == steps then
                vim.api.nvim_win_set_cursor(0, { i, 0 })
                return
            end
        end
    end
    -- if steps exceeds number of entries below, jump to last entry
    vim.api.nvim_win_set_cursor(0, { last_entry, 0 })
end

-- navigate to the previous numbered item
---@param steps integer
function M.prev_numbered_item(steps)
    steps = steps or 1 -- Default to 1 if no steps are provided
    local current_line = vim.api.nvim_win_get_cursor(0)[1]
    local jumps_made = 0
    for i = current_line - 1, 1, -1 do
        local line = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]
        if line:match("^%s*%d+:") and jumps_made < steps then
            jumps_made = jumps_made + 1
            if jumps_made == steps then
                vim.api.nvim_win_set_cursor(0, { i, 0 })
                return
            end
        end
    end
    -- if steps exceeds the number of entries above, jump to first entry.
    vim.api.nvim_win_set_cursor(0, { 1, 0 })
end

-- customized paste function that functions like 'p'
---@param text string
---@param reg_type string
function M.smart_paste(text, reg_type)
    -- convert text string to string list
    local lines = {}
    for line in text:gmatch("([^\n]*)\n?") do
        table.insert(lines, line)
    end

    -- remove last newline character to replicate base put behavior
    if #lines > 1 then
        table.remove(lines)
    end
    vim.api.nvim_put(lines, reg_type, true, true)
end

return M
