local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local sorters = require("telescope.sorters")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local M = {}

function M.yankbank_picker(yanks, reg_types)
    pickers.new({}, {
        prompt_title = "YankBank",
        finder = finders.new_table({
            results = yanks,
            entry_maker = function(entry)
                return {
                    value = entry,
                    display = entry:gsub("\n", "\\n"),
                    ordinal = entry,
                }
            end,
        }),
        sorter = sorters.get_generic_fuzzy_sorter(),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                if selection then
                    local text = selection.value
                    local reg_type = reg_types[vim.tbl_index(yanks, text)]
                    require("yankbank.helpers").smart_paste(text, reg_type)
                end
            end)
            return true
        end,
    }):find()
end

return M
