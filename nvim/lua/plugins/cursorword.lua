local M = {
    'nyngwang/murmur.lua',
    lazy = false,
    enabled = false,
}

function M.config()
    local group_name = 'cursorword_group'
    vim.api.nvim_create_augroup(group_name, { clear = true })

    -- Configure murmur settings
    require('murmur').setup({
        max_len = 80,
        min_len = 3, -- Min length for cursorword highlighting
        exclude_filetypes = {}, -- Optionally add filetypes to exclude

        -- Callbacks for custom behavior
        callbacks = {
            -- Close floating diagnostics when entering Insert mode
            function()
                vim.cmd('doautocmd InsertEnter')
                vim.w.diag_shown = false
            end,
        },
    })

    -- CursorHold event to display diagnostics when hovering over a cursorword
    vim.api.nvim_create_autocmd('CursorHold', {
        group = group_name,
        pattern = '*',
        callback = function()
            -- Skip if diagnostic float is already shown
            if vim.w.diag_shown then
                return
            end

            -- Show diagnostic float for cursorword if available
            if vim.w.cursor_word ~= '' then
                vim.diagnostic.open_float()
                vim.w.diag_shown = true
            end
        end,
    })

    -- Apply special color scheme settings for cursorword highlighting
    vim.api.nvim_create_autocmd('ColorScheme', {
        group = group_name,
        pattern = '*',
        callback = function()
            -- Custom cursorword color for the 'typewriter-night' color scheme (adjust to your theme)
            vim.cmd([[
                hi murmur_cursor_rgb guifg=#0a100d guibg=#ffee32
            ]])
        end,
    })
end

return M
