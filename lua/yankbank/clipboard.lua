-- clipboard.lua
local M = {}

-- TODO: convert string to table yanks to work better with files

-- Function to add yanked text to table
---@param yanks table
---@param reg_types table
---@param text string
---@param reg_type string
---@param max_entries integer
function M.add_yank(yanks, reg_types, text, reg_type, max_entries)
    -- avoid adding empty strings
    -- TODO: could block adding single characters here
    if text == "" or text == " " or text == "\n" then
        return
    end
    print(
        "yanks: ",
        vim.inspect(yanks),
        "| reg_types: ",
        vim.inspect(reg_types)
    )

    -- do not update with duplicate values
    for _, entry in ipairs(yanks) do
        if entry == text then
            return
        end
    end

    -- add entry to bank
    table.insert(yanks, 1, text)
    table.insert(reg_types, 1, reg_type)
    if #yanks > max_entries then
        table.remove(yanks)
        table.remove(reg_types)
    end
end

-- autocommand to listen for yank events
---@param yanks table
---@param reg_types table
---@param max_entries integer
function M.setup_yank_autocmd(yanks, reg_types, max_entries)
    vim.api.nvim_create_autocmd("TextYankPost", {
        callback = function()
            -- get register information
            local rn = vim.v.event.regname
            local reg_type = vim.fn.getregtype("+")

            -- check changes wwere made to default register
            if vim.v.event.regname == "" then
                local yanked_text = vim.fn.getreg(rn)
                if #yanked_text <= 1 then
                    return
                end
                M.add_yank(yanks, reg_types, yanked_text, reg_type, max_entries)
            end
        end,
    })
end

return M
