-- init.lua
local M = {}

-- local imports
local menu = require("yankbank.menu")
local clipboard = require("yankbank.clipboard")

-- initialize yanks tables
local yanks = {}
local max_entries = 10
local sep = "-----"

-- wrapper function for main plugin functionality
local function show_yank_bank(args)
    -- Parse command arguments directly if args are provided as a string
    local opts = {}
    if type(args) == "string" and args ~= "" then
        local parts = vim.split(args, "%s+", {true})
        opts.max_entries = tonumber(parts[1])
        opts.sep = parts[2]
    elseif type(args) == "table" then
        -- If opts is already a table, use it directly (for programmatic calls)
        opts = args
    end

    -- Fallback to defaults if necessary
    local max_entries_opt = opts.max_entries or max_entries
    local sep_opt = opts.sep or sep

    local bufnr, display_lines, line_yank_map = menu.create_and_fill_buffer(yanks, max_entries_opt, sep_opt)
    -- handle empty bank case
    if not bufnr then
        return
    end
    local win_id = menu.open_window(bufnr, display_lines)
    menu.set_keymaps(win_id, bufnr, yanks, line_yank_map)
end

-- plugin setup
function M.setup(opts)
    opts = opts or {}

    -- parse opts
    max_entries = opts.max_entries or max_entries
    sep = opts.sep or sep

    -- create clipboard autocmds
    clipboard.setup_yank_autocmd(yanks, max_entries)

    -- Create user command
    -- TODO: allow params (i.e. keymaps/max_entries/separator)
    vim.api.nvim_create_user_command("YankBank", function(args)
        show_yank_bank(args.args)
    end, { desc = "Show Recent Yanks", nargs = "*" })
end

return M
