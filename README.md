# YankBank
A Neovim plugin for keeping track of more recent yanks and deletions and exposing them in a quick access menu.

## What it Does
YankBank stores the N recent yanks into the unnamed register ("), then populates a popup window with these recent yanks, allowing for quick access to recent yank history.
Upon opening the popup menu, the current contents of the unnamedplus (+) register are also added to the menu (if they are different than the current contents of the unnamed register).

Choosing an entry from the menu (by hitting enter) will paste it into the currently open buffer at the cursor position.

Popup window:
![YankBank popup window](assets/screenshot-1.png)

The menu is specific to the current session, and will only contain the contents of the current unnamedplus register upon opening in a completely new session.
It will be populated further for each yank or deletion in that session.

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

The setup function also supports taking in a table of options:
| Option | Type | Default |
|-------------|--------------------------------------------|----------------|
| max_entries | integer number of entries to show in popup | 10 |
| sep | string separator to show between table entries | "-----" |


If no separator is desired, pass in an empty string for sep:
```lua
    config = function()
        require('yankbank').setup({
            max_entries = 12,
            sep = "",
        })
    end,
```

## Usage

The popup menu can be opened with the command:`:YankBank`, an entry is pasted at the current cursor position by hitting enter, and the menu can be closed by hitting escape, ctrl-c, or q.
An entry from the menu can also be yanked into the unnamed register by hitting yy.

I would personally also recommend setting a keybind to open the menu.
```lua
-- map to '<leader>y'
vim.keymap.set("n", "<leader>y", ":YankBank<CR>", { noremap = true })
```

## Potential Improvements
- Expose popup keybind behavior through setup options
- Access to other registers (number/letter registers?)
- Polling on unnamedplus register to populate bank in more intuitive manner (could be enabled as option)

