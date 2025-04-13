-- Plugin loader for teleproompter
-- This file automatically loads when Neovim starts

-- Check if plugin is already loaded to avoid duplicates
if vim.g.loaded_teleproompter then
    return
end
vim.g.loaded_teleproompter = true

-- Do not load in VSCode Neovim
if vim.g.vscode then
    return
end

-- Defer loading until after Neovim is fully started for better startup time
vim.defer_fn(function()
    -- Define user command to initialize teleproompter
    vim.api.nvim_create_user_command("TeleproompterSetup", function(opts)
        require("teleproompter").setup(opts.args)
    end, {
        nargs = "?",
        desc = "Initialize Teleproompter with optional config"
    })

    -- Load teleproompter only when explicitly requested or when certain filetypes are opened
    local function setup_on_filetype()
        -- Initialize teleproompter with default config
        require("teleproompter").setup()
        -- Remove the autocommand to prevent multiple initializations
        vim.api.nvim_del_augroup_by_name("TeleproompterAutoSetup")
    end

    -- Create autocommand group
    local augroup = vim.api.nvim_create_augroup("TeleproompterAutoSetup", { clear = true })

    -- Create autocommand to setup teleproompter on certain filetypes
    vim.api.nvim_create_autocmd("FileType", {
        group = augroup,
        pattern = { 'lua', 'python', 'javascript', 'typescript', 'markdown', 'rust', 'go' },
        callback = setup_on_filetype,
        desc = "Auto-setup Teleproompter for supported filetypes"
    })
end, 0)
