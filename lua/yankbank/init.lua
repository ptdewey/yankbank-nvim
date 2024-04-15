-- init.lua
local M = {}

-- local imports
local menu = require("yankbank.menu")
local clipboard = require("yankbank.clipboard")
local persistence = require("yankbank.persistence")

-- initialize yanks tables
local yanks = {}
local reg_types = {}

local plugin_path = debug.getinfo(1).source:sub(2):match("(.*/).*/.*/") or "./"

-- default plugin options
local default_opts = {
    max_entries = 10,
    sep = "-----",
    persist_type = "memory",
    persist_path = plugin_path .. "bank.txt",
}

-- wrapper function for main plugin functionality
---@param opts table
local function show_yank_bank(opts)
    -- Parse command arguments directly if args are provided as a string

    local bufnr, display_lines, line_yank_map =
        menu.create_and_fill_buffer(yanks, reg_types, opts)

    -- handle empty bank case
    if not bufnr or not display_lines or not line_yank_map then
        return
    end

    local win_id = menu.open_window(bufnr, display_lines)
    menu.set_keymaps(win_id, bufnr, yanks, reg_types, line_yank_map, opts)
end

-- plugin setup
---@param opts table?
function M.setup(opts)
    -- merge opts with default options table
    opts = vim.tbl_deep_extend("force", default_opts, opts or {})

    -- create clipboard autocmds
    clipboard.setup_yank_autocmd(yanks, reg_types, opts)

    -- enable persistence based on opts
    yanks, reg_types = persistence.setup(yanks, reg_types, opts)
    -- print(vim.inspect(yanks))
    -- print(vim.inspect(reg_types))

    -- Create user command
    vim.api.nvim_create_user_command("YankBank", function()
        show_yank_bank(opts)
    end, { desc = "Show Recent Yanks" })
end

return M
