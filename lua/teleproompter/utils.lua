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

function Utils:copy_everything_to_clipboard()
    -- Get system prompt first
    local system_prompt = self:get_system_prompt()

    -- Get file content and command output
    local file_content = self:copy_all_items_to_clipboard(false) -- Pass false to prevent clipboard copy
    local command_output = self.commands:execute_commands_and_copy_output(false) -- Pass false to prevent clipboard copy

    -- Combine content with system prompt at the beginning
    local combined_content = system_prompt

    if system_prompt ~= "" and (file_content ~= "" or command_output ~= "") then
        combined_content = combined_content .. "\n\n"
    end

    combined_content = combined_content .. file_content

    if file_content ~= "" and command_output ~= "" then
        combined_content = combined_content .. "\n\n"
    end

    combined_content = combined_content .. command_output

    -- Copy to clipboard
    vim.fn.setreg("+", combined_content)
    vim.notify("All content with system prompt copied to clipboard", vim.log.levels.INFO)

    return combined_content
end

-- Update the copy_all_items_to_clipboard function to accept an optional parameter
function Utils:copy_all_items_to_clipboard(copy_to_clipboard)
    -- Default to true if not specified
    if copy_to_clipboard == nil then
        copy_to_clipboard = true
    end

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

    -- Copy to clipboard if requested
    if copy_to_clipboard and combined_content ~= "" then
        vim.fn.setreg("+", combined_content)
        vim.notify("File contents copied to clipboard", vim.log.levels.INFO)
    end

    return combined_content
end

-- System prompt related functions
-- Find project root directory (to locate TELEPROOMPTER.md)
function Utils:find_project_root()
    -- Try to find git root as project root
    local current_file = vim.fn.expand('%:p')
    local current_dir = vim.fn.fnamemodify(current_file, ':h')

    -- Start from current directory and traverse up
    local path = current_dir
    while path ~= '/' do
        -- Check if .git directory exists (indicating git root)
        if vim.fn.isdirectory(path .. '/.git') == 1 then
            return path
        end
        -- Move up one directory
        path = vim.fn.fnamemodify(path, ':h')
    end

    -- Fallback to current working directory if git root not found
    return vim.fn.getcwd()
end

-- Get system prompt content
function Utils:get_system_prompt()
    local content = ""

    -- Check for override in project root first
    local project_root = self:find_project_root()
    local override_path = project_root .. "/TELEPROOMPTER.md"

    if vim.fn.filereadable(override_path) == 1 then
        -- Read override file
        local override_content, err = self:read_file_content(override_path)
        if override_content then
            return override_content
        else
            vim.notify("Error reading system prompt override: " .. (err or "Unknown error"), vim.log.levels.WARN)
        end
    end

    -- Fall back to configured system prompt file
    if self.config and self.config.system_prompt_file and vim.fn.filereadable(self.config.system_prompt_file) == 1 then
        local file_content, err = self:read_file_content(self.config.system_prompt_file)
        if file_content then
            return file_content
        else
            vim.notify("Error reading system prompt file: " .. (err or "Unknown error"), vim.log.levels.WARN)
        end
    end

    -- Use default system prompt if no file is available
    return self.config and self.config.default_system_prompt or 
        "You are a helpful AI assistant. Answer questions accurately and concisely."
end

return Utils

