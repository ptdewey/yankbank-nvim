-- init.lua
local M = {}

-- local imports
local menu = require("yankbank.menu")
local clipboard = require("yankbank.clipboard")
local telescope = require("yankbank.telescope")

-- initialize yanks tables
local yanks = {}
local reg_types = {}
local default_opts = {
    max_entries = 10,
    sep = "-----",
    focus_gain_poll = false,
    num_behavior = "prefix",
    registers = {
        yank_register = "+",
    },
    keymaps = {},
}

-- wrapper function for main plugin functionality
local function show_yank_bank(opts)
    -- Parse command arguments directly if args are provided as a string
    opts = opts or default_opts

    -- initialize buffer and populate bank
    local bufnr, display_lines, line_yank_map = menu.create_and_fill_buffer(
        yanks,
        reg_types,
        opts.max_entries,
        opts.sep
    )

    -- handle empty bank case
    if not bufnr then
        return
    end

    -- open window and set keybinds
    local win_id = menu.open_window(bufnr, display_lines)
    menu.set_keymaps(win_id, bufnr, yanks, reg_types, line_yank_map, opts)
    return
end

-- plugin setup
function M.setup(opts)
    opts = opts or default_opts

    -- create clipboard autocmds
    clipboard.setup_yank_autocmd(yanks, reg_types, opts)

    -- Create user command
    vim.api.nvim_create_user_command("YankBank", function(args)
        show_yank_bank(opts)
    end, { desc = "Show Recent Yanks" })

    -- Add a command for Telescope integration
    vim.api.nvim_create_user_command("TelescopeYankBank", function()
        require("yankbank.telescope").yankbank(yanks, reg_types)
    end, { desc = "Show Recent Yanks with Telescope" })
end

-- Expose yanks and reg_types for external access
M.yanks = yanks
M.reg_types = reg_types

return M
function M.setup(opts)
    opts = opts or default_opts

    -- create clipboard autocmds
    clipboard.setup_yank_autocmd(yanks, reg_types, opts)

    -- Create user command
    vim.api.nvim_create_user_command("YankBank", function(args)
        show_yank_bank(opts)
    end, { desc = "Show Recent Yanks" })

end

return M
