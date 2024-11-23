local M = {
    'glepnir/dashboard-nvim',
    event = 'VimEnter',
    dependencies = { { 'nvim-tree/nvim-web-devicons' } },
}

function M.config()
    local db = require('dashboard')
    db.setup({
        theme = 'hyper',
        config = {
            week_header = { enable = true },
            packages = { enable = false },
            mru = {
                limit = 10,
                icon = ' ',
                label = 'Recent Files',
                cwd_only = true,
            },
            shortcut = {
                {
                    desc = '󰚰 Update',
                    group = '@property',
                    action = 'Lazy update',
                    key = 'u',
                },
                {
                    desc = ' Files',
                    group = 'Label',
                    action = 'Telescope find_files',
                    key = 'f',
                },
                {
                    desc = ' Grep',
                    group = 'Label',
                    action = 'Telescope live_grep',
                    key = 'g',
                },
                {
                    desc = '󰗼 Quit',
                    group = 'Error',
                    action = 'qa',
                    key = 'q',
                },
            },
            footer = {},
        },
    })
end

return M
