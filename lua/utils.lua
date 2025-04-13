-- Utility functions for teleproompter
local utils = {}

-- Reference to main module
local _M = nil

-- Read file contents safely
function utils.read_file(file_path)
    local file = io.open(file_path, "r")
    if not file then
        return nil, "Could not open file: " .. file_path
    end

    local content = file:read("*all")
    file:close()
    return content
end

-- Function to copy contents of all items in lists to clipboard
function utils.copy_all_items_to_clipboard()
    if not _M then
        error("Utils module not initialized")
    end

    local harpoon = _M.harpoon
    local lists = _M.lists
    local all_contents = {}

    -- Get items from CONTEXT list
    for _, item in ipairs(harpoon:list(lists.CONTEXT).items) do
        local file_path = item.value
        local content, err = utils.read_file(file_path)
        if content then
            table.insert(all_contents, "### Context : " .. " ###\n\n" .. content .. "\n\n")
        else
            vim.notify("Error reading file " .. file_path .. ": " .. (err or "unknown error"), vim.log.levels.ERROR)
        end
    end

    -- Get items from RESOURCES list
    for _, item in ipairs(harpoon:list(lists.RESOURCES).items) do
        local file_path = item.value
        local content, err = utils.read_file(file_path)
        if content then
            table.insert(all_contents, "### " .. file_path .. " ###\n\n" .. content .. "\n\n")
        else
            vim.notify("Error reading file " .. file_path .. ": " .. (err or "unknown error"), vim.log.levels.ERROR)
        end
    end

    -- Get items from INSTRUCTIONS list
    for _, item in ipairs(harpoon:list(lists.INSTRUCTIONS).items) do
        local file_path = item.value
        local content, err = utils.read_file(file_path)
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
function utils.copy_everything_to_clipboard()
    if not _M then
        error("Utils module not initialized")
    end

    local harpoon = _M.harpoon
    local lists = _M.lists
    local commands = _M.commands
    local all_contents = {}

    -- Get items from CONTEXT list
    for _, item in ipairs(harpoon:list(lists.CONTEXT).items) do
        local file_path = item.value
        local content, err = utils.read_file(file_path)
        if content then
            table.insert(all_contents, "### Context : " .. " ###\n\n" .. content .. "\n\n")
        else
            vim.notify("Error reading file " .. file_path .. ": " .. (err or "unknown error"), vim.log.levels.ERROR)
        end
    end

    -- Get command outputs from CMD_CONTEXT list
    for i, item in ipairs(harpoon:list(lists.CMD_CONTEXT).items) do
        local cmd = item.value
        local output = vim.fn.system(cmd)
        if output then
            table.insert(all_contents, "### Command Output " .. i .. ": " .. cmd .. " ###\n\n" .. output .. "\n\n")
        end
    end

    -- Get items from RESOURCES list
    for _, item in ipairs(harpoon:list(lists.RESOURCES).items) do
        local file_path = item.value
        local content, err = utils.read_file(file_path)
        if content then
            table.insert(all_contents, "### " .. file_path .. " ###\n\n" .. content .. "\n\n")
        else
            vim.notify("Error reading file " .. file_path .. ": " .. (err or "unknown error"), vim.log.levels.ERROR)
        end
    end

    -- Get items from INSTRUCTIONS list
    for _, item in ipairs(harpoon:list(lists.INSTRUCTIONS).items) do
        local file_path = item.value
        local content, err = utils.read_file(file_path)
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

-- Initialize the module with a reference to the main module
function utils.init(main_module)
    _M = main_module
    return utils
end

