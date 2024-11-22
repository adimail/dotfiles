local M = {
    'kazhala/close-buffers.nvim',
    event = 'VeryLazy',
}

function M.config()
    require('close_buffers').setup({
        filetype_ignore = { 'NvimTree', 'tagbar', 'help', 'qf', 'lspinfo' },
        file_glob_ignore = {},
        file_regex_ignore = {},
        preserve_window_layout = { 'this' }, -- Preserve window layout for the current buffer
        next_buffer_cmd = function(windows)
            require('bufferline').cycle(1) -- Switch to next buffer in the bufferline
            local bufnr = vim.api.nvim_get_current_buf()

            -- Ensure all windows are updated with the next buffer
            for _, window in ipairs(windows) do
                vim.api.nvim_win_set_buf(window, bufnr)
            end
        end,
    })
end

return M
