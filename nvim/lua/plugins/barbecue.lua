local spec = {
    'utilyre/barbecue.nvim',
    -- event = 'UIEnter',
    ft = {
        'go',
        'lua',
        'yaml',
        'yml',
        'markdown',
        'python',
        'cpp',
        'json',
        'ts',
        'astro',
        'html',
        'shfmt',
        'sh',
    },
    dependencies = {
        'neovim/nvim-lspconfig',
        'smiteshp/nvim-navic',
        'nvim-tree/nvim-web-devicons',
    },
}

function spec.config()
    require('barbecue').setup({
        theme = {
            dirname = { fg = '#ffffff' },
        },
    })
end

return spec
