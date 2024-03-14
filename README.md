# YankBank
A Neovim plugin for keeping track of more recent yanks and deletions and exposing them in a quick to access menu.

## What it Does
<!-- TODO: screenshots -->
<!-- TODO: talk about how the menu populates-->
TODO:


## Installation and Setup

Lazy:
```lua
{
    "ptdewey/yankbank-nvim",
    config = function()
        require('yankbank').setup()
    end,
}
```

Packer:
```lua
use {
    'ptdewey/yankbank-nvim',
    config = function()
        require('yankbank').setup()
    end,
}
```

## Usage

The popup menu can be opened with the command:`:YankBank`, an entry is pasted at the current cursor position by hitting enter, and the menu can be closed by hitting escape, ctrl-c, or q.

I would personally also recommend setting a keybind to open the menu.
```lua
-- map to '<leader>y'
vim.keymap.set("n", "<leader>y", ":YankBank<CR>", { noremap = true })
```

