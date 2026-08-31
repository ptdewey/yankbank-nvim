-- luacheck: globals Snacks
local M = {}

---@type snacks.picker.Config
local snacks_source = {
    title = "YankBank",
    finder = function()
        local yanks = require("yankbank.api").get_all()
        local items = {}
        for i = 1, #yanks do
            local yank = yanks[i]
            local yank_text = yank.yank_text
            table.insert(items, {
                label = tostring(i),
                reg = tostring(i),
                -- This is not used right now, but might be useful in the future
                -- to determine how to paste the content
                reg_type = yank.reg_type,
                -- data is used as the paste content
                data = yank_text,
                -- text is used by the matcher for searching
                text = yank_text,
                -- value is used to display in the picker
                value = yank_text,
                preview = {
                    text = yank_text,
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
    confirm = function(picker, selected)
        picker:close()

        local state = require("yankbank.state")
        local opts = state.get_opts()
        if opts.registers.paste_register then
            -- place paste content back into register. This is helpful if you
            -- wanted to select a paste item from history and use it repeatedly
            vim.fn.setreg(opts.registers.paste_register, selected.value)
        end
    end,
}

function M.setup()
    if Snacks and Snacks.picker then
        Snacks.picker.sources.yankbank = snacks_source
    end
    vim.api.nvim_create_user_command("YankBankSnacks", function()
        if Snacks then
            Snacks.picker(snacks_source)
        else
            vim.notify("Yank bank: Snacks is not loaded", vim.log.levels.ERROR)
        end
    end, {
        desc = "Open yankbank in snacks picker",
    })
end

return M
