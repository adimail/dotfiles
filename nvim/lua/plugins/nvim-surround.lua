local M = {
    'kylechui/nvim-surround',
    version = '*',
    event = 'VeryLazy',
}

function M.config()
    require('nvim-surround').setup()

    vim.keymap.set('x', 'Q', '<Plug>(nvim-surround-visual)', { desc = 'Add surround' })
end

return M
