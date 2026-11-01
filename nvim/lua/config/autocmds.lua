local function augroup(name)
    return vim.api.nvim_create_augroup('agou_' .. name, { clear = true })
end

vim.api.nvim_create_autocmd('FileType', {
    pattern = 'go',
    callback = function(event)
        vim.opt_local.expandtab = false
        vim.opt_local.shiftwidth = 4
        vim.opt_local.softtabstop = 4
        vim.opt_local.tabstop = 4

        local bopts = { buffer = event.buf, noremap = true, silent = true }
        vim.keymap.set('n', '<Leader>rp', function()
            vim.cmd('split | terminal go run .')
        end, bopts)
        vim.keymap.set('n', '<Leader>gb', function()
            vim.cmd('split | terminal go build .')
        end, bopts)
    end,
})

vim.api.nvim_create_autocmd('TextYankPost', {
    group = augroup('highlight_yank'),
    callback = function()
        vim.highlight.on_yank({ higroup = 'IncSearch', timeout = 200 })
    end,
})

vim.api.nvim_create_autocmd('VimResized', {
    group = augroup('resize_splits'),
    callback = function()
        vim.cmd('tabdo wincmd =')
    end,
})

vim.api.nvim_create_autocmd('BufReadPost', {
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(0) then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'help', 'qf', 'lspinfo', 'startuptime', 'checkhealth', 'man' },
    callback = function(event)
        vim.keymap.set('n', 'q', '<cmd>close<cr>', { buffer = event.buf, silent = true })
    end,
})
