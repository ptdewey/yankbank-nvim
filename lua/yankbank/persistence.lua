-- persistence.lua
local M = {}

---comment
---@param yanks table
---@param reg_types table
---@param opts table
function M.add_entry(yanks, reg_types, opts)
    if not opts.persist_type then
        return
    elseif opts.persist_type == "memory" then
        return
    elseif opts.persist_type == "file" then
        -- TODO:
    elseif opts.persist_type == "sqlite" then
    end
end

---initialize bank persistence
---@param yanks table
---@param reg_types table
---@param opts table
function M.setup(yanks, reg_types, opts)
    if not opts.persist_type then
        return
    elseif opts.persist_type == "file" then
        -- TODO:
        require("yankbank.persistence.file").setup_persistence(
            opts.persist_path,
            opts.max_entries,
            yanks,
            reg_types
        )
    elseif opts.persist_type == "sqlite" then
        -- TODO:
        require("yankbank.persistence.sql").init_db(
            yanks,
            reg_types,
            opts.persist_path
        )
    end
end

return M
