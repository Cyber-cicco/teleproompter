-- Utility functions for the teleproompter plugin

--- @class Utils
--- @field lists List
--- @field commands Commands
local Utils = {}
Utils.__index = Utils

---@param lists List
---@param commands Commands
---@return Utils
function Utils:new(lists, commands)
    local utils = setmetatable({
        lists = lists,
        commands = commands
    }, self)
    return utils
end

-- Read a file and return its content
function Utils:read_file_content(filepath)
    local file = io.open(filepath, "r")
    if not file then
        return nil, "Cannot open file: " .. filepath
    end

    local content = file:read("*all")
    file:close()
    return content
end

-- Copy contents of all file-type lists to clipboard
function Utils:copy_all_items_to_clipboard()
    local combined_content = ""
    local file_lists = self.lists:get_lists_by_type("file")
    local harpoon = require("harpoon")

    -- Process each file list
    for _, list_info in ipairs(file_lists) do
        local list_key = list_info.key
        local list_config = list_info.config
        local items = harpoon:list(list_config.list_name).items

        if #items > 0 then
            combined_content = combined_content .. "### " .. list_config.title .. " ###\n\n"

            for _, item in ipairs(items) do
                local filepath = item.value
                local filename = vim.fn.fnamemodify(filepath, ":t")

                -- Read file content
                local content, err = self:read_file_content(filepath)
                if content then
                    combined_content = combined_content .. "### " .. filename .. " ###\n\n"
                    combined_content = combined_content .. content .. "\n\n"
                else
                    combined_content = combined_content .. "### " .. filename .. " ###\n\n"
                    combined_content = combined_content .. "Error reading file: " .. (err or "Unknown error") .. "\n\n"
                end
            end
        end
    end

    -- Copy to clipboard
    if combined_content ~= "" then
        vim.fn.setreg("+", combined_content)
        vim.notify("File contents copied to clipboard", vim.log.levels.INFO)
    else
        vim.notify("No file contents to copy", vim.log.levels.WARN)
    end

    return combined_content
end

-- Copy everything (file contents and command outputs) to clipboard
function Utils:copy_everything_to_clipboard()
    local file_content = self:copy_all_items_to_clipboard()
    local command_output = self.commands:execute_commands_and_copy_output()

    local combined_content = file_content .. "\n\n" .. command_output

    -- Copy to clipboard
    vim.fn.setreg("+", combined_content)
    vim.notify("All content copied to clipboard", vim.log.levels.INFO)

    return combined_content
end

return Utils

