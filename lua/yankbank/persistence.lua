-- persistence.lua
local M = {}

local persistence = {}
local db = nil

---add entry from bank to
---@param entry string|table
---@param reg_type string
---@param opts table
function M.add_entry(entry, reg_type, opts)
    if not opts.persist_type then
        return
    elseif opts.persist_type == "file" then
        persistence.add_to_bankfile(opts.persist_path, entry, reg_type)
    elseif opts.persist_type == "sqlite" then
        persistence.add_to_yanktable(db, entry, reg_type)
    end
end

---initialize bank persistence
---@param yanks table
---@param reg_types table
---@param opts table
---@return table
---@return table
function M.setup(yanks, reg_types, opts)
    if not opts.persist_type then
        return {}, {}
    elseif opts.persist_type == "file" then
        persistence = require("yankbank.persistence.file")
        return persistence.setup_persistence(
            opts.persist_path,
            opts.max_entries,
            yanks,
            reg_types
        )
    elseif opts.persist_type == "sqlite" then
        persistence = require("yankbank.persistence.sql")
        db = persistence.init_db(yanks, reg_types, opts.persist_path)
        return yanks, reg_types
    end

    return {}, {}
end

return M
