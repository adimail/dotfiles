_G.zen_mode_active = false
_G.zen_mode_original_settings = {}

local function safe_call(module_name, func_path, ...)
    local status, mod = pcall(require, module_name)
    if not status then
        return false, 'Module ' .. module_name .. ' not found'
    end

    local func = mod
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
        return false,
            'Error calling ' .. module_name .. '.' .. func_path .. ': ' .. tostring(result)
    end

    return true, result
end

function ToggleZenMode()
    local wo = vim.wo
    local o = vim.o
    local current_bufnr = vim.api.nvim_get_current_buf()

    if _G.zen_mode_active then
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

        if _G.zen_mode_original_settings.laststatus ~= nil then
            o.laststatus = _G.zen_mode_original_settings.laststatus
        end

        vim.diagnostic.enable(nil, { bufnr = current_bufnr })

        if _G.zen_mode_original_settings.inlay_hints_enabled then
            safe_call('vim.lsp.inlay_hint', 'enable', true, { bufnr = current_bufnr })
        end

        if _G.zen_mode_original_settings.gitsigns_blame_enabled then
            local gs_config_ok, gs_config = pcall(require, 'gitsigns.config')
            if gs_config_ok and gs_config.config and not gs_config.config.current_line_blame then
                vim.cmd('Gitsigns toggle_current_line_blame')
            end
        end

        local lualine_ok, lualine = pcall(require, 'lualine')
        if lualine_ok and lualine.refresh then
            pcall(function()
                lualine.refresh()
            end)
        end

        _G.zen_mode_active = false
        _G.zen_mode_original_settings = {}
    else
        local gitsigns_blame_enabled = false
        local gs_config_ok, gs_config = pcall(require, 'gitsigns.config')
        if gs_config_ok and gs_config.config and gs_config.config.current_line_blame then
            gitsigns_blame_enabled = true
        end

        _G.zen_mode_original_settings = {
            number = wo.number,
            relativenumber = wo.relativenumber,
            signcolumn = wo.signcolumn,
            foldcolumn = wo.foldcolumn,
            colorcolumn = wo.colorcolumn,
            laststatus = o.laststatus,
            inlay_hints_enabled = vim.lsp.inlay_hint
                and select(2, safe_call('vim.lsp.inlay_hint', 'is_enabled', current_bufnr)),
            gitsigns_blame_enabled = gitsigns_blame_enabled,
        }

        wo.relativenumber = false
        wo.number = true
        wo.signcolumn = 'no'
        wo.foldcolumn = '0'
        wo.colorcolumn = ''

        o.laststatus = 0

        vim.diagnostic.enable(false, { bufnr = current_bufnr })

        safe_call('vim.lsp.inlay_hint', 'enable', false, { bufnr = current_bufnr })

        if _G.zen_mode_original_settings.gitsigns_blame_enabled then
            vim.cmd('Gitsigns toggle_current_line_blame')
        end

        _G.zen_mode_active = true
    end
end
