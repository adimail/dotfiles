local M = {
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy',
}

function M.config()
    if vim.g.started_by_firenvim then
        return
    end

    local hide_in_width = function()
        return vim.fn.winwidth(0) > 80
    end

    local diagnostics = {
        'diagnostics',
        sources = { 'nvim_diagnostic' },
        sections = { 'error', 'warn' },
        symbols = { error = ' ', warn = ' ' },
        -- symbols = { error = "  ", warn = "  " },
        colored = false,
        update_in_insert = false,
        always_visible = true,
    }

    local winbar_cfg = {}
    local inactive_winbar_cfg = {}

    local diff = {
        'diff',
        colored = true,
        symbols = { added = ' ', modified = ' ', removed = ' ' }, -- changes diff symbols
        cond = hide_in_width,
    }
    -- cool function for progress
    local progress = function()
        local current_line = vim.fn.line('.')
        local total_lines = vim.fn.line('$')
        local chars =
            { '__', '▁▁', '▂▂', '▃▃', '▄▄', '▅▅', '▆▆', '▇▇', '██' }
        local line_ratio = current_line / total_lines
        local index = math.ceil(line_ratio * #chars)

        if current_line == 1 then
            return 'Top' .. ' ' .. chars[index]
        elseif current_line == total_lines then
            return 'Bot' .. ' ' .. chars[index]
        else
            return math.floor(current_line / total_lines * 100) .. '%%' .. ' ' .. chars[index]
        end
    end

    local conditions = {
        buffer_not_empty = function()
            return vim.fn.empty(vim.fn.expand('%:t')) ~= 1
        end,
        check_git_workspace = function()
            local filepath = vim.fn.expand('%:p:h')
            local gitdir = vim.fn.finddir('.git', filepath .. ';')
            return gitdir and #gitdir > 0 and #gitdir < #filepath
        end,
    }

    -- Function to check if a virtual environment is active
    local function get_venv_name()
        local venv = os.getenv('VIRTUAL_ENV')
        if venv then
            -- Extract the name of the virtual environment
            return vim.fn.fnamemodify(venv, ':t')
        end
        return nil
    end

    -- Function to add (py venv) to the right of encoding if a virtual environment is active
    local function py_venv_status()
        local venv_name = get_venv_name()
        if venv_name then
            return 'venv 📦' -- Add label if venv is active
        end
        return ''
    end

    require('lualine').setup({
        options = {
            icons_enabled = true,
            -- theme = "gruvbox-material",
            theme = 'auto',
            component_separators = { left = '', right = '' },
            section_separators = { left = '', right = '' },
            -- "dapui_watches", "dapui_stacks", "dapui_scopes", "dapui_breakpoints"
            disabled_filetypes = {
                'alpha',
                'dashboard',
                'NvimTree',
                'neo-tree',
                'sagaoutline',
                'tagbar',
            },
            always_divide_middle = true,
        },
        sections = {
            lualine_a = { 'mode' },
            lualine_b = { 'branch', diff, diagnostics },
            lualine_c = {
                {
                    'filename',
                    file_status = true, -- displays file status (readonly status, modified status)
                    path = 1, -- 0 = just filename, 1 = relative path, 2 = absolute path
                    shorting_target = 30, -- Shortens path to leave 40 space in the window
                    -- for other components. Terrible name any suggestions?
                },
                -- { require('auto-session-library').current_session_name },
            },
            lualine_x = {
                'encoding',
                -- "fileformat",
                {
                    'filetype',
                    colored = true, -- displays filetype icon in color if set to `true
                    icon_only = false, -- Display only icon for filetype
                },
                py_venv_status,
            },
            lualine_y = {
                -- "progress",
                progress,
            },
            lualine_z = { 'location' },
        },
        inactive_sections = {
            lualine_a = {},
            lualine_b = {},
            lualine_c = {
                {
                    'filename',
                    file_status = true, -- displays file status (readonly status, modified status)
                    path = 2, -- 0 = just filename, 1 = relative path, 2 = absolute path
                    shorting_target = 30, -- Shortens path to leave 40 space in the window
                    -- for other components. Terrible name any suggestions?
                },
                -- { require('auto-session-library').current_session_name },
            },
            lualine_x = { 'location' },
            lualine_y = {},
            lualine_z = {},
        },
        tabline = {},
        winbar = winbar_cfg,
        inactive_winbar = inactive_winbar_cfg,
        extensions = {},
    })
end

return M
