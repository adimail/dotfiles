local M = {
    'L3MON4D3/LuaSnip',
    event = {
        'InsertEnter',
        'CmdlineEnter',
    },
}

function M.config()
    local luasnip = require('luasnip')

    luasnip.config.setup({
        history = false,
        enable_autosnippets = true,
        update_events = { 'InsertLeave' },
        region_check_events = { 'CursorHold', 'InsertLeave' },
    })

    luasnip.filetype_extend('markdown_inline', { 'markdown' })
    require('luasnip.loaders.from_lua').load({ paths = { vim.fn.stdpath('config') .. '/lua/snippets' } })
end

return M
