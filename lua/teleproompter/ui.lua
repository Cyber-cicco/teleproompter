-- This module handles all UI-related functionality for the Teleproompter plugin

local ui = {}

-----------------------------------------------------------
-- Telescope Integration
-----------------------------------------------------------

-- Display files in a Telescope picker
function ui.toggle_telescope(harpoon_files)
    local file_paths = {}
    for _, item in ipairs(harpoon_files.items) do
        table.insert(file_paths, item.value)
    end

    local conf = require("telescope.config").values
    require("telescope.pickers").new({}, {
        prompt_title = "Harpoon",
        finder = require("telescope.finders").new_table({
            results = file_paths,
        }),
        previewer = conf.file_previewer({}),
        sorter = conf.generic_sorter({}),
    }):find()
end

-----------------------------------------------------------
-- List Windows
-----------------------------------------------------------

-- Display all lists in a single window
---@param lists List
function ui.show_all_lists_window(lists)
    local harpoon = require("harpoon")

    -- Create a new buffer for our window
    local buf = vim.api.nvim_create_buf(false, true)

    -- Prepare the content for all lists
    local content = {}

    -- Add header
    table.insert(content, "TELEPROOMPTER LISTS")
    table.insert(content, "==================")
    table.insert(content, "")

    -- Add each list
    local all_lists = lists:get_all_keys()
    for _, list_key in ipairs(all_lists) do
        local list_title = lists:get_list_title(list_key)
        local list_name = lists:get_list_name(list_key)
        local list_type = lists:get_list_type(list_key)

        -- Create header with type indicator
        local header = string.upper(list_title) .. " LIST (" .. list_type .. "):"
        table.insert(content, header)
        table.insert(content, string.rep("-", string.len(header)))

        local list_items = harpoon:list(list_name).items
        -- Sort items by order
        list_items = lists:sort_items_by_order(list_items)

        if #list_items > 0 then
            for i, item in ipairs(list_items) do
                local order = item.context and item.context.order or "-"
                table.insert(content, string.format("%d. [Order: %s] %s", i, order, item.value))
            end
        else
            table.insert(content, "No items in " .. list_title .. " list")
        end
        table.insert(content, "")
    end

    -- Add footer with keybindings help
    table.insert(content, "")
    table.insert(content, "Press 'q' to close this window | 'y' to copy all to clipboard | 'o' to set item order")

    -- Set the content to the buffer
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)

    -- Calculate window size and position
    local width = vim.api.nvim_get_option("columns")
    local height = vim.api.nvim_get_option("lines")
    local win_width = math.min(width - 4, 80)
    local win_height = math.min(height - 4, 40)
    local row = (height - win_height) / 2
    local col = (width - win_width) / 2

    -- Window options
    local opts = {
        relative = "editor",
        width = win_width,
        height = win_height,
        row = row,
        col = col,
        style = "minimal",
        border = "rounded",
        title = "Teleproompter Lists"
    }

    -- Create the window
    local win = vim.api.nvim_open_win(buf, true, opts)

    -- Set window options
    vim.api.nvim_win_set_option(win, "winblend", 0)
    vim.api.nvim_buf_set_option(buf, "modifiable", false)
    vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")

    -- Add keymaps for the window
    vim.api.nvim_buf_set_keymap(buf, "n", "q",
        ":lua vim.api.nvim_win_close(" .. win .. ", true)<CR>",
        { noremap = true, silent = true, desc = "Close window" }
    )

    -- Add keymap to copy all lists content
    vim.api.nvim_buf_set_keymap(buf, "n", "y",
        ":lua require('teleproompter').utils:copy_everything_to_clipboard()<CR>",
        { noremap = true, silent = true, desc = "Copy all to clipboard" }
    )

    -- Add keymap to set item order
    vim.api.nvim_buf_set_keymap(buf, "n", "o",
        ":lua require('teleproompter.ui').set_item_order()<CR>",
        { noremap = true, silent = true, desc = "Set item order" }
    )

    -- Set buffer name
    vim.api.nvim_buf_set_name(buf, "Teleproompter Lists")

    -- Apply highlighting for better readability
    vim.api.nvim_buf_add_highlight(buf, -1, "Title", 0, 0, -1)
    vim.api.nvim_buf_add_highlight(buf, -1, "Special", 1, 0, -1)

    -- Find and highlight section headers
    for i, line in ipairs(content) do
        if line:match("^[A-Z]+ LIST") then
            vim.api.nvim_buf_add_highlight(buf, -1, "Keyword", i - 1, 0, -1)
            vim.api.nvim_buf_add_highlight(buf, -1, "Comment", i, 0, -1)
        end
    end

    return win, buf
end

-----------------------------------------------------------
-- Telescope Integration for All Lists
-----------------------------------------------------------

-- Show all lists in a telescope picker with advanced filtering
---@param lists List
function ui.show_all_lists_telescope(lists)
    local combined_items = lists:get_combined_items()

    -- Prepare results for telescope
    local results = {}
    for _, item in ipairs(combined_items) do
        table.insert(results, {
            value = item.value,
            type = item.type,
            list_type = item.list_type,
            title = item.title,
            display = string.format("[%s] %s", item.type, item.value)
        })
    end

    -- Open telescope with combined items
    local conf = require("telescope.config").values
    require("telescope.pickers").new({}, {
        prompt_title = "Teleproompter Lists",
        finder = require("telescope.finders").new_table({
            results = results,
            entry_maker = function(entry)
                return {
                    value = entry.value,
                    type = entry.type,
                    list_type = entry.list_type,
                    title = entry.title,
                    display = entry.display,
                    ordinal = entry.display,
                }
            end,
        }),
        sorter = conf.generic_sorter({}),
        previewer = conf.file_previewer({}),
        attach_mappings = function(prompt_bufnr, map)
            -- Action on selection: open the file or execute the command
            local actions = require("telescope.actions")
            local action_state = require("telescope.actions.state")

            -- Custom action to handle selection
            local function handle_selection()
                local selection = action_state.get_selected_entry()
                if selection then
                    -- Close the picker
                    actions.close(prompt_bufnr)

                    if selection.list_type == "command" then
                        -- For commands, execute them
                        vim.notify("Executing command: " .. selection.value)
                        local output = vim.fn.system(selection.value)

                        -- Display output in a floating window
                        ui.show_output_window(output, "Command Output: " .. selection.value)
                    else
                        -- For file paths, open the file
                        vim.cmd("edit " .. selection.value)
                    end
                end
            end

            -- Custom action to copy selected item's content
            local function copy_selection()
                local selection = action_state.get_selected_entry()
                if selection then
                    if selection.list_type == "command" then
                        -- For commands, execute and copy output
                        local output = vim.fn.system(selection.value)
                        vim.fn.setreg('+', output)
                        vim.notify("Command output copied to clipboard", vim.log.levels.INFO)
                    else
                        -- For files, read and copy content
                        local file = io.open(selection.value, "r")
                        if file then
                            local content = file:read("*all")
                            file:close()
                            vim.fn.setreg('+', content)
                            vim.notify("File content copied to clipboard", vim.log.levels.INFO)
                        else
                            vim.notify("Failed to open file: " .. selection.value, vim.log.levels.ERROR)
                        end
                    end
                end
            end

            -- Map keys to our custom actions
            map("i", "<CR>", handle_selection)
            map("n", "<CR>", handle_selection)
            map("i", "<C-y>", copy_selection)
            map("n", "<C-y>", copy_selection)

            return true
        end,
    }):find()
end

-----------------------------------------------------------
-- Output Windows
-----------------------------------------------------------

-- Show command output in a floating window
---@param output string
---@param title? string
-- Show command output in a floating window
---@param output string
---@param title? string
function ui.show_output_window(output, title)
    title = title or "Command Output"

    -- Split output into lines
    local lines = {}
    for line in string.gmatch(output, "[^\r\n]+") do
        table.insert(lines, line)
    end

    -- Add info about keymaps
    table.insert(lines, "")
    table.insert(lines, "Press 'q' to close, 'y' to copy all content")

    -- Create buffer for output
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    -- Calculate window size and position
    local width = vim.api.nvim_get_option("columns")
    local height = vim.api.nvim_get_option("lines")
    local win_width = math.min(width - 4, 80)
    local win_height = math.min(height - 4, 20)
    local row = (height - win_height) / 2
    local col = (width - win_width) / 2

    -- Configure window
    local opts = {
        relative = "editor",
        width = win_width,
        height = win_height,
        row = row,
        col = col,
        style = "minimal",
        border = "rounded",
        title = title
    }

    -- Create window
    local win = vim.api.nvim_open_win(buf, true, opts)

    -- Set the buffer as non-modifiable AFTER setting all lines
    vim.api.nvim_buf_set_option(buf, "modifiable", false)

    -- Add keymap to close window
    vim.api.nvim_buf_set_keymap(buf, "n", "q",
        ":lua vim.api.nvim_win_close(" .. win .. ", true)<CR>",
        { noremap = true, silent = true, desc = "Close window" })

    -- Add keymap to copy content to clipboard
    vim.api.nvim_buf_set_keymap(buf, "n", "y",
        ":lua vim.fn.setreg('+', table.concat(vim.api.nvim_buf_get_lines(" .. buf .. ", 0, -1, false), '\\n'))<CR>",
        { noremap = true, silent = true, desc = "Copy output to clipboard" })

    return win, buf
end

-----------------------------------------------------------
-- Interactive List Management
-----------------------------------------------------------

-- Show a dialog to add a new item to a specific list
---@param lists List
---@param list_key string
function ui.add_item_dialog(lists, list_key)
    local list_config = lists.lists[list_key]
    if not list_config then
        vim.notify("List not found: " .. list_key, vim.log.levels.ERROR)
        return
    end

    local harpoon = require("harpoon")
    local list_title = list_config.title

    if list_config.type == "file" then
        -- For file lists, prompt for file path
        vim.ui.input({
            prompt = "Enter file path to add to " .. list_title .. " list: ",
            default = vim.fn.expand("%:p") -- Default to current file
        }, function(input)
            if input and input ~= "" then
                harpoon:list(list_config.list_name):append({
                    value = input,
                    context = { type = "file" }
                })
                vim.notify("File added to " .. list_title .. " list", vim.log.levels.INFO)
            end
        end)
    else
        -- For command lists, prompt for command
        vim.ui.input({
            prompt = "Enter command to add to " .. list_title .. " list: "
        }, function(input)
            if input and input ~= "" then
                harpoon:list(list_config.list_name):append({
                    value = input,
                    context = { type = "command" }
                })
                vim.notify("Command added to " .. list_title .. " list", vim.log.levels.INFO)
            end
        end)
    end
end

-- Show a dialog to manage a specific list
---@param lists List
---@param list_key string
function ui.manage_list_dialog(lists, list_key)
    local list_config = lists.lists[list_key]
    if not list_config then
        vim.notify("List not found: " .. list_key, vim.log.levels.ERROR)
        return
    end

    local harpoon = require("harpoon")
    local list = harpoon:list(list_config.list_name)
    local items = list.items

    -- Create a new buffer
    local buf = vim.api.nvim_create_buf(false, true)

    -- Prepare content
    local content = {}
    table.insert(content, list_config.title .. " List (" .. list_config.type .. ")")
    table.insert(content, string.rep("=", string.len(content[1])))
    table.insert(content, "")

    if #items > 0 then
        for i, item in ipairs(items) do
            table.insert(content, string.format("%d. %s", i, item.value))
        end
    else
        table.insert(content, "No items in list")
    end

    table.insert(content, "")
    table.insert(content, "Commands:")
    table.insert(content, "  a: Add new item")
    table.insert(content, "  d: Delete selected item")
    table.insert(content, "  q: Close window")

    -- Set content to buffer
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)

    -- Calculate window dimensions
    local width = vim.api.nvim_get_option("columns")
    local height = vim.api.nvim_get_option("lines")
    local win_width = math.min(width - 4, 80)
    local win_height = math.min(height - 4, 30)
    local row = (height - win_height) / 2
    local col = (width - win_width) / 2

    -- Configure window
    local opts = {
        relative = "editor",
        width = win_width,
        height = win_height,
        row = row,
        col = col,
        style = "minimal",
        border = "rounded",
        title = "Manage " .. list_config.title .. " List"
    }

    -- Create window
    local win = vim.api.nvim_open_win(buf, true, opts)
    vim.api.nvim_win_set_option(win, "winblend", 0)
    vim.api.nvim_buf_set_option(buf, "modifiable", false)

    -- Add keymaps
    vim.api.nvim_buf_set_keymap(buf, "n", "q",
        ":lua vim.api.nvim_win_close(" .. win .. ", true)<CR>",
        { noremap = true, silent = true }
    )

    vim.api.nvim_buf_set_keymap(buf, "n", "a",
        ":lua require('teleproompter.ui_new').add_item_dialog(require('teleproompter').lists, '" .. list_key .. "')<CR>",
        { noremap = true, silent = true }
    )

    -- TODO: Add functionality for deleting items

    return win, buf
end

return ui
