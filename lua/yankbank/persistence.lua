local M = {}

local persistence = {}

---add entry from bank to
---@param entry string
---@param reg_type string
---@param pin integer|boolean?
function M.add_entry(entry, reg_type, pin)
    if YB_OPTS.persist_type == "sqlite" then
        persistence:insert_yank(entry, reg_type, pin)
    end
end

--- get current state of yanks in persistent storage
function M.get_yanks()
    if YB_OPTS.persist_type == "sqlite" then
        return persistence:get_bank()
    end
end

---initialize bank persistence
---@return table
---@return table
function M.setup()
    if not YB_OPTS.persist_type then
        return {}, {}
    elseif YB_OPTS.persist_type == "sqlite" then
        persistence = require("yankbank.persistence.sql").setup()
        return persistence:get_bank()
    else
        return {}, {}
    end
end

return M
