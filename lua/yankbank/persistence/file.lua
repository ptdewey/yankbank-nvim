-- persistence/file.lua

local M = {}

local n_entries = 0

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
    for line in io.lines(file) do
        lines[#lines + 1] = line
    end
    return lines
end

-- check first line from file for presence of yankbank list header.
-- if it exists, populate current number of entries.
---@param line string
---@return boolean
local function check_for_header(line)
    local n = string.match(line, "<YANKBANK_LIST:(%d+)>")
    if n then
        n_entries = n
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

-- populate yankbank with entries contained in file.
---@param yanks table: table to populate with yanks
---@param file string: yankbank persistence file
---@param max_entries integer: maximum number of yankbank entries
local function populate_yankbank(yanks, file, max_entries)
    -- read lines from file
    local lines = read_lines(file)
    if not check_for_header(lines[1]) then
        print("YankBank list header not found in file...")
        return
    end

    -- iterate through remaining lines in file, adding entries to yankbank
    local entries = {}
    local i = 2
    while i <= #lines do
        local res = check_for_entry(lines[i])
        if res then
            local entry = read_entry(i + 1, res.length, lines)
            if res.index < max_entries then
                -- add to entries
                -- NOTE: might need to sort entries afterwards
                -- TODO: populate yankbank entries
                -- - update yanks table, reg_type, and place at correct spot in list
                entries[#entries + 1] = entry -- TODO: might need to convert to string
                -- NOTE: ^ should I use table.insert instead? (probably)
            end
            -- skip lines that were added to entries
            i = i + res.length
        end
        i = i + 1
    end

    -- TODO: add entries to bank
    print(yanks)

    print(vim.inspect(entries))
end

-- setup function for a persistence file.
-- should be called in plugin setup function
---@param yanks table: table to populate with yanks
---@param file string: file path
---@param max_entries integer: maximum number of yankbank entries
function M.setup_persistence(yanks, file, max_entries)
    -- check if file exists, create it (with header) if it does not
    if not file_exists(file) then
        print("Creating file...")
        local f, err = io.open(file, "w")
        if f then
            f:write("<YANKBANK_LIST:0>")
            f:close()
        else
            print(err)
        end
        return
    end
    populate_yankbank(yanks, file, max_entries)
end

-- local lines = read_lines("test.txt")
-- print(vim.inspect(lines))
-- TEST: remove later
local yanks = {}
print(M.setup_persistence(yanks, "test.txt", 10))
yanks = {}
print(M.setup_persistence(yanks, "test1.txt", 10))
print(n_entries)

return M
