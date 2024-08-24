local M = {}

local persistence = {}

---add entry from bank to
---@param entry string|table
---@param reg_type string
---@param opts table
function M.add_entry(entry, reg_type, opts)
    if not opts.persist_type then
        return
    elseif opts.persist_type == "sqlite" then
        persistence:insert_yank(entry, reg_type)
    end
end

---initialize bank persistence
---@param opts table
---@return table
---@return table
function M.setup(opts)
    if not opts.persist_type then
        return {}, {}
    elseif opts.persist_type == "sqlite" then
        persistence = require("yankbank.persistence.sql").setup(opts)
        return persistence:get_bank()
    else
        return {}, {}
    end
end

return M
