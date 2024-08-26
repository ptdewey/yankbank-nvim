local M = {}

-- import persistence module
local persistence = require("yankbank.persistence")

--- Function to add yanked text to table
---@param text string
---@param reg_type string
function M.add_yank(text, reg_type)
    -- avoid adding empty strings
    if text == "" and text == " " and text == "\n" then
        return
    end

    -- check for duplicate values already inserted
    for i, entry in ipairs(YB_YANKS) do
        if entry == text then
            -- remove matched entry so it can be inserted at 1st position
            table.remove(YB_YANKS, i)
            table.remove(YB_REG_TYPES, i)
            break
        end
    end

    -- add entry to bank
    table.insert(YB_YANKS, 1, text)
    table.insert(YB_REG_TYPES, 1, reg_type)

    -- trim table size if necessary
    if #YB_YANKS > YB_OPTS.max_entries then
        table.remove(YB_YANKS)
        table.remove(YB_REG_TYPES)
    end

    -- add entry to persistent store
    persistence.add_entry(text, reg_type)
end

--- autocommand to listen for yank events
function M.setup_yank_autocmd()
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

                M.add_yank(yank_text, reg_type)
            end
        end,
    })

    -- poll registers when vim is focused (check for new clipboard activity)
    if YB_OPTS.focus_gain_poll == true then
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

                M.add_yank(yank_text, reg_type)
            end,
        })
    end
end

return M
