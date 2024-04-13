local M = {}

local sqlite = require("sqlite.db")

-- @TODO: yank primary key?
-- integer tracking for table position not controlled by sqlite3

-- create db table for yanks, PK is row id and will increment automatically
-- @param existing_yanks table
-- @param uri string
-- @return sqlite_db
local function init_db(existing_yanks, uri)
    local db = sqlite({
        uri = uri,
    })
    db:open()

    db:create("yanks", {
        id = true,
        yank_content = { "text", required = true },
        reg_type = { "text", required = true },
        ensure = true,
    })
    local status = db:status()

    if status ~= nil then
        print("yankbank db error: " + status.code)
    end
    -- @TODO: add functionality to add existing yanks to the db table "yanks"
    db:close()
    return db
end

-- add entry to DB
-- @param db sqlite_db
-- @param yank_content string
-- @param reg_type string
-- @return boolean
local function add_to_yanktable(db, yank_content, reg_type)
    db:open()
    db:insert("yanks", { yank_content = yank_content, reg_type = reg_type })
    local status = db:status()
    db:close()
    return status == nil
end

-- removes entry from yanktable
-- @param db sqlite_db
-- @param yank_content string
-- @return boolean
local function remove_from_yanktable(db, yank_content)
    db:open()
    db:delete("yanks", { where = { yank_content = yank_content } })
    local status = db:status()
    db:close()
    return status == nil
end

-- returns all yanks in table sorted by recency descending
-- @param db sqlite_db
-- @return table[]
local function get_yanks(db)
    db:open()
    local ret = db:select("yanks", { order_by = { asc = "id" } })
    db:close()
    return ret
end

-- test function for db operations
-- local function test_db()
--     local test_db = init_db("/tmp/test_yankbank.db")
--     add_to_yanktable(test_db, "Sample Yank", "reg")
--     print(vim.inspect(get_yanks(test_db)))
--     add_to_yanktable(test_db, "Sample Different Yank", "reg")
--     remove_from_yanktable(test_db, "Sample Different Yank")
--     print("after delete")
--     print(vim.inspect(get_yanks(test_db)))
-- end

return M
