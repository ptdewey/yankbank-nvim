if vim.g.loaded_yankbank then
    return
end
vim.g.loaded_yankbank = 1

vim.api.nvim_create_user_command("YankBank", function()
    require("yankbank").show()
end, { desc = "Show Recent Yanks" })

vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("YankBank", { clear = true }),
    callback = function()
        local rn = vim.v.event.regname
        if rn ~= "" and rn ~= "+" then
            return
        end

        local yank_text = vim.fn.getreg(rn)
        if type(yank_text) ~= "string" or #yank_text <= 1 then
            return
        end

        local reg_type = vim.fn.getregtype(rn)
        require("yankbank").ensure_initialized()
        require("yankbank.clipboard").add_yank(yank_text, reg_type)
    end,
})
