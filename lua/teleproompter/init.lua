local Lists = require("teleproompter.lists")
local Commands = require("teleproompter.commands")
local Ui = require("teleproompter.ui")
local Utils = require("teleproompter.utils")

--- @class KeyMapsOpts
--- @field add_context string
--- @field add_resources string
--- @field add_instructions string
--- @field toggle_context string
--- @field toggle_cmd_context string
--- @field toggle_resources string
--- @field toggle_instructions string
--- @field show_all_lists string
--- @field show_all_telescope string
--- @field copy_all string
--- @field add_command string
--- @field exec_commands string
--- @field copy_everything string
--- @field telescope_toggle string

--- @class TeleProompterOpts
--- @field lists ListsOpts
--- @field keymaps KeyMapsOpts
local default_opts = {
    lists = {
        context_list = "__teleproompter_context_list__",
        cmd_context_list = "__teleproompter_cmd_context_list__",
        resources_list = "__teleproompter_resources_list__",
        instructions_list = "__teleproompter_instructions_list__"
    },
    keymaps = {
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

--- Main entry point for teleproompter plugin
--- @class TeleProompter
--- @field lists List
--- @field keymaps KeyMapsOpts
--- @field commands Commands
--- @field utils Utils
local Teleproompter = {}
Teleproompter.__index = Teleproompter

-- Setup function to configure teleproompter
---@param opts? TeleProompterOpts
function Teleproompter.setup(opts)
    local instance = Teleproompter:new(opts)
    print(instance.lists.context_list)
    instance:setup_keymaps()
    return instance
end

---@param user_opts? TeleProompterOpts
---@return TeleProompter
function Teleproompter:new(user_opts)
    local opts = vim.tbl_deep_extend("force", default_opts, user_opts or {})

    local list = Lists:new(opts.lists)
    local commands = Commands:new(list)
    local utils = Utils:new(list, commands)
    -- Store references
    local proompt = setmetatable({
        config = opts,
        lists = list, -- Fixed: Changed 'list' to 'lists' to match the field name used in setup_keymaps
        commands = commands,
        utils = utils,
        keymaps = opts.keymaps,
    }, self)

    return proompt
end

-- Keymaps setup function
function Teleproompter:setup_keymaps()
    print("caca")
    local keymaps = self.keymaps
    local lists = self.lists
    local harpoon = require("harpoon")

    -- Main list operations
    vim.keymap.set("n", keymaps.add_context, function() harpoon:list(lists.context_list):add() end)
    vim.keymap.set("n", keymaps.add_resources, function() harpoon:list(lists.resources_list):add() end)
    vim.keymap.set("n", keymaps.add_instructions, function() harpoon:list(lists.instructions_list):add() end)

    -- Toggle menus
    vim.keymap.set("n", keymaps.toggle_context,
        function() harpoon.ui:toggle_quick_menu(harpoon:list(lists.context_list)) end)
    vim.keymap.set("n", keymaps.toggle_cmd_context,
        function() harpoon.ui:toggle_quick_menu(harpoon:list(lists.cmd_context_list)) end)
    vim.keymap.set("n", keymaps.toggle_resources,
        function() harpoon.ui:toggle_quick_menu(harpoon:list(lists.resources_list)) end)
    vim.keymap.set("n", keymaps.toggle_instructions,
        function() harpoon.ui:toggle_quick_menu(harpoon:list(lists.instructions_list)) end)

    -- Telescope integration
    vim.keymap.set("n", keymaps.telescope_toggle, function() Ui.toggle_telescope(harpoon:list()) end,
        { desc = "Open harpoon window" })

    -- Clipboard operations
    vim.keymap.set("n", keymaps.copy_all, function() self.utils:copy_all_items_to_clipboard() end,
        { desc = "Copy contents of all marked files to clipboard" })
    vim.keymap.set("n", keymaps.add_command, function() self.commands:add_command_to_list() end,
        { desc = "Add command to CMD_CONTEXT list" })
    vim.keymap.set("n", keymaps.exec_commands, function() self.commands:execute_commands_and_copy_output() end,
        { desc = "Execute commands and copy output to clipboard" })
    vim.keymap.set("n", keymaps.copy_everything, function() self.utils:copy_everything_to_clipboard() end,
        { desc = "Copy all content and command outputs to clipboard" })

    -- For UI operations, if Ui is a module not an instance, use function wrapper
    vim.keymap.set("n", keymaps.show_all_lists, function() Ui.show_all_lists_window(self.lists) end,
        { desc = "Show all harpoon lists in one window" })
    vim.keymap.set("n", keymaps.show_all_telescope, function() Ui.show_all_lists_telescope(self.lists) end,
        { desc = "Show all harpoon lists in telescope" })
end

return Teleproompter
