local M = {
    'ThePrimeagen/harpoon',
    dependencies = { 'nvim-lua/plenary.nvim' },
    event = 'VeryLazy',
}

function M.config()
    require('harpoon').setup({
        global_settings = {
            save_on_toggle = false,
            save_on_change = true,
            enter_on_sendcmd = false,
            tmux_autoclose_windows = false,
            excluded_filetypes = { 'harpoon' },
            mark_branch = false,
        },
    })

    -- Customizing Harpoon's appearance (colors, highlights)
    vim.cmd([[
        highlight HarpoonWindow guibg=#282828 guifg=#ebdbb2
        highlight HarpoonTabLine guibg=#3c3836 guifg=#b8bb26
        highlight HarpoonTabLineSel guibg=#504945 guifg=#d79921
    ]])
end

return M
