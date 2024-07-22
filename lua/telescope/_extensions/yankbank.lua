local telescope = require("telescope")
local yankbank = require("yankbank.telescope")

local has_telescope, telescope = pcall(require, "telescope")

if not has_telescope then
    error("yankbank-nvim requires nvim-telescope/telescope.nvim")
end

return telescope.register_extension({
    exports = {
        yankbank = require("yankbank.telescope").yankbank,
    },
})
