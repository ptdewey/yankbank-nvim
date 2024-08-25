local M = {}

-- local imports
local menu = require("yankbank.menu")
local clipboard = require("yankbank.clipboard")
local persistence = require("yankbank.persistence")

YANKS = {}
REG_TYPES = {}
OPTS = {}

-- default plugin options
local default_opts = {
    max_entries = 10,
    sep = "-----",
    focus_gain_poll = false,
    num_behavior = "prefix",
    registers = {
        yank_register = "+",
    },
    persist_type = nil,
    keymaps = {},
}

--- wrapper function for main plugin functionality
local function show_yank_bank()
    YANKS = persistence.get_yanks() or YANKS

    -- initialize buffer and populate bank
    local buf_data = menu.create_and_fill_buffer()
    if not buf_data then
        return
    end

    -- open popup window
    buf_data.win_id = menu.open_window(buf_data)

    -- set popup keybinds
    menu.set_keymaps(buf_data)
end

-- plugin setup
---@param opts? table
function M.setup(opts)
    -- merge opts with default options table
    OPTS = vim.tbl_deep_extend("keep", opts or {}, default_opts)

    -- enable persistence based on opts (needs to be called before autocmd setup)
    YANKS, REG_TYPES = persistence.setup()

    -- create clipboard autocmds
    clipboard.setup_yank_autocmd()

    -- create user command
    vim.api.nvim_create_user_command("YankBank", function()
        show_yank_bank()
    end, { desc = "Show Recent Yanks" })
end

return M
