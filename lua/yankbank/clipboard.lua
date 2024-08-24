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

-- autocommand to listen for yank events
---@param yanks table
---@param reg_types table
---@param opts table
function M.setup_yank_autocmd(yanks, reg_types, opts)
    vim.api.nvim_create_autocmd("TextYankPost", {
        callback = function()
            -- get register information
            local rn = vim.v.event.regname

            -- check changes wwere made to default register
            if rn == "" or rn == "+" then
                local reg_type = vim.fn.getregtype(rn)
                local yank_text = vim.fn.getreg(rn)

                if not yank_text or type(yank_text) ~= "string" then
                    return
                end

                if #yank_text <= 1 then
                    return
                end
                M.add_yank(yanks, reg_types, yank_text, reg_type, opts)
            end
        end,
    })

    -- poll registers when vim is focused (check for new clipboard activity)
    if opts.focus_gain_poll == true then
        vim.api.nvim_create_autocmd("FocusGained", {
            callback = function()
                -- get register information
                local reg_type = vim.fn.getregtype("+")
                local yank_text = vim.fn.getreg("+")

                if not yank_text or type(yank_text) ~= "string" then
                    return
                end

                if string.len(yank_text) <= 1 then
                    return
                end

                M.add_yank(yanks, reg_types, yank_text, reg_type, opts)
            end,
        })
    end
end

return M
