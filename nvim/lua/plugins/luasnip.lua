-- FILE: lua/plugins/luasnip.lua
local M = {
    'L3MON4D3/LuaSnip',
    event = {
        'InsertEnter',
        'CmdlineEnter',
    },
    dependencies = {
        'rafamadriz/friendly-snippets',
        config = function()
            -- EDIT: /Users/agou-ops/.local/share/nvim/lazy/friendly-snippets/snippets
            require('luasnip.loaders.from_vscode').lazy_load()
        end,
    },
}

function M.config()
    local luasnip = require('luasnip')

    luasnip.config.setup({
        history = false,
        enable_autosnippets = true,
        update_events = { 'TextChanged', 'TextChangedI' },
        region_check_events = { 'CursorMoved', 'CursorMovedI', 'CursorHold' },
    })

    luasnip.filetype_extend('markdown_inline', { 'markdown' })

    -- custom snippets
    require('luasnip.loaders.from_lua').load({ paths = { '~/.config/nvim/lua/snippets' } })
end
return M
