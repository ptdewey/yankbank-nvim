local M = {}

local sqlite = require("sqlite")

-- local dbdir = vim.fn.stdpath("data") .. "/databases"
local dbdir = debug.getinfo(1).source:sub(2):match("(.*/).*/.*/.*/") or "./"
local max_entries = 10

---@class YankBankDB:sqlite_db
---@field bank sqlite_tbl
---@field bank sqlite_tbl
local db = sqlite({
    uri = dbdir .. "/yankbank.db",
    bank = {
        -- yanked text should be unique and be primary key
        yank_text = { "text", unique = true, primary = true, required = true },
        reg_type = { "text", required = true },
        pinned = { "integer", required = true, default = 0 },
    },
})

---@class sqlite_tbl
local data = db.bank

-- NOTE: escape and unescape query text
-- TODO: adjust to only escape text that matches function syntax
---
---@param content string
---@return string
function M.escape(content)
    return string.format("__ESCAPED__'%s'", content)
end

---
---@param content string
---@return string
---@return integer?
function M.unescape(content)
    return content:gsub("^__ESCAPED__'(.*)'$", "%1")
end

--- insert yank entry into database
---@param yank_text string yanked text
---@param reg_type string register type
---@param pin integer|boolean? pin status of inserted entry
function data:insert_yank(yank_text, reg_type, pin)
    -- attempt to remove entry if count > 0 (to move potential duplicate)
    local is_pinned = 0
    if self:count() > 0 then
        db:with_open(function()
            -- check if entry exists in db
            local res = db:eval(
                "SELECT * FROM bank WHERE yank_text = :yank_text and reg_type = :reg_type",
                { yank_text = M.escape(yank_text), reg_type = reg_type }
            )

            -- if result is empty (eval returns boolean), proceed to insertion
            if type(res) == "boolean" then
                return
            end

            -- entry found, get pin status
            is_pinned = res[1].pinned

            -- remove entry from db so it can be moved to first position
            db:eval(
                "DELETE FROM bank WHERE yank_text = :yank_text and reg_type = :reg_type",
                { yank_text = M.escape(yank_text), reg_type = reg_type }
            )
        end)
    end

    -- override is_pinned if pin param is set, default to is_pinned otherwise
    is_pinned = (pin == 1 or pin == true) and 1
        or (pin == 0 or pin == false) and 0
        or is_pinned

    -- insert entry using the eval method with parameterized query to avoid error on 'data:insert()'
    db:with_open(function()
        db:eval(
            "INSERT INTO bank (yank_text, reg_type, pinned) VALUES (:yank_text, :reg_type, :pinned)",
            {
                yank_text = M.escape(yank_text),
                reg_type = reg_type,
                pinned = is_pinned,
            }
        )
    end)

    -- attempt to trim database size
    self:trim_size()
end

--- trim database size if it exceeds max_entries option
--- WARN: if all entries are pinned, behavior is undefined
function data:trim_size()
    if self:count() > max_entries then
        -- remove the oldest entry
        local e = db:with_open(function()
            return db:select("bank", {
                where = { pinned = 0 },
                order_by = { asc = "rowid" },
                limit = 1,
            })[1]
        end)

        if e then
            db:with_open(function()
                db:eval(
                    "DELETE FROM bank WHERE yank_text = :yank_text",
                    { yank_text = e.yank_text }
                )
            end)
        end
    end
end

--- get sqlite bank contents
---@return table yanks, table reg_types, table pins
function data:get_bank()
    local yanks, reg_types, pins = {}, {}, {}

    local bank = self:get()
    for _, entry in ipairs(bank) do
        local text, _ = M.unescape(entry.yank_text)
        table.insert(yanks, 1, text)
        table.insert(reg_types, 1, entry.reg_type)
        table.insert(pins, 1, entry.pinned)
    end

    return yanks, reg_types, pins
end

--- remove an entry from the banks table matching input text
---@param text string
---@param reg_type string
function data.remove_match(text, reg_type)
    db:with_open(function()
        return db:eval(
            "DELETE FROM bank WHERE yank_text = :yank_text and reg_type = :reg_type",
            { yank_text = M.escape(text), reg_type = reg_type }
        )
    end)
end

--- pin entry in yankbank to prevent removal
---@param text string text to match and pin
---@param reg_type string reg_type corresponding to text
---@return boolean
function data.pin(text, reg_type)
    return db:with_open(function()
        -- TODO: always returns true or nothing
        return (
            db:eval(
                "UPDATE bank SET pinned = 1 WHERE yank_text = :yank_text and reg_type = :reg_type",
                { yank_text = M.escape(text), reg_type = reg_type }
            )
        )
    end)
end

--- unpin entry in yankbank to prevent removal
---@param text string
---@param reg_type string reg_type corresponding to text
---@return boolean
function data.unpin(text, reg_type)
    return db:with_open(function()
        -- TODO: always returns true or nothing
        -- - figure out how to return if updated or remove return
        return db:eval(
            "UPDATE bank SET pinned = 0 WHERE yank_text = :yank_text and reg_type = :reg_type",
            { yank_text = M.escape(text), reg_type = reg_type }
        )
    end)
end

--- get data in sqlite_tbl form (for api use only)
---@return sqlite_tbl
function M.data()
    return data
end

--- set up database persistence
---@return sqlite_tbl data
function M.setup()
    max_entries = YB_OPTS.max_entries

    vim.api.nvim_create_user_command("YankBankClearDB", function()
        data:drop()
        YB_YANKS = {}
        YB_REG_TYPES = {}
    end, {})

    if YB_OPTS.debug == true then
        vim.api.nvim_create_user_command("YankBankViewDB", function()
            print(vim.inspect(data:get()))
        end, {})
    end

    return data
end

return M
