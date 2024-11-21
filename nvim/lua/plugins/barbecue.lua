local spec = {
    'utilyre/barbecue.nvim',
    -- event = 'UIEnter',
    ft = { 'go', 'lua', 'yaml', 'yml', 'markdown' },
    dependencies = {
        'neovim/nvim-lspconfig',
        'smiteshp/nvim-navic',
        'nvim-tree/nvim-web-devicons', -- optional dependency
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
