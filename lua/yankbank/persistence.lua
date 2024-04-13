-- persistence.lua

local M = {}

-- TODO: for file-based persistence:
-- - need system for moving entries around in list
--   - either use tags and search by tag (could be out of order)
--   - or keep list in sorted order (likely more i/o heavy)
-- - store local copy of list in memory, to make accesses to popup quick
--   - might need plenary for the asynchronous r/w accesses

function M.enable_persistence(yanks, opts)
    if not opts.persist_type then
        return
    elseif opts.persist_type == "file" then
        -- TODO:
        require("persistence.file").setup_persistence(
            yanks,
            opts.persist_path,
            opts.max_entries
        )
    elseif opts.persist_type == "sqlite" then
        -- TODO:
        require("persistence.sql").init_db(yanks, opts.persist_path)
    end
end

return M
