local bind = vim.keymap.set
local opts = { noremap = true, silent = true }

bind('n', 'gD', vim.lsp.buf.declaration, opts)
bind('n', 'gi', vim.lsp.buf.implementation, opts)
bind('n', '<leader>D', vim.lsp.buf.type_definition, opts)
bind('n', '<leader>z', '<cmd>lua ToggleZenMode()<CR>', opts)
bind('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
bind('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
bind('n', '<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
end, opts)

bind('n', '<leader>fa', function()
    vim.cmd('args **/*')
    vim.cmd('argdo silent! ConformFormat | update')
end, opts)

bind('n', '<leader>e', vim.diagnostic.open_float, opts)
bind('n', '[d', vim.diagnostic.goto_prev, opts)
bind('n', ']d', vim.diagnostic.goto_next, opts)
bind('n', '<leader>q', vim.diagnostic.setloclist, opts)
bind('n', '<leader>ld', vim.diagnostic.setloclist, opts)
bind('n', '<leader>qd', vim.diagnostic.setqflist, opts)

bind('n', 'u', '<CMD>undo<CR>', opts)
bind('n', '<C-r>', '<CMD>redo<CR>', opts)
bind('x', 'p', '"_dP', opts)

bind('c', 'W', 'w', opts)
bind('c', 'WQ', 'wq', opts)
bind('c', 'Wq', 'wq', opts)
bind('c', 'QA', 'qa', opts)
bind('n', '<C-_>', 'gcc', { remap = true })
bind('v', '<C-_>', 'gc', { remap = true })

bind('n', 'd', '"_d', opts)
bind('v', 'd', '"_d', opts)
bind('n', 'c', '"_c', opts)
bind('v', 'c', '"_c', opts)

bind('n', '<C-o>', '<C-o>zz', opts)
bind('n', '<C-i>', '<C-i>zz', opts)
bind('n', 'H', 'g^', opts)
bind('n', 'L', 'g_', opts)
bind('v', 'H', 'g^', opts)
bind('v', 'L', 'g_', opts)

bind('n', '<leader>ll', '<CMD>bp<CR>', opts)
bind('n', '<leader>hh', '<CMD>bn<CR>', opts)
bind('n', '<leader>bd', '<CMD>bdelete<CR>', opts)
bind('n', '<leader>ba', '<CMD>bufdo bd<CR>', opts)

bind('n', '<S-Up>', '<cmd>resize +2<CR>', opts)
bind('n', '<S-Down>', '<cmd>resize -2<CR>', opts)
bind('n', '<S-Right>', '<cmd>vertical resize +5<CR>', opts)
bind('n', '<S-Left>', '<cmd>vertical resize -5<CR>', opts)

bind('n', '<C-h>', '<C-w>h', opts)
bind('n', '<C-j>', '<C-w>j', opts)
bind('n', '<C-k>', '<C-w>k', opts)
bind('n', '<C-l>', '<C-w>l', opts)

bind('n', '<C-a>', 'ggVG', opts)
bind('n', '<C-Space>', 'ggVGy', opts)

bind('v', '<tab>', '>gv', opts)
bind('v', '<S-tab>', '<gv', opts)

bind('n', 'z<space>', 'zt', opts)
bind('n', '<leader>st', function()
    vim.opt.spell = not vim.opt.spell:get()
end, opts)
