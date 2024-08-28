local M = {}

--- get a table containg a single yankbank entry by index
---@param i integer
---@return table
function M.get_entry(i)
    return {
        yank_text = YB_YANKS[i],
        reg_type = YB_REG_TYPES[i],
    }
end

--- get a table containing all yankbank entries
---@return table
function M.get_all()
    local out = {}
    for i, v in ipairs(YB_YANKS) do
        table.insert(out, {
            yank_text = v,
            reg_type = YB_REG_TYPES[i],
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
    local yank_text = table.remove(YB_YANKS, i)
    local reg_type = table.remove(YB_REG_TYPES, i)
    if YB_OPTS.persist_type == "sqlite" then
        require("yankbank.persistence.sql")
            .data()
            .remove_match(yank_text, reg_type)
    end
end

--- pin entry to yankbank so that it won't be removed when its position exceeds the max number of entries
---
---@param i integer index to pin
function M.pin_entry(i)
    -- TODO: check persistence mode, max_entries
    -- - add third table YB_PINS to keep track of pins
    -- TODO: show pins differently in popup
    if YB_OPTS.persist_type == "sqlite" then
        return require("yankbank.persistence.sql")
            .data()
            .pin(YB_YANKS[i], YB_REG_TYPES[i])
    end
end

--- unpin bank entry
---
---@param i integer index to unpin
function M.unpin_entry(i)
    -- TODO: check persistence mode, max_entries
    -- - in sql.lua, add 3rd field (bool) pinned
    if YB_OPTS.persist_type == "sqlite" then
        return require("yankbank.persistence.sql")
            .data()
            .unpin(YB_YANKS[i], YB_REG_TYPES[i])
    end
end

-- TODO: individual popup keymap setting functions
-- - could just update opts table that is passed into set_keymaps

return M
