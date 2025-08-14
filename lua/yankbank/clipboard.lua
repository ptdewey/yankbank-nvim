local M = {}

local state = require("yankbank.state")

--- get the last zero entry in a table
---
---@param t table
---@return integer?
local function last_zero_entry(t)
    for i = #t, 1, -1 do
        if t[i] == 0 then
            return i
        end
    end
    return nil
end

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
    local yanks = state.get_yanks()
    local reg_types = state.get_reg_types()
    local pins = state.get_pins()

    -- check for duplicate values already inserted
    for i, entry in ipairs(yanks) do
        if entry == text then
            -- remove matched entry so it can be inserted at 1st position
            table.remove(yanks, i)
            table.remove(reg_types, i)
            is_pinned = table.remove(pins, i)
            break
        end
    end

    -- override is_pinned if pin is set
    is_pinned = (pin == 1 or pin == true) and 1
        or (pin == 0 or pin == false) and 0
        or is_pinned

    -- add entry to bank
    table.insert(yanks, 1, text)
    table.insert(reg_types, 1, reg_type)
    table.insert(pins, 1, is_pinned)

    -- trim table size if necessary
    local opts = state.get_opts()
    if #yanks > opts.max_entries then
        local i = last_zero_entry(pins)

        if not i or i == 1 then
            -- WARN: undefined behavior
            print(
                "Warning: all YankBank entries are pinned, insertion behavior is undefined when all entries are pinned."
            )
        else
            -- remove last non-pinned entry
            table.remove(yanks, i)
            table.remove(reg_types, i)
            table.remove(pins, i)
        end
    end

    -- update state
    state.set_yanks(yanks)
    state.set_reg_types(reg_types)
    state.set_pins(pins)

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

                -- lazy load initialization when first yank happens
                require("yankbank").ensure_initialized()
                M.add_yank(yank_text, reg_type)
            end
        end,
    })

    -- poll registers when vim is focused (check for new clipboard activity)
    local opts = state.get_opts()
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

                -- lazy load initialization when first focus gain happens
                require("yankbank").ensure_initialized()
                M.add_yank(yank_text, reg_type)
            end,
        })
    end
end

return M
