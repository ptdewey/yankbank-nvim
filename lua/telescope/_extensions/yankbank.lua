local telescope = require("telescope")
local yankbank = require("yankbank.telescope")

return telescope.register_extension {
    setup = function(ext_config, config)
        -- access extension config and user config
    end,
    exports = {
        yankbank = yankbank.yankbank,
    },
}
