return {
    'MagicDuck/grug-far.nvim',
    event = 'VeryLazy',
    config = function()
        require('grug-far').setup({
            -- options, see https://github.com/MagicDuck/grug-far.nvim
            headerMaxWidth = 80,
        })
    end,
    keys = {
        {
            '<leader>sr',
            function()
                require('grug-far').open({ transient = true })
            end,
            mode = { 'n', 'v' },
            desc = 'Search and Replace (Grug-far)',
        },
        {
            '<leader>sw',
            function()
                require('grug-far').open({ prefills = { search = vim.fn.expand('<cword>') } })
            end,
            mode = { 'n' },
            desc = 'Search and Replace Current Word',
        },
    },
}
