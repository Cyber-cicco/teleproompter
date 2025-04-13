-- Utility functions for teleproompter
--- @class Utils
--- @field lists List
--- @field commands Commands
local Utils = {}
Utils.__index = Utils

---@param lists List
---@param cmd Commands
function Utils:new(lists, cmd)
    return setmetatable({
        lists = lists,
        commands = cmd,
    }, self)
end

-- Read file contents safely
function Utils.read_file(file_path)
    local file = io.open(file_path, "r")
    if not file then
        return nil, "Could not open file: " .. file_path
    end

    local content = file:read("*all")
    file:close()
    return content
end

-- Function to copy contents of all items in lists to clipboard
function Utils:copy_all_items_to_clipboard()
    print("caca")

    local harpoon = require("harpoon")
    local lists = self.lists
    local all_contents = {}

    -- Get items from CONTEXT list
    for _, item in ipairs(harpoon:list(lists.context_list).items) do
        local file_path = item.value
        local content, err = self.read_file(file_path)
        if content then
            table.insert(all_contents, "### Context : " .. " ###\n\n" .. content .. "\n\n")
        else
            vim.notify("Error reading file " .. file_path .. ": " .. (err or "unknown error"), vim.log.levels.ERROR)
        end
    end

    -- Get items from RESOURCES list
    for _, item in ipairs(harpoon:list(lists.resources_list).items) do
        local file_path = item.value
        local content, err = self.read_file(file_path)
        if content then
            table.insert(all_contents, "### " .. file_path .. " ###\n\n" .. content .. "\n\n")
        else
            vim.notify("Error reading file " .. file_path .. ": " .. (err or "unknown error"), vim.log.levels.ERROR)
        end
    end

    -- Get items from INSTRUCTIONS list
    for _, item in ipairs(harpoon:list(lists.instructions_list).items) do
        local file_path = item.value
        local content, err = self.read_file(file_path)
        if content then
            table.insert(all_contents, "### Instructions : " .. " ###\n\n" .. content .. "\n\n")
        else
            vim.notify("Error reading file " .. file_path .. ": " .. (err or "unknown error"), vim.log.levels.ERROR)
        end
    end

    -- Join all contents and copy to clipboard
    local combined_content = table.concat(all_contents, "")
    vim.fn.setreg("+", combined_content)
    vim.notify("Copied contents of all items to clipboard")
end

-- Function to copy everything (files content + command outputs)
function Utils:copy_everything_to_clipboard()

    local harpoon = require("harpoon")
    local lists = self.lists
    local commands = self.commands
    local all_contents = {}

    -- Get items from CONTEXT list
    for _, item in ipairs(harpoon:list(self.lists.context_list).items) do
        local file_path = item.value
        local content, err = self.read_file(file_path)
        if content then
            table.insert(all_contents, "### Context : " .. " ###\n\n" .. content .. "\n\n")
        else
            vim.notify("Error reading file " .. file_path .. ": " .. (err or "unknown error"), vim.log.levels.ERROR)
        end
    end

    -- Get command outputs from CMD_CONTEXT list
    for i, item in ipairs(harpoon:list(self.lists.context_list).items) do
        local cmd = item.value
        local output = vim.fn.system(cmd)
        if output then
            table.insert(all_contents, "### Command Output " .. i .. ": " .. cmd .. " ###\n\n" .. output .. "\n\n")
        end
    end

    -- Get items from RESOURCES list
    for _, item in ipairs(harpoon:list(lists.resources_list).items) do
        local file_path = item.value
        local content, err = self.read_file(file_path)
        if content then
            table.insert(all_contents, "### " .. file_path .. " ###\n\n" .. content .. "\n\n")
        else
            vim.notify("Error reading file " .. file_path .. ": " .. (err or "unknown error"), vim.log.levels.ERROR)
        end
    end

    -- Get items from INSTRUCTIONS list
    for _, item in ipairs(harpoon:list(lists.instructions_list).items) do
        local file_path = item.value
        local content, err = self.read_file(file_path)
        if content then
            table.insert(all_contents, "### Instructions : " .. " ###\n\n" .. content .. "\n\n")
        else
            vim.notify("Error reading file " .. file_path .. ": " .. (err or "unknown error"), vim.log.levels.ERROR)
        end
    end

    -- Join all contents and copy to clipboard
    local combined_content = table.concat(all_contents, "")
    vim.fn.setreg("+", combined_content)
    vim.notify("Copied all content and command outputs to clipboard")
end

return Utils
