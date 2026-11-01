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
        colored = false,
        update_in_insert = false,
        always_visible = true,
    }

    local diff = {
        'diff',
        colored = true,
        symbols = { added = ' ', modified = ' ', removed = ' ' },
        cond = hide_in_width,
    }

    local progress = function()
        local current_line = vim.fn.line('.')
        local total_lines = vim.fn.line('$')
        local chars = { '__', '▁▁', '▂▂', '▃▃', '▄▄', '▅▅', '▆▆', '▇▇', '██' }
        local line_ratio = current_line / total_lines
        local index = math.ceil(line_ratio * #chars)

        if current_line == 1 then
            return 'Top ' .. chars[index]
        elseif current_line == total_lines then
            return 'Bot ' .. chars[index]
        else
            return math.floor(current_line / total_lines * 100) .. '%% ' .. chars[index]
        end
    end

    local function py_venv_status()
        local venv = os.getenv('VIRTUAL_ENV')
        if venv then
            return 'venv 📦'
        end
        return ''
    end

    local function instant_status()
        if vim.g.instant_status then
            return '⚡ pair'
        end
        return ''
    end

    require('lualine').setup({
        options = {
            icons_enabled = true,
            theme = 'auto',
            component_separators = { left = '', right = '' },
            section_separators = { left = '', right = '' },
            disabled_filetypes = {
                'alpha',
                'dashboard',
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
                    file_status = true,
                    path = 1,
                    shorting_target = 30,
                },
            },
            lualine_x = {
                'encoding',
                {
                    'filetype',
                    colored = true,
                    icon_only = false,
                },
                py_venv_status,
                instant_status,
            },
            lualine_y = { progress },
            lualine_z = { 'location' },
        },
        inactive_sections = {
            lualine_a = {},
            lualine_b = {},
            lualine_c = {
                {
                    'filename',
                    file_status = true,
                    path = 2,
                    shorting_target = 30,
                },
            },
            lualine_x = { 'location' },
            lualine_y = {},
            lualine_z = {},
        },
        tabline = {},
        winbar = {},
        inactive_winbar = {},
        extensions = {},
    })
end

return M
