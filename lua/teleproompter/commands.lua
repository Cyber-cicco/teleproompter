-- Command-related functionality for teleproompter

--- @class Commands
--- @field lists List
local Commands = {}
Commands.__index = Commands

---@param lists List
---@return Commands
function Commands:new(lists)
    local commands = setmetatable({
        lists = lists
    }, self)
    return commands
end

-- Add a new command to the command context list
function Commands:add_command_to_list()
    local harpoon = require("harpoon")

    -- Find the command list (first list with type "command")
    local command_lists = self.lists:get_lists_by_type("command")
    if #command_lists == 0 then
        vim.notify("No command list found", vim.log.levels.ERROR)
        return
    end

    -- Use the first command list by default
    local cmd_list_key = command_lists[1].key
    local cmd_list_name = command_lists[1].config.list_name

    -- Prompt user for command
    vim.ui.input({
        prompt = "Enter command: "
    }, function(input)
        if input and input ~= "" then
            -- Add command to list
            harpoon:list(cmd_list_name):append({
                value = input,
                context = { type = "command" }
            })
            vim.notify("Command added to " .. self.lists:get_list_title(cmd_list_key) .. " list", vim.log.levels.INFO)
        end
    end)
end

-- Execute all commands in command lists and copy their output
function Commands:execute_commands_and_copy_output(copy_to_clipboard)
    -- Default to true if not specified
    if copy_to_clipboard == nil then
        copy_to_clipboard = true
    end

    local combined_output = ""
    local harpoon = require("harpoon")

    -- Get all command lists
    local command_lists = self.lists:get_lists_by_type("command")

    if #command_lists == 0 then
        vim.notify("No command lists found", vim.log.levels.WARN)
        return ""
    end

    -- Process each command list
    for _, list_info in ipairs(command_lists) do
        local list_key = list_info.key
        local list_config = list_info.config
        local items = harpoon:list(list_config.list_name).items

        if #items > 0 then
            combined_output = combined_output .. "### " .. list_config.title .. " Output ###\n\n"

            -- Execute each command in the list
            for _, item in ipairs(items) do
                local cmd = item.value
                vim.notify("Executing: " .. cmd, vim.log.levels.INFO)

                local success, result = pcall(vim.fn.system, cmd)

                if success then
                    combined_output = combined_output .. "### Command: " .. cmd .. " ###\n\n"
                    combined_output = combined_output .. result .. "\n\n"
                else
                    combined_output = combined_output .. "### Command: " .. cmd .. " ###\n\n"
                    combined_output = combined_output .. "Error executing command: " .. result .. "\n\n"
                end
            end
        end
    end

    -- Copy to clipboard if requested and there's output
    if copy_to_clipboard and combined_output ~= "" then
        vim.fn.setreg("+", combined_output)
        vim.notify("Command outputs copied to clipboard", vim.log.levels.INFO)
    end

    return combined_output
end

-- Execute a specific command and return its output
function Commands:execute_command(cmd)
    vim.notify("Executing: " .. cmd, vim.log.levels.INFO)
    local success, result = pcall(vim.fn.system, cmd)

    if success then
        return result
    else
        return "Error executing command: " .. result
    end
end

return Commands

