# Teleproompter Plugin for Neovim

Teleproompter is a plugin that extends Harpoon to enable quick creation, management, and usage of context files for LLM prompting. It allows you to organize files into different categories (context, resources, instructions) and execute commands directly from Neovim.

## Prerequisites

The plugin requires:
- Neovim >= 0.7.0
- [Harpoon](https://github.com/ThePrimeagen/harpoon)
- [Telescope](https://github.com/nvim-telescope/telescope.nvim) (for advanced file navigation)

## Installation

### Using Packer

Add to your packer.lua file:

```lua
use {
    'yourusername/teleproompter',
    requires = {
        'ThePrimeagen/harpoon',
        'nvim-telescope/telescope.nvim'
    },
    config = function()
        require('teleproompter').setup()
    end
}
```

### Using Lazy.nvim

```lua
{
    'yourusername/teleproompter',
    dependencies = {
        'ThePrimeagen/harpoon',
        'nvim-telescope/telescope.nvim'
    },
    config = function()
        require('teleproompter').setup()
    end
}
```

### Manual Installation

Clone the repository:

```bash
git clone https://github.com/yourusername/teleproompter.git ~/.config/nvim/pack/plugins/start/teleproompter
```

Then add to your init.lua:

```lua
require('teleproompter').setup()
```

## Usage

### Basic Concepts

Teleproompter organizes files into four different lists:

1. **Main List** - Regular Harpoon file list
2. **Context List** - Files containing context information for LLM prompts
3. **Resources List** - Reference files or resources
4. **Instructions List** - Files containing instructions for LLMs
5. **Command Context List** - Shell commands to execute

### Default Keybindings

#### Adding Files to Lists
- `<leader>a` - Add current file to main list
- `<leader>c` - Add current file to context list
- `<leader>r` - Add current file to resources list
- `<leader>i` - Add current file to instructions list

#### Adding Commands
- `<leader>tc` - Add a command to the command context list

#### Toggling Lists
- `<leader>e` - Toggle main list
- `<leader>lc` - Toggle context list
- `<leader>lt` - Toggle command context list
- `<leader>lr` - Toggle resources list
- `<leader>li` - Toggle instructions list
- `<leader>la` - Show all lists in a single window
- `<leader>ls` - Show all lists in telescope

#### Navigation
- `&`, `é`, `"`, `'`, `(`, `-` - Navigate to items 1-6 in the main list
- `<leader>P` - Go to previous file in list
- `<leader>N` - Go to next file in list

#### Clipboard Operations
- `<leader>yc` - Copy contents of all marked files to clipboard
- `<leader>ye` - Execute commands and copy output to clipboard
- `<leader>ya` - Copy all content and command outputs to clipboard

### Customization

You can customize the plugin by passing options to the setup function:

```lua
require('teleproompter').setup({
    keymaps = {
        -- Override default keymaps
        add_main = "<leader>ha",
        add_context = "<leader>hc",
        -- ... other keymaps
    },
    lists = {
        -- Custom list names if needed
        context_list = "__my_context_list__",
        -- ... other list names
    }
})
```

## Converting from your existing setup

If you're currently using the harpoon setup from the original configuration, you can replace your `after/plugin/harpoon.lua` file with a simple setup:

```lua
-- after/plugin/teleproompter.lua
require('teleproompter').setup()
```

All your existing functionality should continue to work with the same keybindings.

## License

MIT
