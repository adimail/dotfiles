local M = {
    'glepnir/lspsaga.nvim',
    ft = { 'go', 'lua', 'sh' },
}

function M.config()
    require('lspsaga').setup({
        ui = {
            border = 'rounded',
            title = true,
            winblend = 0,
            expand = '',
            collapse = '',
            code_action = '󰛨',
            diagnostic = '',
            incoming = ' ',
            outgoing = ' ',
            hover = ' ',
            kind = {},
        },
        hover = {
            max_width = 0.5,
            max_height = 0.8,
            open_link = 'gx',
            open_cmd = '!chrome',
        },
        diagnostic = {
            show_code_action = true,
            show_source = true,
            jump_num_shortcut = true,
            max_width = 0.7,
            custom_fix = nil,
            custom_msg = nil,
            text_hl_follow = false,
            keys = { exec_action = 'o', quit = 'q', go_action = 'g' },
        },
        code_action = { num_shortcut = true, keys = { quit = 'q', exec = '<CR>' } },
        lightbulb = {
            enable = true,
            enable_in_insert = true,
            -- cache_code_action = true,
            sign = true,
            sign_priority = 40,
            virtual_text = false,
        },
        preview = { lines_above = 0, lines_below = 10 },
        scroll_preview = { scroll_down = '<C-f>', scroll_up = '<C-b>' },
        request_timeout = 2000,
        finder = {
            keys = {
                shuttle = '[w',
                toggle_or_open = { 'o', '<CR>' },
                vsplit = 'v',
                split = 's',
                tabe = 't',
                quit = { 'q', '<ESC>' },
            },
        },
        definition = {
            keys = {
                edit = 'o',
                vsplit = '<C-v>',
                split = '<C-s>',
                tabe = '<C-c>t',
                quit = 'q',
                close = '<Esc>',
            },
        },
        rename = {
            keys = {
                quit = '<C-c>',
                exec = '<CR>',
                mark = 'x',
                confirm = '<CR>',
                in_select = true,
            },
        },
        implement = {
            enable = true,
            sign = true,
            virtual_text = true,
        },
        symbol_in_winbar = {
            enable = false,
            separator = ' ',
            hide_keyword = true,
            show_file = true,
            folder_level = 2,
            respect_root = false,
            color_mode = true,
        },
        outline = {
            keys = {
                jump = 'j',
                quit = 'q',
                up = '<Up>',
                down = '<Down>',
            },
        },
        callhierarchy = {
            show_detail = false,
            keys = {
                edit = 'e',
                vsplit = 's',
                split = 'i',
                tabe = 't',
                jump = 'o',
                quit = 'q',
                expand_collapse = 'u',
            },
        },
        beacon = { enable = true, frequency = 7 },
        server_filetype_map = {},
    })

    -- Hover documentation with Lspsaga when no fold is under cursor
    vim.keymap.set('n', 'K', function()
        local winid = require('ufo').peekFoldedLinesUnderCursor()
        if not winid then
            -- Show LSP hover doc if no fold is under cursor
            vim.cmd([[ Lspsaga hover_doc ]])
        end
    end)
end

return M
