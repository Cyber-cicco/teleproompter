-- Command execution functions for teleproompter
local commands = {}

-- Reference to main module
local _M = nil

-- Function to add a command to the CMD_CONTEXT list
function commands.add_command_to_list()
    if not _M then
        error("Commands module not initialized")
    end

    local lists = _M.lists
    local harpoon = _M.harpoon

    vim.ui.input({ prompt = "Enter command: " }, function(cmd)
        if cmd and cmd ~= "" then
            harpoon:list(lists.CMD_CONTEXT):append({
                value = cmd,
                context = { cmd = cmd }
            })
            vim.notify("Added command to CMD_CONTEXT list: " .. cmd)
        end
    end)
end

-- Function to execute commands from CMD_CONTEXT list and copy output to clipboard
function commands.execute_commands_and_copy_output()
    if not _M then
        error("Commands module not initialized")
    end

    local lists = _M.lists
    local harpoon = _M.harpoon
    local all_outputs = {}

    for i, item in ipairs(harpoon:list(lists.CMD_CONTEXT).items) do
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

-- Function to execute a single command and return its output
function commands.execute_command(cmd)
    if not cmd or cmd == "" then
        return nil, "Empty command"
    end

    local output = vim.fn.system(cmd)
    return output
end

-- Initialize the module with a reference to the main module
function commands.init(main_module)
    _M = main_module
    return commands
end

return commands
