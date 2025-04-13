-- List definitions and management for teleproompter
local lists = {}

-- Define list names (will be populated during init)
lists.CONTEXT = nil
lists.CMD_CONTEXT = nil
lists.RESOURCES = nil
lists.INSTRUCTIONS = nil

-- Store main module reference
lists._M = nil

-- Initialize lists module
function lists.init(main_module)
    lists._M = main_module

    -- Set list names from config
    local config = main_module.config
    lists.CONTEXT = config.lists.context_list
    lists.CMD_CONTEXT = config.lists.cmd_context_list
    lists.RESOURCES = config.lists.resources_list
    lists.INSTRUCTIONS = config.lists.instructions_list

    return lists
end

-- Helper function to get a list by its name
function lists.get(list_name)
    if not lists._M then
        error("Lists module not initialized")
    end

    return lists._M.harpoon:list(list_name)
end

-- Get all list names
function lists.get_all_names()
    return {
        lists.CONTEXT,
        lists.CMD_CONTEXT,
        lists.RESOURCES,
        lists.INSTRUCTIONS
    }
end

-- Get all list items grouped by list type
function lists.get_all_items()
    if not lists._M then
        error("Lists module not initialized")
    end

    local harpoon = lists._M.harpoon
    local result = {}

    result.context = harpoon:list(lists.CONTEXT).items
    result.cmd_context = harpoon:list(lists.CMD_CONTEXT).items
    result.resources = harpoon:list(lists.RESOURCES).items
    result.instructions = harpoon:list(lists.INSTRUCTIONS).items
    result.main = harpoon:list().items

    return result
end

-- Get combined items from all lists with their list type
function lists.get_combined_items()
    local combined_items = {}
    local all_items = lists.get_all_items()

    for _, item in ipairs(all_items.instructions) do
        table.insert(combined_items, { value = item.value, type = "INSTRUCTIONS" })
    end

    for _, item in ipairs(all_items.context) do
        table.insert(combined_items, { value = item.value, type = "CONTEXT" })
    end

    for _, item in ipairs(all_items.resources) do
        table.insert(combined_items, { value = item.value, type = "RESOURCES" })
    end

    for _, item in ipairs(all_items.cmd_context) do
        table.insert(combined_items, { value = item.value, type = "CMD_CONTEXT" })
    end

    return combined_items
end

return lists
