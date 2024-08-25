local M = {}

-- TODO: figure out how api should get 'yanks' and 'reg_types'
-- - possibly rewrite these to be global variables

--- DOC:
---@param i integer
---@return table
function M.get_entry(i)
    -- TODO: figure out how tables are being populated for the api
    return {
        yank_text = YANKS[i],
        reg_type = REG_TYPES[i],
    }
end

--- DOC:
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

return M
