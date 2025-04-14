--- @class ListConfig
--- @field type string "file" or "command"
--- @field title string Section title for the list
--- @field list_name string The internal name for the harpoon list
--- @field order number The order in the list
--- @field key string The key of the map

--- @class ListsOpts
--- @field [string] ListConfig Custom list configurations

--- @class HarpoonList
--- @field config HarpoonPartialConfigItem
--- @field name string
--- @field preprompts {[string]: string}
--- @field instuctions {[string]: string}
--- @field _length number
--- @field _index number
--- @field items HarpoonItem[]

--- @class HarpoonItem
--- @field value string
--- @field context any

---@alias HarpoonListItem {value: any, context: any, incontext: boolean, inlist:boolean}

---@class HarpoonPartialConfigItem
---@field select_with_nil? boolean defaults to false
---@field encode? (fun(list_item: HarpoonListItem): string) | boolean
---@field decode? (fun(obj: string): any)
---@field display? (fun(list_item: HarpoonListItem): string)
---@field select? (fun(list_item?: HarpoonListItem, list: HarpoonList, options: any?): nil)
---@field equals? (fun(list_line_a: HarpoonListItem, list_line_b: HarpoonListItem): boolean)
---@field create_list_item? fun(config: HarpoonPartialConfigItem, item: any?, inlist?:boolean, incontext?:boolean): HarpoonListItem
---@field BufLeave? fun(evt: any, list: HarpoonList): nil
---@field VimLeavePre? fun(evt: any, list: HarpoonList): nil
---@field get_root_dir? fun(): string


--- List definitions and management for teleproompter
--- @class List
--- @field lists table<string, ListConfig> Map of list IDs to their configurations
local List = {}
List.__index = List

---@param opts ListsOpts
---@return List
function List:new(opts)
    local list = setmetatable({
        lists = opts or {},
    }, self)
    return list
end

-- Get all list names (internal harpoon list names)
function List:get_all_names()
    local names = {}
    for _, config in pairs(self:get_list()) do
        table.insert(names, config.list_name)
    end
    return names
end

---@return ListConfig[]
function List:get_list()
    local sorted = {}
    for _, config in pairs(self.lists) do
        table.insert(sorted, config)
    end
    table.sort(sorted, function(a, b)
        return (a.order or math.huge) > (b.order or math.huge)
    end)
    return sorted
end

-- Get a specific list name by key
function List:get_list_name(key)
    if self.lists[key] then
        return self.lists[key].list_name
    end
    return nil
end

-- Get list type (file or command)
function List:get_list_type(key)
    if self.lists[key] then
        return self.lists[key].type
    end
    return nil
end

-- Get list title
function List:get_list_title(key)
    if self.lists[key] then
        return self.lists[key].title
    end
    return nil
end

-- Get all list keys (user-defined identifiers)
function List:get_all_keys()
    local keys = {}
    for key, _ in pairs(self.lists) do
        table.insert(keys, key)
    end
    return keys
end

-- Get lists of a specific type
function List:get_lists_by_type(type_name)
    local result = {}
    for key, config in pairs(self.lists) do
        if config.type == type_name then
            table.insert(result, { key = key, config = config })
        end
    end
    return result
end

-- Get all items from all lists
function List:get_all_items()
    local result = {}
    local harpoon = require("harpoon")

    for _, config in pairs(self:get_list()) do
        result[config.key] = harpoon:list(config.list_name).items
    end

    return result
end

--- Get combined items from all lists with their list type
---@return table
function List:get_combined_items()
    local combined_items = {}
    local all_items = self:get_all_items()

    for list_key, items in pairs(all_items) do
        local list_config = self.lists[list_key]
        for _, item in ipairs(items) do
            table.insert(combined_items, {
                value = item.value,
                type = string.upper(list_config.key),
                list_type = list_config.type,
                title = list_config.title
            })
        end
    end

    return combined_items
end

--- Add a new list configuration
---@param key string The list identifier
---@param config ListConfig The list configuration
function List:add_list(key, config)
    self.lists[key] = config
end

return List
