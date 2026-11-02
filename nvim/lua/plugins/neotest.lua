return {
    {
        'nvim-neotest/neotest',
        dependencies = {
            'nvim-neotest/nvim-nio',
            'nvim-lua/plenary.nvim',
            'nvim-treesitter/nvim-treesitter',
            'fredrikaverpil/neotest-golang',
        },
        config = function()
            require('neotest').setup({
                adapters = {
                    require('neotest-golang'),
                },
            })
        end,
        keys = {
            {
                '<leader>tg',
                function()
                    require('neotest').run.run({ suite = false, strategy = 'dap' })
                end,
                desc = 'Debug nearest test',
            },
        },
    },
}
