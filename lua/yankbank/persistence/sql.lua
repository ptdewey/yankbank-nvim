local M = {}

local sqlite = require("sqlite.db")

local dbdir = vim.fn.stdpath("data") .. "/databases"
local max_entries = 10

---@class YankBankDB:sqlite_db
---@field bank sqlite_tbl
local db = sqlite({
    uri = dbdir .. "/yankbank.db",
    bank = {
        -- yanked text should be unique and be primary key
        yank_text = { "text", unique = true, primary = true, required = true },
        reg_type = { "text", required = true },
    },
})

---@class sqlite_tbl
local data = db.bank

--- insert yank entry into database
---@param yank_text string yanked text
---@param reg_type string register type
function data:insert_yank(yank_text, reg_type)
    -- attempt to remove entry if count > 0 (to move potential duplicate)
    if self:count() > 0 then
        self:remove({ yank_text = yank_text })
    end

    -- insert entry
    self:insert({
        yank_text = yank_text,
        reg_type = reg_type,
    })

    -- attempt to trim database size
    self:trim_size()
end

--- trim database size if it exceeds max_entries option
function data:trim_size()
    if self:count() > max_entries then
        -- remove the oldest entry
        self:remove({ yank_text = self:get()[1].yank_text })
    end
end

--- get sqlite bank contents
---@return table yanks, table reg_types
function data:get_bank()
    local yanks, reg_types = {}, {}

    local bank = self:get()
    for _, entry in ipairs(bank) do
        table.insert(yanks, 1, entry.yank_text)
        table.insert(reg_types, 1, entry.reg_type)
    end

    return yanks, reg_types
end

-- FIX: correctly handle multiple sessions open at once
-- - fetch database state each time YankBank command is called?

--- set up database persistence
---@param opts table
---@return sqlite_tbl data
function M.setup(opts)
    max_entries = opts.max_entries

    -- TODO: move database into plugin directory instead to allow easier uninstall
    if vim.fn.isdirectory(dbdir) == 0 then
        vim.fn.mkdir(dbdir, "p")
    end

    return data
end

return M
