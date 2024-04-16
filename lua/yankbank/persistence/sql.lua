local M = {}

local sqlite = require("sqlite.db")

-- @TODO: yank primary key?
-- integer tracking for table position not controlled by sqlite3

-- create db table for yanks, PK is row id and will increment automatically
-- @param existing_yanks table
-- @param uri string
-- @return sqlite_db
function M.init_db(existing_yanks, uri)
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
        print("yankbank db error: ", status.code)
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
function M.add_to_yanktable(db, yank_content, reg_type)
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
function M.remove_from_yanktable(db, yank_content)
    db:open()
    db:delete("yanks", { where = { yank_content = yank_content } })
    local status = db:status()
    db:close()
    return status == nil
end

-- returns all yanks in table sorted by recency descending
-- @param db sqlite_db
-- @return table[]
function M.get_yanks(db)
    db:open()
    local ret = db:select("yanks", { order_by = { asc = "id" } })
    db:close()
    return ret
end

function M.remove_by_yank_index(db, index)
    db:open()
    local ret = db:select("yanks", { order_by = { asc = "id" }})
    local id_to_remove = ret[index].id
    local del = db:delete("yanks", { where = { id = id_to_remove } })
    local status = db:status()
    db:close()
    return status == nil
end

-- test function for db operations
local function test_db()
    local test_db = M.init_db({}, "/tmp/test_yankbank.db")
    -- print(vim.inspect(test_db))
    M.add_to_yanktable(test_db, "Sample Yank", "reg")
    print(vim.inspect(M.get_yanks(test_db)))
    M.add_to_yanktable(test_db, "Sample Different Yank", "reg")
    M.remove_from_yanktable(test_db, "Sample Different Yank")
    print("after SDY delete")
    print(vim.inspect(M.get_yanks(test_db)))
    M.remove_by_yank_index(test_db, 2)
    print("after index 2 delete")
    print(vim.inspect(M.get_yanks(test_db)))
end

-- test_db()

return M
