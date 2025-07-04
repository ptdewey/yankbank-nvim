local M = {}

-- define global variables
YB_YANKS = {}
YB_REG_TYPES = {}
YB_PINS = {}
YB_OPTS = {}

-- local imports
local menu = require("yankbank.menu")
local clipboard = require("yankbank.clipboard")
local persistence = require("yankbank.persistence")
local helpers = require("yankbank.helpers")

-- default plugin options
local default_opts = {
    max_entries = 10,
    sep = "-----",
    focus_gain_poll = false,
    num_behavior = "prefix",
    registers = {
        yank_register = "+",
    },
    keymaps = {},
    persist_type = nil,
    db_path = nil,
    bind_indices = nil,
}

--- wrapper function for main plugin functionality
local function show_yank_bank()
    YB_YANKS = persistence.get_yanks() or YB_YANKS

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
    YB_OPTS = vim.tbl_deep_extend("keep", opts or {}, default_opts)

    -- set up menu keybinds from defafaults and YB_OPTS.keymaps
    menu.setup()

    -- enable persistence based on opts (needs to be called before autocmd setup)
    YB_YANKS, YB_REG_TYPES, YB_PINS = persistence.setup()

    -- create clipboard autocmds
    clipboard.setup_yank_autocmd()

    -- create user command
    vim.api.nvim_create_user_command("YankBank", function()
        show_yank_bank()
    end, { desc = "Show Recent Yanks" })

    -- Bind 1-n if `bind_indices` is set to a string
    if YB_OPTS.bind_indices then
        for i = 1, YB_OPTS.max_entries do
            vim.keymap.set("n", YB_OPTS.bind_indices .. i, function()
                helpers.smart_paste(YB_YANKS[i], YB_REG_TYPES[i], true)
            end, {
                noremap = true,
                silent = true,
                desc = "Paste YankBank entry " .. i,
            })
        end
    end
end

return M
