local Lists = require("teleproompter.lists")
local Commands = require("teleproompter.commands")
local Ui = require("teleproompter.ui")
local Utils = require("teleproompter.utils")

--- @class KeyMapsOpts
--- @field lists table<string, string> Map of list keys to their add keymaps
--- @field toggle_lists table<string, string> Map of list keys to their toggle keymaps
--- @field show_all_lists string
--- @field show_all_telescope string
--- @field copy_all string
--- @field add_command string
--- @field exec_commands string
--- @field copy_everything string
--- @field telescope_toggle string

--- @class TeleProompterOpts
--- @field lists table<string, ListConfig>
--- @field keymaps KeyMapsOpts
--- @field system_prompt_file string Path to system prompt file
--- @field default_system_prompt string Default system prompt text
local default_opts = {
    lists = {
        context = {
            type = "file",
            title = "Context",
            list_name = "__teleproompter_context_list__",
            order = 1,
            key = "context",
        },
        cmd_context = {
            type = "command",
            title = "Command Context",
            list_name = "__teleproompter_cmd_context_list__",
            order = 2,
            key = "cmd_context",
        },
        resources = {
            type = "file",
            title = "Resources",
            list_name = "__teleproompter_resources_list__",
            order = 3,
            key = "resources",
        },
        instructions = {
            type = "file",
            title = "Instructions",
            list_name = "__teleproompter_instructions_list__",
            order = 4,
            key = "instructions",
        }
    },
    keymaps = {
        lists = {
            context = "<leader>c",
            resources = "<leader>r",
            instructions = "<leader>i"
        },
        toggle_lists = {
            context = "<leader>lc",
            cmd_context = "<leader>lt",
            resources = "<leader>lr",
            instructions = "<leader>li"
        },
        show_all_lists = "<leader>la",
        show_all_telescope = "<leader>ls",
        copy_all = "<leader>yc",
        add_command = "<leader>tc",
        exec_commands = "<leader>ye",
        copy_everything = "<leader>ya",
        telescope_toggle = "<C-e>"
    },
    -- Default system prompt configuration
    system_prompt_file = vim.fn.stdpath("config") .. "/teleproompter_system_prompt.md",
    default_system_prompt = [[
# System Prompt
You are a helpful AI assistant. You will be given context, instructions, and resources to help you respond to the user's request.

1. First, carefully read and understand any context provided
2. Follow the instructions given to you precisely
3. Use the resources provided to inform your response
4. Be concise yet thorough in your answers
5. If you're unsure about something, acknowledge the uncertainty rather than making assumptions
]]
}

--- Main entry point for teleproompter plugin
--- @class TeleProompter
--- @field lists List
--- @field keymaps KeyMapsOpts
--- @field commands Commands
--- @field utils Utils
--- @field config TeleProompterOpts
local Teleproompter = {}
Teleproompter.__index = Teleproompter

-- Setup function to configure teleproompter
---@param opts? TeleProompterOpts
function Teleproompter.setup(opts)
    local instance = Teleproompter:new(opts)
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
    
    -- Pass the configuration to utils for system prompt handling
    utils.config = opts
    
    -- Store references
    local proompt = setmetatable({
        config = opts,
        lists = list,
        commands = commands,
        utils = utils,
        keymaps = opts.keymaps,
    }, self)

    return proompt
end

-- Keymaps setup function
function Teleproompter:setup_keymaps()
    local keymaps = self.keymaps
    local lists = self.lists
    local harpoon = require("harpoon")

    -- Setup keymaps for adding files to lists
    if keymaps.lists then
        for list_key, keymap in pairs(keymaps.lists) do
            local list_name = lists:get_list_name(list_key)
            if list_name then
                vim.keymap.set("n", keymap, function()
                    harpoon:list(list_name):add()
                end, { desc = "Add current file to " .. lists:get_list_title(list_key) .. " list" })
            end
        end
    end

    -- Setup toggle menus for lists
    if keymaps.toggle_lists then
        for list_key, keymap in pairs(keymaps.toggle_lists) do
            local list_name = lists:get_list_name(list_key)
            if list_name then
                vim.keymap.set("n", keymap, function()
                    harpoon.ui:toggle_quick_menu(harpoon:list(list_name))
                end, { desc = "Toggle " .. lists:get_list_title(list_key) .. " list menu" })
            end
        end
    end

    -- Telescope integration
    vim.keymap.set("n", keymaps.telescope_toggle, function()
        Ui.toggle_telescope(harpoon:list())
    end, { desc = "Open harpoon window" })

    -- Clipboard operations
    vim.keymap.set("n", keymaps.copy_all, function()
        self.utils:copy_all_items_to_clipboard()
    end, { desc = "Copy contents of all marked files to clipboard" })

    vim.keymap.set("n", keymaps.add_command, function()
        self.commands:add_command_to_list()
    end, { desc = "Add command to CMD_CONTEXT list" })

    vim.keymap.set("n", keymaps.exec_commands, function()
        self.commands:execute_commands_and_copy_output()
    end, { desc = "Execute commands and copy output to clipboard" })

    vim.keymap.set("n", keymaps.copy_everything, function()
        self.utils:copy_everything_to_clipboard()
    end, { desc = "Copy all content and command outputs to clipboard" })

    -- For UI operations
    vim.keymap.set("n", keymaps.show_all_lists, function()
        Ui.show_all_lists_window(self.lists)
    end, { desc = "Show all harpoon lists in one window" })

    vim.keymap.set("n", keymaps.show_all_telescope, function()
        Ui.show_all_lists_telescope(self.lists)
    end, { desc = "Show all harpoon lists in telescope" })
end

return Teleproompter
