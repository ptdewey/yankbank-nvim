local M = {}

local state = require("yankbank.state")

--- get a table containg a single yankbank entry by index
---@param i integer
---@return table
function M.get_entry(i)
    return {
        yank_text = state.get_yanks()[i],
        reg_type = state.get_reg_types()[i],
    }
end

--- get a table containing all yankbank entries
---@return table
function M.get_all()
    local out = {}
    local yanks = state.get_yanks()
    local reg_types = state.get_reg_types()
    for i, v in ipairs(yanks) do
        table.insert(out, {
            yank_text = v,
            reg_type = reg_types[i],
        })
    end
    return out
end

--- add an entry to yankbank
---@param yank_text string yank text to add to YANKS table
---@param reg_type string register type "v", "V", or "^V" (visual, v-line, v-block respectively)
---@param pin integer|boolean?
function M.add_entry(yank_text, reg_type, pin)
    require("yankbank.clipboard").add_yank(yank_text, reg_type, pin)
end

--- remove entry from yankbank by index
---@param i integer index to remove
function M.remove_entry(i)
    local yanks = state.get_yanks()
    local reg_types = state.get_reg_types()
    local yank_text = table.remove(yanks, i)
    local reg_type = table.remove(reg_types, i)
    state.set_yanks(yanks)
    state.set_reg_types(reg_types)
    
    local opts = state.get_opts()
    if opts.persist_type == "sqlite" then
        require("yankbank.persistence.sql")
            .data()
            .remove_match(yank_text, reg_type)
    end
end

--- pin entry to yankbank so that it won't be removed when its position exceeds the max number of entries
---
---@param i integer index to pin
function M.pin_entry(i)
    local pins = state.get_pins()
    if i > #pins then
        return
    end

    -- TODO: show pins differently in popup (could use different hl_groups for pinned entries?)
    pins[i] = 1
    state.set_pins(pins)

    local opts = state.get_opts()
    if opts.persist_type == "sqlite" then
        return require("yankbank.persistence.sql")
            .data()
            .pin(state.get_yanks()[i], state.get_reg_types()[i])
    end
end

--- unpin bank entry
---
---@param i integer index to unpin
function M.unpin_entry(i)
    local pins = state.get_pins()
    if i > #pins then
        return
    end

    -- TODO: update popup pin highlight
    pins[i] = 0
    state.set_pins(pins)

    local opts = state.get_opts()
    if opts.persist_type == "sqlite" then
        return require("yankbank.persistence.sql")
            .data()
            .unpin(state.get_yanks()[i], state.get_reg_types()[i])
    end
end

-- TODO: individual popup keymap setting functions

return M
