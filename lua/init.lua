-- Main entry point for teleproompter plugin
local teleproompter = {}

-- Import submodules
teleproompter.lists = require("teleproompter.lists")
teleproompter.commands = require("teleproompter.commands")
teleproompter.ui = require("teleproompter.ui")
teleproompter.utils = require("teleproompter.utils")

-- Setup function that will be called from user config
function teleproompter.setup(opts)
    -- Default configuration
    local default_opts = {
        lists = {
            context_list = "__teleproompter_context_list__",
            cmd_context_list = "__teleproompter_cmd_context_list__",
            resources_list = "__teleproompter_resources_list__",
            instructions_list = "__teleproompter_instructions_list__"
        },
        keymaps = {
            -- Default keymaps
            add_context = "<leader>c",
            add_resources = "<leader>r",
            add_instructions = "<leader>i",
            toggle_context = "<leader>lc",
            toggle_cmd_context = "<leader>lt",
            toggle_resources = "<leader>lr",
            toggle_instructions = "<leader>li",
            show_all_lists = "<leader>la",
            show_all_telescope = "<leader>ls",
            copy_all = "<leader>yc",
            add_command = "<leader>tc",
            exec_commands = "<leader>ye",
            copy_everything = "<leader>ya",
            telescope_toggle = "<C-e>"
        }
    }

    -- Merge user options with defaults
    opts = vim.tbl_deep_extend("force", default_opts, opts or {})

    -- Initialize harpoon
    local harpoon = require("harpoon")
    harpoon:setup()

    -- Store references
    teleproompter.harpoon = harpoon
    teleproompter.config = opts

    -- Initialize lists
    teleproompter.lists.init(teleproompter)

    -- Setup keymaps
    teleproompter.setup_keymaps()

    return teleproompter
end

-- Keymaps setup function
function teleproompter.setup_keymaps()
    local conf = teleproompter.config
    local keymaps = conf.keymaps
    local harpoon = teleproompter.harpoon
    local lists = teleproompter.lists

    -- Main list operations
    vim.keymap.set("n", keymaps.add_context, function() harpoon:list(lists.CONTEXT):add() end)
    vim.keymap.set("n", keymaps.add_resources, function() harpoon:list(lists.RESOURCES):add() end)
    vim.keymap.set("n", keymaps.add_instructions, function() harpoon:list(lists.INSTRUCTIONS):add() end)

    -- Toggle menus
    vim.keymap.set("n", keymaps.toggle_context, function() harpoon.ui:toggle_quick_menu(harpoon:list(lists.CONTEXT)) end)
    vim.keymap.set("n", keymaps.toggle_cmd_context,
        function() harpoon.ui:toggle_quick_menu(harpoon:list(lists.CMD_CONTEXT)) end)
    vim.keymap.set("n", keymaps.toggle_resources,
        function() harpoon.ui:toggle_quick_menu(harpoon:list(lists.RESOURCES)) end)
    vim.keymap.set("n", keymaps.toggle_instructions,
        function() harpoon.ui:toggle_quick_menu(harpoon:list(lists.INSTRUCTIONS)) end)

    -- Telescope integration
    vim.keymap.set("n", keymaps.telescope_toggle, function() teleproompter.ui.toggle_telescope(harpoon:list()) end,
        { desc = "Open harpoon window" })

    -- Clipboard operations
    vim.keymap.set("n", keymaps.copy_all, teleproompter.utils.copy_all_items_to_clipboard,
        { desc = "Copy contents of all marked files to clipboard" })
    vim.keymap.set("n", keymaps.add_command, teleproompter.commands.add_command_to_list,
        { desc = "Add command to CMD_CONTEXT list" })
    vim.keymap.set("n", keymaps.exec_commands, teleproompter.commands.execute_commands_and_copy_output,
        { desc = "Execute commands and copy output to clipboard" })
    vim.keymap.set("n", keymaps.copy_everything, teleproompter.utils.copy_everything_to_clipboard,
        { desc = "Copy all content and command outputs to clipboard" })

    -- UI operations
    vim.keymap.set("n", keymaps.show_all_lists, teleproompter.ui.show_all_lists_window,
        { desc = "Show all harpoon lists in one window" })
    vim.keymap.set("n", keymaps.show_all_telescope, teleproompter.ui.show_all_lists_telescope,
        { desc = "Show all harpoon lists in telescope" })
end

return teleproompter
