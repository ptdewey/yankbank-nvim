local telescope = require("telescope")
local yankbank = require("yankbank.telescope")

return telescope.register_extension {
    setup = function(ext_config, config)
        -- access extension config and user config
    end,
    exports = {
        yankbank = function()
            local yanks = require("yankbank.init").yanks
            local reg_types = require("yankbank.init").reg_types
            yankbank.yankbank(yanks, reg_types)
        end,
    },
}
