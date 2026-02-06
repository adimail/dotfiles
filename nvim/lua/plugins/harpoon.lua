return {
    'ThePrimeagen/harpoon',
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
        {
            '<leader>hx',
            function()
                require('harpoon.mark').add_file()
            end,
            desc = 'Harpoon Mark',
        },
        {
            '<leader>hm',
            function()
                require('harpoon.ui').toggle_quick_menu()
            end,
            desc = 'Harpoon Menu',
        },
        {
            '<leader>hn',
            function()
                require('harpoon.ui').nav_next()
            end,
            desc = 'Harpoon Next',
        },
        {
            '<leader>hp',
            function()
                require('harpoon.ui').nav_prev()
            end,
            desc = 'Harpoon Prev',
        },
    },
    config = function()
        require('harpoon').setup({
            global_settings = { save_on_change = true },
        })
    end,
}
