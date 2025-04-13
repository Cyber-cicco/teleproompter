-- UI-related functions for teleproompter
local ui = {}

-- Reference to main module
local _M = nil

-- Telescope integration function
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

-- Function to display all lists in a single window
function ui.show_all_lists_window()
    if not _M then
        error("UI module not initialized")
    end

    local harpoon = _M.harpoon
    local lists = _M.lists

    -- Create a new buffer for our window
    local buf = vim.api.nvim_create_buf(false, true)

    -- Prepare the content for all lists
    local content = {}

    -- Add header
    table.insert(content, "PROMPT FILES LIST")
    table.insert(content, "================")
    table.insert(content, "")

    -- INSTRUCTIONS list
    table.insert(content, "INSTRUCTIONS LIST:")
    table.insert(content, "-----------------")
    local instructions_items = harpoon:list(lists.INSTRUCTIONS).items
    if #instructions_items > 0 then
        for i, item in ipairs(instructions_items) do
            table.insert(content, string.format("%d. %s", i, item.value))
        end
    else
        table.insert(content, "No items in INSTRUCTIONS list")
    end
    table.insert(content, "")

    -- CONTEXT list
    table.insert(content, "CONTEXT LIST:")
    table.insert(content, "------------")
    local context_items = harpoon:list(lists.CONTEXT).items
    if #context_items > 0 then
        for i, item in ipairs(context_items) do
            table.insert(content, string.format("%d. %s", i, item.value))
        end
    else
        table.insert(content, "No items in CONTEXT list")
    end
    table.insert(content, "")

    -- RESOURCES list
    table.insert(content, "RESOURCES LIST:")
    table.insert(content, "--------------")
    local resources_items = harpoon:list(lists.RESOURCES).items
    if #resources_items > 0 then
        for i, item in ipairs(resources_items) do
            table.insert(content, string.format("%d. %s", i, item.value))
        end
    else
        table.insert(content, "No items in RESOURCES list")
    end
    table.insert(content, "")

    -- CMD_CONTEXT list
    table.insert(content, "COMMAND CONTEXT LIST:")
    table.insert(content, "---------------------")
    local cmd_context_items = harpoon:list(lists.CMD_CONTEXT).items
    if #cmd_context_items > 0 then
        for i, item in ipairs(cmd_context_items) do
            table.insert(content, string.format("%d. %s", i, item.value))
        end
    else
        table.insert(content, "No items in CMD_CONTEXT list")
    end

    -- Add footer with keybindings help
    table.insert(content, "")
    table.insert(content, "Press 'q' to close this window")

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
        border = "rounded"
    }

    -- Create the window
    local win = vim.api.nvim_open_win(buf, true, opts)

    -- Set window options
    vim.api.nvim_win_set_option(win, "winblend", 0)
    vim.api.nvim_buf_set_option(buf, "modifiable", false)
    vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")

    -- Add keymaps for the window
    vim.api.nvim_buf_set_keymap(buf, "n", "q", ":lua vim.api.nvim_win_close(" .. win .. ", true)<CR>", {
        noremap = true,
        silent = true
    })

    -- Set buffer name
    vim.api.nvim_buf_set_name(buf, "Harpoon Lists")

    -- Apply highlighting for better readability
    vim.api.nvim_buf_add_highlight(buf, -1, "Title", 0, 0, -1)
    vim.api.nvim_buf_add_highlight(buf, -1, "Special", 1, 0, -1)

    local line_idx = 4
    vim.api.nvim_buf_add_highlight(buf, -1, "Keyword", line_idx, 0, -1)
    line_idx = line_idx + 1
    vim.api.nvim_buf_add_highlight(buf, -1, "Comment", line_idx, 0, -1)

    -- Find and highlight other section headers
    for i, line in ipairs(content) do
        if line:match("^[A-Z]+ LIST:$") then
            vim.api.nvim_buf_add_highlight(buf, -1, "Keyword", i - 1, 0, -1)
            vim.api.nvim_buf_add_highlight(buf, -1, "Comment", i, 0, -1)
        end
    end
end

-- Function to open a more interactive window with telescope
function ui.show_all_lists_telescope()
    if not _M then
        error("UI module not initialized")
    end

    local lists = _M.lists
    local combined_items = lists.get_combined_items()

    -- Prepare results for telescope
    local results = {}
    for _, item in ipairs(combined_items) do
        table.insert(results, string.format("[%s] %s", item.type, item.value))
    end

    -- Open telescope with combined items
    local conf = require("telescope.config").values
    require("telescope.pickers").new({}, {
        prompt_title = "All Harpoon Lists",
        finder = require("telescope.finders").new_table({
            results = results,
            entry_maker = function(entry)
                return {
                    value = entry,
                    display = entry,
                    ordinal = entry,
                }
            end,
        }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, map)
            -- Action on selection: open the file or execute the command
            local actions = require("telescope.actions")
            local action_state = require("telescope.actions.state")

            -- Custom action to handle selection
            local function handle_selection()
                local selection = action_state.get_selected_entry()
                if selection and selection.value then
                    -- Close the picker
                    actions.close(prompt_bufnr)

                    -- Parse the selection to get type and value
                    local type_pattern = "%[([^%]]+)%]"
                    local type_match = string.match(selection.value, type_pattern)

                    -- Extract the actual value (everything after the type bracket)
                    local value = string.gsub(selection.value, "%[" .. type_match .. "%] ", "")

                    if type_match == "CMD_CONTEXT" then
                        -- For commands, execute them
                        vim.notify("Executing command: " .. value)
                        local output = vim.fn.system(value)
                        -- Display output in a floating window
                        local lines = {}
                        for line in string.gmatch(output, "[^\r\n]+") do
                            table.insert(lines, line)
                        end

                        -- Create temporary buffer for output
                        local buf = vim.api.nvim_create_buf(false, true)
                        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

                        -- Calculate window size and position
                        local width = vim.api.nvim_get_option("columns")
                        local height = vim.api.nvim_get_option("lines")
                        local win_width = math.min(width - 4, 80)
                        local win_height = math.min(height - 4, 20)
                        local row = (height - win_height) / 2
                        local col = (width - win_width) / 2

                        local opts = {
                            relative = "editor",
                            width = win_width,
                            height = win_height,
                            row = row,
                            col = col,
                            style = "minimal",
                            border = "rounded"
                        }

                        local win = vim.api.nvim_open_win(buf, true, opts)
                        vim.api.nvim_buf_set_option(buf, "modifiable", false)
                        vim.api.nvim_buf_set_keymap(buf, "n", "q",
                            ":lua vim.api.nvim_win_close(" .. win .. ", true)<CR>",
                            { noremap = true, silent = true })
                    else
                        -- For file paths, open the file
                        vim.cmd("edit " .. value)
                    end
                end
            end

            -- Map enter key to our custom action
            map("i", "<CR>", handle_selection)
            map("n", "<CR>", handle_selection)

            return true
        end,
    }):find()
end

-- Show command output in a floating window
function ui.show_output_window(output, title)
    title = title or "Command Output"

    -- Split output into lines
    local lines = {}
    for line in string.gmatch(output, "[^\r\n]+") do
        table.insert(lines, line)
    end

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
    vim.api.nvim_buf_set_option(buf, "modifiable", false)

    -- Add keymap to close window
    vim.api.nvim_buf_set_keymap(buf, "n", "q",
        ":lua vim.api.nvim_win_close(" .. win .. ", true)<CR>",
        { noremap = true, silent = true })

    -- Add keymap to copy content to clipboard
    vim.api.nvim_buf_set_keymap(buf, "n", "y",
        ":lua vim.fn.setreg('+', table.concat(vim.api.nvim_buf_get_lines(" .. buf .. ", 0, -1, false), '\\n'))<CR>",
        { noremap = true, silent = true, desc = "Copy output to clipboard" })

    -- Add info about keymaps
    vim.api.nvim_buf_set_lines(buf, #lines, #lines + 2, false, { "", "Press 'q' to close, 'y' to copy all content" })

    return win, buf
end

-- Initialize the module with a reference to the main module
function ui.init(main_module)
    _M = main_module
    return ui
end

return ui
