local M = {}

-- import persistence module
local persistence = require("yankbank.persistence")

-- Function to add yanked text to table
---@param yanks table
---@param reg_types table
---@param text string
---@param reg_type string
---@param opts table
function M.add_yank(yanks, reg_types, text, reg_type, opts)
    -- avoid adding empty strings
    -- TODO: could block adding single characters here
    if text == "" or text == " " or text == "\n" then
        return
    end

    -- do not update with duplicate values
    -- BUG: there seems to be some issues here when trying to add on pipup open
    for _, entry in ipairs(yanks) do
        if entry == text then
            return
        end
    end

    -- add entry to bank
    table.insert(yanks, 1, text)
    table.insert(reg_types, 1, reg_type)
    if #yanks > opts.max_entries then
        table.remove(yanks)
        table.remove(reg_types)
    end

    -- add entry to persistent store
    persistence.add_entry(text, reg_type, opts)
end

-- TODO: autocmd for focus gained (check system clipboard?)

-- autocommand to listen for yank events
---@param yanks table
---@param reg_types table
---@param opts table
function M.setup_yank_autocmd(yanks, reg_types, opts)
    vim.api.nvim_create_autocmd("TextYankPost", {
        callback = function()
            -- get register information
            local rn = vim.v.event.regname
            -- local reg_type = vim.fn.getregtype("+")

            -- check changes wwere made to default register
            if vim.v.event.regname == "" or vim.v.event.regname == "+" then
                local reg_type = vim.fn.getregtype(rn)
                local yanked_text = vim.fn.getreg(rn)
                if #yanked_text <= 1 then
                    return
                end
                M.add_yank(yanks, reg_types, yanked_text, reg_type, opts)
            end
        end,
    })
end

return M
