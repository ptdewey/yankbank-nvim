local M = {}

--- get the last zero entry in a table
---
---@param t table
---@return integer?
function M.last_zero_entry(t)
    for i = #t, 1, -1 do
        if t[i] == 0 then
            return i
        end
    end
    return nil
end

return M
