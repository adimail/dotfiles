return {
    {
        'sainnhe/gruvbox-material',
        lazy = false,
        priority = 1000,
        config = function()
            vim.g.gruvbox_material_background = 'hard'
            vim.g.gruvbox_material_better_performance = 1
            vim.g.gruvbox_material_enable_italic = 1
            vim.cmd.colorscheme('gruvbox-material')
        end,
    },
    {
        'iamcco/markdown-preview.nvim',
        build = 'cd app && npm install',
        ft = 'markdown',
        keys = { { '<leader>mp', '<cmd>MarkdownPreviewToggle<cr>', desc = 'Markdown Preview' } },
    },
    { 'lambdalisue/suda.vim', event = 'VeryLazy' },
    { 'm4xshen/autoclose.nvim', event = 'VeryLazy', config = true },
    { 'danymat/neogen', event = 'VeryLazy', config = true },
    { 'mbbill/undotree', event = 'VeryLazy' },
    {
        'norcalli/nvim-colorizer.lua',
        ft = { 'css', 'scss', 'html', 'javascriptreact', 'typescriptreact' },
        config = function()
            require('colorizer').setup({
                'css',
                'scss',
                'html',
                'javascriptreact',
                'typescriptreact',
            })
        end,
    },
    { 'yanskun/gotests.nvim', ft = 'go', config = true },
    { 'icholy/lsplinks.nvim', ft = 'go', config = true },
}
