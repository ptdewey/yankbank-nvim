-- clipboard.lua
local M = {}

-- Function to add yanked text to table
function M.add_yank(yanks, text, max_entries)
    -- avoid adding empty strings
    if text ~= "" then
        table.insert(yanks, 1, text)

        if #yanks > max_entries then
            table.remove(yanks)
        end
    end
end

-- autocommand to listen for yank events
function M.setup_yank_autocmd(yanks, max_entries)
    vim.api.nvim_create_autocmd("TextYankPost", {
        callback = function()
            -- TODO: this function can be expanded to incorporate other registers
            -- - use vim.v.event.regname and an allowlist
            -- if reg_type == "y" or reg_type == "d" then
            -- local yanked_text = vim.fn.getreg('"')

            -- get register information
            local reg_type = vim.v.event.operator
            local rn = vim.v.event.regname

            -- check changes wwere made to default register
            if vim.v.event.regname == '' then
                local yanked_text = vim.fn.getreg(rn)

                -- don't track single character deletions
                if #yanked_text <= 1 and reg_type ~= "y" then
                    return
                end

                M.add_yank(yanks, yanked_text, max_entries)
            end
        end,
    })
end

return M
