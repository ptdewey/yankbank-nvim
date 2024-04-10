-- persistence.lua

local M = {}

-- TODO: for file-based persistence:
-- - need system for moving entries around in list
--   - either use tags and search by tag (could be out of order)
--   - or keep list in sorted order (likely more i/o heavy)
-- - store local copy of list in memory, to make accesses to popup quick
--   - might need plenary for the asynchronous r/w accesses

function M.enable_persistence(yanks, opts)
    if not opts.method then
        return
    elseif opts.method == "file" then
        -- TODO:
        require("persistence.file").setup_persistence(
            yanks,
            opts.persist_file,
            opts.max_entries
        )
    elseif opts.method == "sqlite" then
        -- TODO:
        print("sqlite persistence not yet implemented.")
    end
end

return M
