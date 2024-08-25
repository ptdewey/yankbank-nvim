local M = {}

--- get a table containg a single yankbank entry by index
---@param i integer
---@return table
function M.get_entry(i)
    return {
        yank_text = YANKS[i],
        reg_type = REG_TYPES[i],
    }
end

--- get a table containing all yankbank entries
---@return table
function M.get_all()
    local out = {}
    for i, v in ipairs(YANKS) do
        table.insert(out, {
            yank_text = v,
            reg_type = REG_TYPES[i],
        })
    end
    return out
end

--- add an entry to yankbank
---@param yank_text string yank text to add to YANKS table
---@param reg_type string register type "v", "V", or "^V" for visual, visual-linewise, and visual-block modes respectively.
function M.add_entry(yank_text, reg_type)
    require("yankbank.clipboard").add_yank(yank_text, reg_type)
end

--- remove entry from yankbank by index
---@param i integer index to remove
function M.remove_entry(i)
    local yank_text = table.remove(YANKS, i)
    table.remove(REG_TYPES, i)
    if OPTS.persist_type == "sqlite" then
        require("yankbank.persistence.sql").data():remove_match(yank_text)
    end
end

-- TODO: individual popup keymap setting functions
-- - could just update opts table that is passed into set_keymaps

return M
