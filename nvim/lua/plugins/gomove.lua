local M = {
    'booperlv/nvim-gomove',
    event = 'VeryLazy',
}

function M.config()
    local map = vim.api.nvim_set_keymap

    -- Move selected text in visual mode (non-sticky)
    -- <S-h>, <S-j>, <S-k>, <S-l>: Move left, down, up, and right respectively
    -- <S-Left>, <S-Down>, <S-Up>, <S-Right>: Move left, down, up, and right respectively
    map('v', '<S-h>', '<Plug>GoNSMLeft', {})
    map('v', '<S-j>', '<Plug>GoNSMDown', {})
    map('v', '<S-k>', '<Plug>GoNSMUp', {})
    map('v', '<S-l>', '<Plug>GoNSMRight', {})
    map('v', '<S-Left>', '<Plug>GoNSMLeft', {})
    map('v', '<S-Down>', '<Plug>GoNSMDown', {})
    map('v', '<S-Up>', '<Plug>GoNSMUp', {})
    map('v', '<S-Right>', '<Plug>GoNSMRight', {})

    -- Move selected text in visual mode (sticky)
    -- Sticky mode keeps the selection while moving the text
    map('x', '<S-h>', '<Plug>GoVSMLeft', {})
    map('x', '<S-j>', '<Plug>GoVSMDown', {})
    map('x', '<S-k>', '<Plug>GoVSMUp', {})
    map('x', '<S-l>', '<Plug>GoVSMRight', {})

    -- Duplicate selected text in visual mode
    -- <C-h>, <C-j>, <C-k>, <C-l>: Duplicate left, down, up, and right respectively
    map('x', '<C-h>', '<Plug>GoVSDLeft', {})
    map('x', '<C-j>', '<Plug>GoVSDDown', {})
    map('x', '<C-k>', '<Plug>GoVSDUp', {})
    map('x', '<C-l>', '<Plug>GoVSDRight', {})

    -- Plugin configuration
    require('gomove').setup({
        map_defaults = true, -- Use plugin's default key mappings
        reindent = true, -- Automatically reindent lines moved vertically
        undojoin = true, -- Combine undo actions for sequential moves
        move_past_end_col = false, -- Prevent moving past the last column horizontally
    })

    --[[
    Test data for trying the key mappings:
    aaa bbb ccc ddd
    eee fff ggg hhh
    iii jjj kkk lll
    aaa bbb ccc ddd
    aaa bbb ccc ddd
    aaa bbb ccc ddd
    ]]

    -- Additional ideas:
    -- 1. If you want to disable default mappings globally, set map_defaults = false and define your own bindings.
    -- 2. Consider adding 'n' mode mappings for moving or duplicating lines outside of visual mode if needed.
    -- 3. If you often use block selections in visual block mode (<C-v>), test these mappings for compatibility.
end

return M
