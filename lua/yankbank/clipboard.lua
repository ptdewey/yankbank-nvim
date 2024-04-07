-- clipboard.lua
local M = {}

-- Function to add yanked text to table
function M.add_yank(yanks, reg_types, text, reg_type, max_entries)
    -- avoid adding empty strings
    if text ~= "" and text ~= " " and text ~= "\n" then
        -- do not update with duplicate values
        for _, entry in ipairs(yanks) do
            if entry == text then
                return
            end
        end
        table.insert(yanks, 1, text)
        table.insert(reg_types, 1, reg_type)
        if #yanks > max_entries then
            table.remove(yanks)
            table.remove(reg_types)
        end
    end
end

-- autocommand to listen for yank events
function M.setup_yank_autocmd(yanks, reg_types, max_entries)
    vim.api.nvim_create_autocmd("TextYankPost", {
        callback = function()
            -- TODO: this function can be expanded to incorporate other registers
            -- - use vim.v.event.regname and an allowlist
            -- local reg_type = vim.v.event.operator
            -- if reg_type == "y" or reg_type == "d" then
            -- local yanked_text = vim.fn.getreg('"')

            -- get register information
            local rn = vim.v.event.regname
            local reg_type = vim.fn.getregtype('"')

            -- check changes wwere made to default register
            if vim.v.event.regname == "" then
                local yanked_text = vim.fn.getreg(rn)

                -- NOTE: this only blocks adding to list if something else is in plus register
                if string.len(yanked_text) <= 1 then
                    return
                end

                M.add_yank(yanks, reg_types, yanked_text, reg_type, max_entries)
            end
        end,
    })
end

return M
