--- @class ListsOpts
--- @field context_list string
--- @field cmd_context_list string
--- @field resources_list string
--- @field instructions_list string

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
--- @field context_list string
--- @field cmd_context_list string
--- @field resources_list string
--- @field instructions_list string
local List = {}
List.__index = List


---comment
---@param opts ListsOpts
---@return List
function List:new(opts)
    local list = setmetatable({
        context_list = opts.context_list,
        cmd_context_list = opts.cmd_context_list,
        resources_list = opts.resources_list,
        instructions_list = opts.instructions_list,
    }, self)
    return list
end

-- Get all list names
function List:get_all_names()
    return {
        self.context_list,
        self.resources_list,
        self.cmd_context_list,
        self.instructions_list,
    }
end

---@return {
---     cmd_context: HarpoonItem[],
---     context: HarpoonItem[],
---     instructions: HarpoonItem[],
---     main: HarpoonItem[],
---     resources: HarpoonItem[],
--- }

function List:get_all_items()
    local result = {}
    local harpoon = require("harpoon")

    result.context = harpoon:list(self.context_list).items
    result.cmd_context = harpoon:list(self.cmd_context_list).items
    result.resources = harpoon:list(self.resources_list).items
    result.instructions = harpoon:list(self.instructions_list).items
    result.main = harpoon:list().items

    return result
end

--- Get combined items from all lists with their list type
---@return table
function List:get_combined_items()
    local combined_items = {}
    local all_items = self.get_all_items(self)

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

return List
