-- init.lua
local M = {}

-- local imports
local menu = require("yankbank.menu")
local clipboard = require("yankbank.clipboard")

-- initialize yanks tables
local yanks = {}
local max_entries = 10

-- wrapper function for main plugin functionality
local function show_yank_bank()
    -- TODO: update max entries with passed in options
    local bufnr, display_lines, line_yank_map = menu.create_and_fill_buffer(yanks, max_entries)
    local win_id = menu.open_window(bufnr, display_lines)
    menu.set_keymaps(win_id, bufnr, yanks, line_yank_map)
end

-- plugin setup
function M.setup(opts)
    local o = {}

    -- parse opts
    if opts ~= nil then
        o.max_entries = opts.max_entries or max_entries
    else
        o.max_entries = max_entries
    end

    -- create clipboard autocmds
    clipboard.setup_yank_autocmd(yanks, o.max_entries)

    -- Create user command
    -- TODO: allow params (i.e. keymaps/max_entries/separator)
    vim.api.nvim_create_user_command("YankBank", show_yank_bank,
        { desc = "Show Recent Yanks" })
end

return M
