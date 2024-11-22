local M = {
    'petertriho/nvim-scrollbar',
    event = 'VeryLazy',
    dependencies = { 'lewis6991/gitsigns.nvim', 'kevinhwang91/nvim-hlslens' },
    enabled = true,
}

function M.config()
    -- Gitsigns integration
    require('scrollbar.handlers.gitsigns').setup()

    -- Search highlighting with hlslens
    require('scrollbar.handlers.search').setup()

    -- Scrollbar setup
    require('scrollbar').setup({
        show = true,
        set_highlights = true,
        folds = 1000, -- Disable if buffer exceeds this many lines
        max_lines = false, -- No limit on the number of lines
        handle = {
            text = ' ',
            highlight = 'ScrollbarHandle', -- Highlight group for customization
            hide_if_all_visible = true,
        },
        excluded_buftypes = { 'terminal' },
        excluded_filetypes = { 'prompt', 'TelescopePrompt', 'NvimTree' },
        autocmd = {
            render = {
                'BufWinEnter',
                'TabEnter',
                'TermEnter',
                'WinEnter',
                'CmdwinLeave',
                'TextChanged',
                'VimResized',
                'WinScrolled',
            },
        },
        handlers = {
            diagnostic = true,
            gitsigns = true,
            search = true,
        },
    })

    -- custom scrollbar config
    vim.api.nvim_set_hl(0, 'ScrollbarHandle', {
        fg = '#FFFFFF', -- White text
        bg = nil,
        blend = 50, -- 50% transparency
        bold = true, -- Bold text
    })
end

return M
