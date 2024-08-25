local M = {}

local sqlite = require("sqlite.db")

-- local dbdir = vim.fn.stdpath("data") .. "/databases"
local dbdir = debug.getinfo(1).source:sub(2):match("(.*/).*/.*/.*/") or "./"
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
        db:with_open(function()
            db:eval(
                "DELETE FROM bank WHERE yank_text = :yank_text",
                { yank_text = yank_text }
            )
        end)
    end

    -- insert entry using the eval method with parameterized query to avoid error on 'data:insert()'
    db:with_open(function()
        db:eval(
            "INSERT INTO bank (yank_text, reg_type) VALUES (:yank_text, :reg_type)",
            { yank_text = yank_text, reg_type = reg_type }
        )
    end)

    -- attempt to trim database size
    self:trim_size()
end

--- trim database size if it exceeds max_entries option
function data:trim_size()
    if self:count() > max_entries then
        -- remove the oldest entry
        local oldest_entry = db:with_open(function()
            return db:select(
                "bank",
                { order_by = { asc = "rowid" }, limit = { 1 } }
            )[1]
        end)

        if oldest_entry then
            db:with_open(function()
                db:eval(
                    "DELETE FROM bank WHERE yank_text = :yank_text",
                    { yank_text = oldest_entry.yank_text }
                )
            end)
        end
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

--- set up database persistence
---@param opts table
---@return sqlite_tbl data
function M.setup(opts)
    max_entries = opts.max_entries

    vim.api.nvim_create_user_command("YankBankClearDB", function()
        data:remove()
        YANKS = {}
        REG_TYPES = {}
    end, {})

    if opts.debug == true then
        vim.api.nvim_create_user_command("YankBankViewDB", function()
            print(vim.inspect(data:get()))
        end, {})
    end

    return data
end

return M
