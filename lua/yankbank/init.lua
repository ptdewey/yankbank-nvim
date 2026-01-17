local M = {}

local initialized = false

function M.ensure_initialized()
    if initialized then
        return
    end

    local state = require("yankbank.state")
    local persistence = require("yankbank.persistence")

    -- enable persistence based on opts (needs to be called before autocmd setup)
    local yanks, reg_types, pins = persistence.setup()
    state.init(yanks, reg_types, pins, state.get_opts())
    initialized = true
end

--- wrapper function for main plugin functionality
local function show_yank_bank()
    M.ensure_initialized()

    local state = require("yankbank.state")
    local menu = require("yankbank.menu")

    -- set up menu keybinds from defaults and state.get_opts().keymaps
    menu.setup()

    local persistence = require("yankbank.persistence")
    local yanks = persistence.get_yanks() or state.get_yanks()
    state.set_yanks(yanks)

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
        pickers = {},
    }

    -- merge opts with default options table
    local merged_opts = vim.tbl_deep_extend("keep", opts or {}, default_opts)

    -- store config in state module (lazy loaded when needed)
    local state = require("yankbank.state")
    state.set_opts(merged_opts)

    -- create user command
    vim.api.nvim_create_user_command("YankBank", function()
        show_yank_bank()
    end, { desc = "Show Recent Yanks" })

    -- create clipboard autocmds
    require("yankbank.clipboard").setup_yank_autocmd()

    -- Bind 1-n if `bind_indices` is set to a string
    if merged_opts.bind_indices then
        for i = 1, merged_opts.max_entries do
            vim.keymap.set("n", merged_opts.bind_indices .. i, function()
                M.ensure_initialized()
                require("yankbank.helpers").smart_paste(
                    state.get_yanks()[i],
                    state.get_reg_types()[i],
                    true
                )
            end, {
                noremap = true,
                silent = true,
                desc = "Paste YankBank entry " .. i,
            })
        end
    end

    if merged_opts.pickers.snacks then
        require("yankbank.pickers.snacks").setup()
    end
end

return M
