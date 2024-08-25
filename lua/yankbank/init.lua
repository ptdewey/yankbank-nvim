local M = {}

-- local imports
local menu = require("yankbank.menu")
local clipboard = require("yankbank.clipboard")
local persistence = require("yankbank.persistence")

-- initialize yanks tables
local yanks = {}
local reg_types = {}

-- default plugin options
local default_opts = {
    max_entries = 10,
    sep = "-----",
    focus_gain_poll = false,
    num_behavior = "prefix",
    registers = {
        yank_register = "+",
    },
    persist_type = "memory",
    keymaps = {},
}

--- wrapper function for main plugin functionality
---@param opts table
local function show_yank_bank(opts)
    yanks = persistence.get_yanks(opts) or yanks

    -- initialize buffer and populate bank
    local bufnr, display_lines, line_yank_map =
        menu.create_and_fill_buffer(yanks, reg_types, opts)

    -- handle empty bank case
    if not bufnr or not display_lines or not line_yank_map then
        return
    end

    -- open window and set keybinds
    local win_id = menu.open_window(bufnr, display_lines)
    menu.set_keymaps(win_id, bufnr, yanks, reg_types, line_yank_map, opts)
end

-- plugin setup
---@param opts? table
function M.setup(opts)
    -- merge opts with default options table
    opts = vim.tbl_deep_extend("keep", opts or {}, default_opts)

    -- enable persistence based on opts (needs to be called before autocmd setup)
    yanks, reg_types = persistence.setup(opts)

    -- create clipboard autocmds
    clipboard.setup_yank_autocmd(yanks, reg_types, opts)

    -- create user command
    vim.api.nvim_create_user_command("YankBank", function()
        show_yank_bank(opts)
    end, { desc = "Show Recent Yanks" })
end

return M
