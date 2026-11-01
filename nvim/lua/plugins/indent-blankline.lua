local M = {
    'lukas-reineke/indent-blankline.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
}

function M.config()
    vim.opt.list = true
    vim.opt.listchars:append('eol:⤸')
    vim.opt.listchars:append('space:⋅')
    vim.opt.listchars:append('tab:│ ')

    require('ibl').setup({
        indent = { char = '│' },
        scope = { enabled = false },
        exclude = {
            filetypes = {
                'startify',
                'dashboard',
                'dotooagenda',
                'log',
                'fugitive',
                'gitcommit',
                'packer',
                'vimwiki',
                'markdown',
                'json',
                'txt',
                'vista',
                'help',
                'todoist',
                'peekaboo',
                'git',
                'TelescopePrompt',
                'undotree',
                'flutterToolsOutline',
                '',
            },
        },
    })
end

return M
