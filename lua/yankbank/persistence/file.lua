-- persistence/file.lua

local M = {}

local n_entries = 0
local m_entries = 10

-- function that checks if a file exists
---@param file string: file path
---@return boolean
local function file_exists(file)
    local f = io.open(file, "rb")
    if f then
        f:close()
    end
    return f ~= nil
end

-- function that reads all lines of file into a table
---@param file string: file path
---@return table
local function read_lines(file)
    if not file_exists(file) then
        return {}
    end
    local lines = {}
    local f, err = io.open(file)
    if not f then
        error("Error opening file: " .. err)
    end
    for line in f:lines() do
        lines[#lines + 1] = line
    end
    f:close()
    return lines
end

-- check first line from file for presence of yankbank list header.
-- if it exists, populate current number of entries.
---@param line string
---@return boolean
local function check_for_header(line)
    local n = string.match(line, "<YANKBANK_LIST:(%d+)>")
    if n then
        n_entries = tonumber(n, 10)
        return true
    end
    return false
end

-- function that checks for the presence of a yankbank header on a given line.
-- returns t/f and index, length for entries that exist
---@param line string: line from file being checked
---@return table|nil
local function check_for_entry(line)
    local i, l, ft, rt =
        string.match(line, "<YANKBANK_ENTRY:(%d+),(%d+),(%a+),(%a+)>")
    if i then
        return {
            index = tonumber(i),
            length = tonumber(l),
            file_type = ft,
            reg_type = rt,
        }
    end
end

-- function that reads a yankbank entry from an index to an offset.
---@param i integer: starting index
---@param offset integer: stopping point = i+offset
---@param lines table: file contents
---@return table: yankbank entry in string table form
local function read_entry(i, offset, lines)
    local entry = {}
    for j = i, i + offset - 1 do
        entry[#entry + 1] = lines[j]
    end
    return entry
end

-- remove entry from bankfile
---@param file string: bank file name
local function remove_last_entry(file)
    local f, err = io.open(file, "r+")
    if not f then
        error("Could not open file for reading: " .. err)
    end

    -- read lines from file until matching entry is found
    local lines = {}
    -- TODO: does this for loop work?
    for line in f:lines() do
        print(line)
        if
            string.match(
                line,
                "<YANKBANK_ENTRY:" .. n_entries .. ",%d+,%a+,%a+>"
            )
        then
            n_entries = n_entries - 1
            lines[1] = "<YANKBANK_LIST:" .. n_entries .. ">\n"
            break
        else
            lines[#lines + 1] = line
        end
    end
    f:close()

    -- write to file
    f, err = io.open(file, "w")
    if not f then
        error("Could not open file for writing: " .. err)
    end
    for i = 1, #lines do
        f:write(lines[i])
    end
    f:close()
end

local function open_file(file, mode)
    local f, err = io.open(file, mode)
    if not f then
        error("Could not open file: " .. err)
    end
    return f
end

-- add entry bankfile. (this function needs to be callable from outside the module)
---@param file string
---@param entry table|string
---@param reg_type string
-- TODO: trigger in add_yank in clipboard.lua
-- Function scope probably needs to change to a different level (or be callable from persistence.lua)
local function add_to_bankfile(file, entry, reg_type)
    if n_entries >= m_entries then
        remove_last_entry(file)
    end
    n_entries = n_entries + 1

    -- local f, err = io.open(file, "w")
    local lines = read_lines(file)
    print(vim.inspect(lines))
    local f = open_file(file, "w+")
    -- BUG: issues around here surrounding newline behavior
    -- - definintely an issue adding, only appears after inserting first entry
    f:write("<YANKBANK_LIST:" .. n_entries .. ">\n")
    for i = 2, #lines do
        print(i)
        f:write(lines[i] .. "\n")
        print(lines[i])
    end

    -- write entry header
    f:write(
        "<YANKBANK_ENTRY:"
            .. n_entries
            .. ","
            .. #entry
            .. ",nil,"
            .. reg_type
            .. ">\n"
    )

    -- convert string entry to table
    if type(entry) == "string" then
        print(entry)
        -- local text = entry
        -- entry = {}
        -- for line in text:gmatch("[^\r\n]+") do
        --     table.insert(entry, line)
        -- end
        f:write(entry .. "\n")
        return
    end

    for i = 1, #entry do
        f:write(entry[i])
    end

    f:close()
end

-- populate yankbank with entries contained in file.
---@param yanks table: table to populate with yanks
---@param file string: yankbank persistence file
---@param max_entries integer: maximum number of yankbank entries
---@return table, table
local function populate_yankbank(file, max_entries, yanks, reg_types)
    -- read lines from file
    local lines = read_lines(file)
    if not check_for_header(lines[1]) then
        print("YankBank list header not found in file...")
        return {}, {}
    end

    -- iterate through remaining lines in file, adding entries to yankbank
    local i = 2
    while i <= #lines do
        local res = check_for_entry(lines[i])
        if res then
            local entry = read_entry(i + 1, res.length, lines)
            if res.index < max_entries then
                yanks[#yanks + 1] = entry
                reg_types[#reg_types + 1] = res.reg_type
                -- NOTE: ^ should I use table.insert instead? (would allow inserting at specific position)
            end
            -- skip lines that were added to entries
            i = i + res.length
        end
        i = i + 1
    end
    return yanks, reg_types
end

-- setup function for a persistence file.
-- should be called in plugin setup function
---@param file string: file path
---@param max_entries integer: maximum number of yankbank entries
---@param yanks table: table to populate with yanks
---@param reg_types table: table containing register types
---@return table, table
function M.setup_persistence(file, max_entries, yanks, reg_types)
    -- check if file exists, otherwise create it (with header)
    if not file_exists(file) then
        print("Creating file...")
        local f, err = io.open(file, "w")
        if f then
            f:write("<YANKBANK_LIST:0>")
            f:close()
        else
            print(err)
        end
        return {}, {}
    end
    m_entries = max_entries
    return populate_yankbank(file, max_entries, yanks, reg_types)
end

-- TEST: remove later
local yanks = {}
local reg_types = {}
M.setup_persistence("test.txt", 10, yanks, reg_types)
print(vim.inspect(yanks))
print(vim.inspect(reg_types))
yanks = {}
reg_types = {}
print(vim.inspect(yanks))
print(vim.inspect(reg_types))
M.setup_persistence("test1.txt", 10, yanks, reg_types)
m_entries = 10
add_to_bankfile("test1.txt", "text", "v")
-- BUG: this isnt added to the testing file, file i/o might be too slow
add_to_bankfile("test1.txt", "text1", "V")
-- remove_last_entry("test1.txt")

return M
