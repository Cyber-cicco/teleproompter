# Teleproompter Plugin for Neovim

Teleproompter is a plugin that extends Harpoon to enable quick creation, management, and usage of context files for LLM prompting. It allows you to organize files into different categories (context, resources, instructions) and put results of command executions inside the prompt.

## Problems

1. Instead of pivoting to AI editors, you'd rather integrate your LLM prompting framework into the optimized
file navigation and text editing capabilities from Neovim.

2. You want to specifically craft the LLM prompt you know is right for the task at hand, without relying
on it crawling all of your codebase, wasting time and tokens away.

3. You're a cheap f*ck that lives in Europe and codes 16 hours a day, so you can't afford to send 60 M tokens to Claude per day
(but you have a Claude pro subscription and the chat is way cheaper than the API).

## Solutions

* You probably already have the context your LLM needs in your head. And as a neovim user bent on having a navigation
system where everything you need is at your fingertips, it is probably also in harpoon. So using harpoon as a source
for a list of file and commands to give to a LLM sounds like a good idea.

* So the whole workflow would be putting project files into separate harpoon lists representing specific parts of the prompt, 
have a way to visualize all these files and navigate to it instantly to edit them, and finally, craft the output from the file
content and the command outputs to put it in the clipboard.

## Prerequisites

The plugin requires:
- Neovim >= 0.10.0
- [Harpoon 2](https://github.com/ThePrimeagen/harpoon)
- [Telescope](https://github.com/nvim-telescope/telescope.nvim) 

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

Teleproompter organizes files into different lists, each with specific purposes:

1. **Context List** - Files containing context information for LLM prompts
2. **Command Context List** - Shell commands to execute and include their output
3. **Resources List** - Reference files or resources
4. **Instructions List** - Files containing instructions for LLMs

Each list is managed separately but can be viewed and manipulated together. The plugin leverages Harpoon's list functionality to maintain these lists.

### Default Keybindings

#### Adding Files to Lists
- `<leader>c` - Add current file to context list
- `<leader>r` - Add current file to resources list
- `<leader>i` - Add current file to instructions list

#### Toggling List Menus
- `<leader>lc` - Toggle context list menu
- `<leader>lt` - Toggle command context list menu
- `<leader>lr` - Toggle resources list menu
- `<leader>li` - Toggle instructions list menu

#### List Views
- `<leader>la` - Show all lists in a single window
- `<leader>ls` - Show all lists in Telescope
- `<C-e>` - Toggle Telescope with Harpoon integration

#### Commands
- `<leader>tc` - Add a command to the command context list

#### Clipboard Operations
- `<leader>yc` - Copy contents of all marked files to clipboard
- `<leader>ye` - Execute commands and copy output to clipboard
- `<leader>ya` - Copy all content and command outputs to clipboard

### List Management

When viewing lists, you can:
- Press `q` to close the list window
- Press `y` to copy all content to clipboard
- Press `o` to set item order (in the all lists view)

In Telescope view, you can:
- Press `<CR>` to select and open a file/execute a command
- Press `<C-y>` to copy the selected item's content

### Customization

You can customize the plugin by passing options to the setup function:

```lua
require('teleproompter').setup({
    -- Custom list configurations
    lists = {
        context = {
            type = "file",
            title = "My Context",
            list_name = "__my_context_list__",
            order = 1,
            key = "context",
        },
        custom_list = {
            type = "file",
            title = "Custom List",
            list_name = "__my_custom_list__",
            order = 5,
            key = "custom_list",
        },
        -- Add more custom lists as needed
    },
    
    -- Custom keymaps
    keymaps = {
        lists = {
            context = "<leader>mc",
            resources = "<leader>mr",
            instructions = "<leader>mi",
            custom_list = "<leader>mx"  -- For your custom list
        },
        toggle_lists = {
            context = "<leader>tc",
            cmd_context = "<leader>tt", 
            resources = "<leader>tr",
            instructions = "<leader>ti",
            custom_list = "<leader>tx"  -- For your custom list
        },
        show_all_lists = "<leader>ta",
        show_all_telescope = "<leader>ts",
        copy_all = "<leader>yp",
        add_command = "<leader>ac",
        exec_commands = "<leader>ec",
        copy_everything = "<leader>yy",
        telescope_toggle = "<C-t>"
    }
})
```

### List Configuration Structure

Each list is configured with the following properties:

- `type` - The list type, either "file" or "command"
- `title` - The display title for the list
- `list_name` - The internal name used by Harpoon
- `order` - The display order in combined views
- `key` - The identifier used in configurations and API calls

## Features

### UI Windows

Teleproompter provides various UI windows:
- Individual list menus (via Harpoon)
- Combined list view showing all lists in one window
- Command output displays
- Telescope integration for advanced filtering

### Command Execution

Commands added to the command list can be:
- Executed individually
- Executed all at once with output captured
- Included in the final clipboard output

### Telescope Integration

The plugin integrates with Telescope to provide:
- Advanced filtering of list items
- File previews
- Specialized actions for both files and commands

## License

MIT
