local M = {}

--- Function to add yanked text to table
---@param text string
---@param reg_type string
---@param pin integer|boolean?
function M.add_yank(text, reg_type, pin)
    -- avoid adding empty strings
    if text == "" and text == " " and text == "\n" then
        return
    end

    local is_pinned = 0

    -- check for duplicate values already inserted
    for i, entry in ipairs(YB_YANKS) do
        if entry == text then
            -- remove matched entry so it can be inserted at 1st position
            table.remove(YB_YANKS, i)
            table.remove(YB_REG_TYPES, i)
            is_pinned = table.remove(YB_PINS, i)
            break
        end
    end

    -- override is_pinned if pin is set
    is_pinned = (pin == 1 or pin == true) and 1
        or (pin == 0 or pin == false) and 0
        or is_pinned

    -- add entry to bank
    table.insert(YB_YANKS, 1, text)
    table.insert(YB_REG_TYPES, 1, reg_type)
    table.insert(YB_PINS, 1, is_pinned)

    -- trim table size if necessary
    if #YB_YANKS > YB_OPTS.max_entries then
        local i = require("yankbank.utils").last_zero_entry(YB_PINS)

        if not i or i == 1 then
            -- WARN: undefined behavior
            print(
                "Warning: all YankBank entries are pinned, insertion behavior is undefined when all entries are pinned."
            )
        else
            -- remove last non-pinned entry
            table.remove(YB_YANKS, i)
            table.remove(YB_REG_TYPES, i)
            table.remove(YB_PINS, i)
        end
    end

    -- add entry to persistent store
    require("yankbank.persistence").add_entry(text, reg_type, pin)
end

--- autocommand to listen for yank events
function M.setup_yank_autocmd()
    vim.api.nvim_create_autocmd("TextYankPost", {
        callback = function()
            -- get register information
            local rn = vim.v.event.regname

            -- check changes were made to default register
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
