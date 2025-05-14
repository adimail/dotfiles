_G.zen_mode_active = false
_G.zen_mode_original_settings = {}

-- Helper function to safely call plugin functions
local function safe_call(module_name, func_path, ...)
    local status, mod = pcall(require, module_name)
    if not status then
        -- Module not found or failed to load
        return false, 'Module ' .. module_name .. ' not found'
    end

    local func = mod
    -- Traverse the path if func_path is like 'tree.is_visible'
    for _, part in ipairs(vim.split(func_path, '.', { plain = true })) do
        if func and func[part] then
            func = func[part]
        else
            return false, 'Function path ' .. func_path .. ' not found in ' .. module_name
        end
    end

    if type(func) ~= 'function' then
        return false, module_name .. '.' .. func_path .. ' is not a function'
    end

    local call_status, result = pcall(func, ...)
    if not call_status then
        -- Error during function execution
        return false,
            'Error calling ' .. module_name .. '.' .. func_path .. ': ' .. tostring(result)
    end

    return true, result
end

-- Function to toggle Zen mode
function ToggleZenMode()
    local wo = vim.wo -- Window options for current window
    local o = vim.o -- Global options
    -- local g = vim.g -- Removed as it was unused
    local current_bufnr = vim.api.nvim_get_current_buf() -- Get current buffer number

    if _G.zen_mode_active then
        -- =============================
        -- Exit Zen Mode
        -- =============================
        print('Zen Mode')

        -- Restore window options
        if _G.zen_mode_original_settings.number ~= nil then
            wo.number = _G.zen_mode_original_settings.number
        end
        if _G.zen_mode_original_settings.relativenumber ~= nil then
            wo.relativenumber = _G.zen_mode_original_settings.relativenumber
        end
        if _G.zen_mode_original_settings.signcolumn ~= nil then
            wo.signcolumn = _G.zen_mode_original_settings.signcolumn
        end
        if _G.zen_mode_original_settings.foldcolumn ~= nil then
            wo.foldcolumn = _G.zen_mode_original_settings.foldcolumn
        end
        if _G.zen_mode_original_settings.colorcolumn ~= nil then
            wo.colorcolumn = _G.zen_mode_original_settings.colorcolumn
        end

        -- Restore global options
        if _G.zen_mode_original_settings.laststatus ~= nil then
            o.laststatus = _G.zen_mode_original_settings.laststatus
        end

        -- Restore diagnostics for the current buffer
        vim.diagnostic.enable(nil, { bufnr = current_bufnr })

        -- Restore inlay hints
        if _G.zen_mode_original_settings.inlay_hints_enabled then
            safe_call('vim.lsp.inlay_hint', 'enable', true, { bufnr = current_bufnr })
        end

        -- Restore NvimTree
        if _G.zen_mode_original_settings.nvim_tree_was_open then
            safe_call('nvim-tree.api', 'tree.open')
        end

        -- Restore Gitsigns current line blame
        if _G.zen_mode_original_settings.gitsigns_blame_enabled then
            -- Check current state before toggling to ensure it ends up enabled
            local gs_config_ok, gs_config = pcall(require, 'gitsigns.config')
            if gs_config_ok and gs_config.config and not gs_config.config.current_line_blame then
                vim.cmd('Gitsigns toggle_current_line_blame')
            end
        end

        -- Restore Scrollbar
        if _G.zen_mode_original_settings.scrollbar_enabled then
            safe_call('scrollbar', 'show', true)
        end

        -- Restore Lualine (needed if laststatus was changed)
        local lualine_ok, lualine = pcall(require, 'lualine')
        if lualine_ok and lualine.refresh then
            pcall(function()
                lualine.refresh()
            end)
        end

        -- Reset state
        _G.zen_mode_active = false
        _G.zen_mode_original_settings = {}
    else
        -- =============================
        -- Enter Zen Mode
        -- =============================
        print('Zen Mode')

        -- Check Gitsigns blame state
        local gitsigns_blame_enabled = false
        local gs_config_ok, gs_config = pcall(require, 'gitsigns.config')
        if gs_config_ok and gs_config.config and gs_config.config.current_line_blame then
            gitsigns_blame_enabled = true
        end

        -- Check Scrollbar state (Assume enabled if module is loaded)
        local scrollbar_enabled = false
        local scrollbar_ok, _ = pcall(require, 'scrollbar')
        if scrollbar_ok then
            scrollbar_enabled = true
        end

        -- Save original settings
        _G.zen_mode_original_settings = {
            -- Window options
            number = wo.number,
            relativenumber = wo.relativenumber,
            signcolumn = wo.signcolumn,
            foldcolumn = wo.foldcolumn,
            colorcolumn = wo.colorcolumn,
            -- Global options
            laststatus = o.laststatus,
            -- LSP/Diagnostic states
            inlay_hints_enabled = vim.lsp.inlay_hint
                and select(2, safe_call('vim.lsp.inlay_hint', 'is_enabled', current_bufnr)), -- Get the result
            -- NvimTree state
            nvim_tree_was_open = select(2, safe_call('nvim-tree.api', 'tree.is_visible')), -- Get the result
            -- Other plugins
            gitsigns_blame_enabled = gitsigns_blame_enabled,
            scrollbar_enabled = scrollbar_enabled,
        }

        -- Apply Zen settings
        wo.relativenumber = false -- Turn off relative numbers
        wo.number = true -- Ensure absolute numbers are on
        wo.signcolumn = 'no' -- Hide sign column (diagnostics, git signs)
        wo.foldcolumn = '0' -- Hide fold column
        wo.colorcolumn = '' -- Hide color column

        o.laststatus = 0 -- Hide statusline (Lualine depends on this)

        -- Disable diagnostics for the current buffer
        vim.diagnostic.enable(false, { bufnr = current_bufnr })

        -- Disable inlay hints for the current buffer
        safe_call('vim.lsp.inlay_hint', 'enable', false, { bufnr = current_bufnr })

        -- Close NvimTree if it was open
        if _G.zen_mode_original_settings.nvim_tree_was_open then
            safe_call('nvim-tree.api', 'tree.close')
        end

        -- Disable Gitsigns current line blame if it was enabled
        if _G.zen_mode_original_settings.gitsigns_blame_enabled then
            vim.cmd('Gitsigns toggle_current_line_blame')
        end

        -- Hide Scrollbar if it was enabled
        if _G.zen_mode_original_settings.scrollbar_enabled then
            safe_call('scrollbar', 'show', false)
        end

        -- Set state
        _G.zen_mode_active = true
    end
end
