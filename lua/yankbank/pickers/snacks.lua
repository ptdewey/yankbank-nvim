-- luacheck: globals Snacks
local M = {}

local state = require("yankbank.state")
---@type snacks.picker.Config
M.source = {
    title = "YankBank",
    finder = function()
        local yanks = require("yankbank").get_yanks()

        local items = {}
        for i = 1, #yanks, 1 do
            local yank = yanks[i]
            local yank_value = yank:gsub("\n", "\\n"):gsub("\r", "\\r")
            table.insert(items, {
                text = ("%s: %s"):format(i, yank_value),
                label = tostring(i),
                reg = tostring(i),
                data = yank,
                value = yank_value,
                preview = {
                    text = yank,
                    -- Currently this is pinned to the current buffer's filetype
                    -- as we don't store the filetype of each yank.
                    -- This should be sufficient, as you would usually want to
                    -- paste into the same filetype you yanked from.
                    ft = vim.bo.filetype,
                },
            })
        end
        return items
    end,
    format = "register",
    preview = "preview",
    confirm = { "paste", "close" },
}

function M.setup()
    if Snacks and pcall(require, "snacks.picker") then
        Snacks.picker.sources.yankbank =
            require("yankbank.pickers.snacks").source
    end
    vim.api.nvim_create_user_command("YankBankSnacks", function()
        if Snacks and pcall(require, "yankbank.pickers.snacks") then
            Snacks.picker(require("yankbank.pickers.snacks").source)
        else
            vim.notify("Yank bank: Snacks is not loaded", vim.log.levels.ERROR)
        end
    end, {
        desc = "Open yankbank in snacks picker",
    })
end

return M
