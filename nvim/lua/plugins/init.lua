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
    { 'dstein64/vim-startuptime', event = 'VeryLazy', cmd = 'StartupTime' },
    { 'max397574/better-escape.nvim', event = 'VeryLazy', config = true },
    {
        'iamcco/markdown-preview.nvim',
        build = 'cd app && npm install',
        ft = 'markdown',
        keys = { { '<leader>mp', '<cmd>MarkdownPreviewToggle<cr>', desc = 'Markdown Preview' } },
    },
    { 'lambdalisue/suda.vim', event = 'VeryLazy' },
    { 'm4xshen/autoclose.nvim', event = 'VeryLazy', config = true },
    { 'danymat/neogen', event = 'VeryLazy', config = true },
    { 'mg979/vim-visual-multi', event = 'VeryLazy' },
    { 'mbbill/undotree', event = 'VeryLazy' },
    { 'rmagatti/goto-preview', event = 'VeryLazy', config = true },
    { 'skywind3000/asyncrun.vim', ft = { 'go', 'lua', 'tex', 'html' } },
    { 'xiyaowong/nvim-cursorword', event = 'VeryLazy' },
    { 'norcalli/nvim-colorizer.lua', event = 'VeryLazy', config = true },
    { 'j-hui/fidget.nvim', branch = 'legacy', event = 'LspAttach', config = true },
    { 'yanskun/gotests.nvim', ft = 'go', config = true },
    { 'folke/neodev.nvim', opts = {} },
    { 'tzachar/highlight-undo.nvim', event = 'VeryLazy', config = true },
    { 'icholy/lsplinks.nvim', ft = 'go', config = true },
    { 'maxandron/goplements.nvim', ft = 'go', opts = {} },
}
