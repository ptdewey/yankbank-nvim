-- init.lua
local M = {}

-- local imports
local menu = require("yankbank.menu")
local clipboard = require("yankbank.clipboard")

-- initialize yanks tables
local yanks = {}
local reg_types = {}
local max_entries = 10
local sep = "-----"

-- wrapper function for main plugin functionality
local function show_yank_bank(opts)
    -- Parse command arguments directly if args are provided as a string
    opts = opts or {}

    -- Fallback to defaults if necessary
    local max_entries_opt = opts.max_entries or max_entries
    local sep_opt = opts.sep or sep
    opts.keymaps = opts.keymaps or {}

    local bufnr, display_lines, line_yank_map =
        menu.create_and_fill_buffer(yanks, reg_types, max_entries_opt, sep_opt)
    -- handle empty bank case
    if not bufnr then
        return
    end
    local win_id = menu.open_window(bufnr, display_lines)
    menu.set_keymaps(win_id, bufnr, yanks, reg_types, line_yank_map, opts)
end

-- plugin setup
function M.setup(opts)
    opts = opts or {}

    -- parse opts
    max_entries = opts.max_entries or max_entries

    -- create clipboard autocmds
    clipboard.setup_yank_autocmd(yanks, reg_types, opts)

    -- Create user command
    vim.api.nvim_create_user_command("YankBank", function()
        show_yank_bank(opts)
    end, { desc = "Show Recent Yanks" })
end

return M
