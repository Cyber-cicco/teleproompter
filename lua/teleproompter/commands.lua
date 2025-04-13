--- @class Commands
--- @field list ListsOpts
local Commands = {}
Commands.__index = Commands


---@param list List
function Commands:new(list)
    local cmd = setmetatable({
        list = list
    }, self)
    return cmd
end

-- Function to add a command to the CMD_CONTEXT list
function Commands:add_command_to_list()

    local harpoon = require("harpoon")

    vim.ui.input({ prompt = "Enter command: " }, function(cmd)
        if cmd and cmd ~= "" then
            harpoon:list(self.list.cmd_context_list):append({
                value = cmd,
                context = { cmd = cmd }
            })
            vim.notify("Added command to CMD_CONTEXT list: " .. cmd)
        end
    end)
end

--- Function to execute commands from CMD_CONTEXT list and copy output to clipboard
function Commands:execute_commands_and_copy_output()

    local harpoon = require("harpoon")
    local all_outputs = {}

    for i, item in ipairs(harpoon:list(self.list.cmd_context_list).items) do
        local cmd = item.value
        vim.notify("Executing command: " .. cmd)

        local output = vim.fn.system(cmd)
        if output then
            table.insert(all_outputs, "### Command " .. i .. ": " .. cmd .. " ###\n\n" .. output .. "\n\n")
        else
            table.insert(all_outputs,
                "### Command " .. i .. ": " .. cmd .. " ###\n\n" .. "[No output or error occurred]\n\n")
        end
    end

    if #all_outputs > 0 then
        local combined_output = table.concat(all_outputs, "")
        vim.fn.setreg("+", combined_output)
        vim.notify("Copied output of all commands to clipboard")
    else
        vim.notify("No commands found in CMD_CONTEXT list")
    end
end

--- comment
--- @param cmd? string
--- @return string?, string?
function Commands.execute_command(cmd)
    if not cmd or cmd == "" then
        return nil, "Empty command"
    end

    local output = vim.fn.system(cmd)
    return output
end

return Commands

