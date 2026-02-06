return {
    'lewis6991/gitsigns.nvim',
    event = 'VeryLazy',
    keys = {
        {
            '<leader>ga',
            '<cmd>Gitsigns toggle_linehl<CR><BAR><cmd>Gitsigns toggle_deleted<CR>',
            desc = 'Toggle Gitsigns',
        },
        { '<leader>gl', '<cmd>Gitsigns toggle_linehl<CR>', desc = 'Toggle linehl' },
        { '<leader>gd', '<cmd>Gitsigns diffthis<CR>', desc = 'Git Diff' },
    },
    opts = {
        current_line_blame = true,
        current_line_blame_opts = { delay = 0 },
        current_line_blame_formatter = '      <author>, <author_time:%R> - <summary>',
    },
}
