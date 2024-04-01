-- helpers.lua
local M = {}

-- navigate to the next numbered item
function M.next_numbered_item()
    local current_line = vim.api.nvim_win_get_cursor(0)[1]
    local total_lines = vim.api.nvim_buf_line_count(0)
    for i = current_line + 1, total_lines do
        local line = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]
        -- search for the correct line start
        if line:match("^%s*%d+:") then
            vim.api.nvim_win_set_cursor(0, {i, 0})
            break
        end
    end
end


-- navigate to the previous numbered item
function M.prev_numbered_item()
    local current_line = vim.api.nvim_win_get_cursor(0)[1]
    for i = current_line - 1, 1, -1 do
        local line = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]
        -- search for the correct line start
        if line:match("^%s*%d+:") then
            vim.api.nvim_win_set_cursor(0, {i, 0})
            break
        end
    end
end

-- customized paste function that functions more like 'p'
function M.smart_paste(text)
    -- convert text string to string list
    local lines = {}
    for line in text:gmatch("([^\n]*)\n?") do
        table.insert(lines, line)
    end

    -- determine if the text should be treated as line-wise based on its ending
    local type = "c"
    if #lines > 1 then
        type = "l"
        -- remove last newline character to replicate base put behavior
        table.remove(lines)
    end
    vim.api.nvim_put(lines, type, true, true)
end

return M
