local function augroup(name)
    return vim.api.nvim_create_augroup('agou_' .. name, { clear = true })
end

vim.api.nvim_create_autocmd('BufEnter', {
    pattern = '*.go',
    callback = function()
        local bopts = { buffer = true, noremap = true, silent = true }
        vim.keymap.set(
            'n',
            '<Leader>rr',
            ':AsyncRun -mode=term -pos=bottom -rows=10 go run $(VIM_FILEPATH)<CR>',
            bopts
        )
        vim.keymap.set(
            'n',
            '<Leader>rR',
            ':AsyncRun -mode=term -pos=bottom -rows=85 go run $(VIM_FILEPATH)<CR>',
            bopts
        )
        vim.keymap.set(
            'n',
            '<Leader>rt',
            ':AsyncRun -mode=term -pos=toggleterm2 go run $(VIM_FILEPATH)<CR>',
            bopts
        )
        vim.keymap.set(
            'n',
            '<Leader>rT',
            ':AsyncRun -mode=term -pos=macos go run $(VIM_FILEPATH)<CR>',
            bopts
        )
        vim.keymap.set(
            'n',
            '<Leader>rp',
            ':AsyncRun -mode=term -pos=bottom -rows=10 go run .<CR>',
            bopts
        )
        vim.keymap.set(
            'n',
            '<Leader>rP',
            ':AsyncRun -mode=term -pos=macos -rows=10 go run .<CR>',
            bopts
        )
        vim.keymap.set(
            'n',
            '<Leader>gb',
            ':AsyncRun -mode=term -pos=bottom -rows=10 go build .<CR>',
            bopts
        )
    end,
})

vim.api.nvim_create_autocmd('FileType', {
    pattern = 'go',
    callback = function()
        vim.opt_local.expandtab = false
        vim.opt_local.shiftwidth = 4
        vim.opt_local.softtabstop = 4
        vim.opt_local.tabstop = 4
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

vim.api.nvim_create_autocmd('BufWritePre', {
    group = augroup('trim_whitespace'),
    callback = function()
        local save = vim.fn.winsaveview()
        vim.cmd([[keeppatterns %s/\s\+$//e]])
        vim.fn.winrestview(save)
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

vim.api.nvim_create_autocmd({ 'BufLeave', 'FocusLost' }, {
    callback = function()
        if
            vim.bo.modified
            and not vim.bo.readonly
            and vim.fn.expand('%') ~= ''
            and vim.bo.buftype == ''
        then
            vim.api.nvim_command('silent update')
        end
    end,
})

vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'help', 'qf', 'lspinfo', 'startuptime', 'checkhealth', 'man' },
    callback = function(event)
        vim.keymap.set('n', 'q', '<cmd>close<cr>', { buffer = event.buf, silent = true })
    end,
})
