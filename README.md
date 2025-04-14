# Teleproompter Plugin for Neovim

Teleproompter is a plugin that extends Harpoon to enable quick creation, management, and usage of context files for LLM prompting. It allows you to organize files into different categories (context, resources, instructions) and put results of command executions inside the prompt.

## Problems

1. Instead of pivoting to AI editors, you'd rather integrate your LLM prompting framework into the optimized
file navigation and text editing capabilities from Neovim.

2. You want to specifically craft the LLM prompt you know is right for the task at hand, wihtout relying
on it crawling all of your codebase, wasting time and tokens away.

3. You're a cheap f*ck that lives in Europe and codes 16 hours a day, so you can't afford to send 60 M tokens to Claude per day
(but you have a Claude pro subscription and the chat is way cheaper than the API).

## Solutions

* You probably already have the context your LLM needs in your head. And as a neovim user bent on having a navigation
system where everything you need is at your fingertips, it is probably also in harpoon. So using harpoon as a source
for a list of file and commands to give to a LLM sounds like a good idea.

* So the whole workflow would be putting project files into separate harpoon lists representing specific parts of the prompt, 
have a way to visualize all these files and navigate to it instantly to edit them, and finally, craft the output from the file
content and the command outputs.

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

Teleproompter organizes files into four different lists:

2. **Context List** - Files containing context information for LLM prompts
3. **Resources List** - Reference files or resources
4. **Instructions List** - Files containing instructions for LLMs
5. **Command Context List** - Shell commands to execute

### Default Keybindings

#### Adding Files to Lists
- `<leader>c` - Add current file to context list
- `<leader>r` - Add current file to resources list
- `<leader>i` - Add current file to instructions list

#### Adding Commands
- `<leader>tc` - Add a command to the command context list

#### Toggling Lists
- `<leader>lc` - Toggle context list
- `<leader>lt` - Toggle command context list
- `<leader>lr` - Toggle resources list
- `<leader>li` - Toggle instructions list
- `<leader>la` - Show all lists in a single window
- `<leader>ls` - Show all lists in telescope

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

## License

MIT
