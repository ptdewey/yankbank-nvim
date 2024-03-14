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
    -- determine if the text should be treated as line-wise based on its ending
    if text:sub(-1) == '\n' then
        -- line-wise
        vim.cmd("normal! o")
        vim.api.nvim_paste(text, false, -1)
    else
        -- character-wise
        vim.api.nvim_paste(text, false, -1)
    end
end

return M
