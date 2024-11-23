-- ==========================
-- General Settings
-- ==========================
vim.o.timeoutlen = 300 -- Set the timeout length for mapped sequences in milliseconds

-- Keymap utility
local bind = vim.keymap.set
local opts = { noremap = true, silent = true }

-- ==========================
-- Core LSP Keymaps
-- ==========================
bind('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
bind('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
bind('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
bind('n', '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)

-- Workspace Management
bind('n', '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
bind('n', '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
bind(
    'n',
    '<leader>wl',
    '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>',
    opts
)

-- ==========================
-- Diagnostics Keymaps
-- ==========================
bind('n', '<leader>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
bind('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
bind('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
bind('n', '<leader>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)
bind('n', '<leader>ld', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)
bind('n', '<leader>qd', '<cmd>lua vim.diagnostic.setqflist()<CR>', opts)

-- Telescope Diagnostics Integration
bind('n', '<leader>so', '<cmd>lua require("telescope.builtin").lsp_document_symbols()<CR>', opts)
bind('n', '<leader>sd', '<cmd>Telescope diagnostics<CR>', opts)

-- ==========================
-- LSP Saga Keymaps
-- ==========================
-- General
bind('n', 'K', '<cmd>Lspsaga hover_doc<CR>', opts) -- Hover documentation
bind('n', 'gf', '<cmd>Lspsaga finder<CR>', opts) -- Finder
bind('n', '<leader>gf', '<cmd>Lspsaga finder imp<CR>', opts) -- Finder with implementations

-- Code Actions
bind('n', 'gx', '<cmd>Lspsaga code_action<CR>', opts)
bind(
    'n',
    '<leader>ca',
    '<cmd>Lspsaga code_action<CR>',
    vim.tbl_extend('force', opts, { desc = 'Code Action' })
)

-- Rename
bind('n', 'gr', '<cmd>Lspsaga rename<CR>', opts)

-- Navigation
bind('n', 'gd', '<cmd>Lspsaga goto_definition<CR>', opts)
bind('n', 'gP', '<cmd>Lspsaga peek_definition<CR>', opts)
bind('n', 'gk', '<cmd>Lspsaga diagnostic_jump_prev<CR>', opts)
bind('n', 'gj', '<cmd>Lspsaga diagnostic_jump_next<CR>', opts)
bind(
    'n',
    'gK',
    '<cmd>lua require("lspsaga.diagnostic").goto_prev({ severity = vim.diagnostic.severity.ERROR })<CR>',
    opts
)
bind(
    'n',
    'gJ',
    '<cmd>lua require("lspsaga.diagnostic").goto_next({ severity = vim.diagnostic.severity.ERROR })<CR>',
    opts
)

-- Outline
bind('n', '<leader>ol', '<cmd>Lspsaga outline<CR>', opts)

-- Diagnostics Display
bind('n', '<leader>sl', '<cmd>Lspsaga show_line_diagnostics<CR>', opts)
bind('n', '<leader>sc', '<cmd>Lspsaga show_cursor_diagnostics<CR>', opts)
bind('n', '<leader>sb', '<cmd>Lspsaga show_buf_diagnostics<CR>', opts)

-- Call Hierarchy
bind('n', '<Leader>co', '<cmd>Lspsaga outgoing_calls<CR>', opts)
bind('n', '<Leader>ci', '<cmd>Lspsaga incoming_calls<CR>', opts)

-- ==========================
-- Basic Keymaps
-- ==========================
-- Undo and Redo
bind('n', 'u', '<CMD>undo<CR>', opts) -- Undo
bind('n', '<C-r>', '<CMD>redo<CR>', opts) -- Redo

-- Command-line Shortcuts
bind('c', 'W', 'w', opts) -- Save
bind('c', 'WQ', 'wq', opts) -- Save and quit
bind('c', 'Wq', 'wq', opts)
bind('c', 'QA', 'qa', opts) -- Quit all

-- Clipboard Management
bind('n', 'd', [["_d]], opts) -- Delete without copying
bind('v', 'd', [["_d]], opts) -- delete without saving
bind('n', 'c', [["_c]], opts) -- Change without copying
bind('v', 'c', [["_c]], opts)

-- Navigation Enhancements
bind('n', '<C-o>', '<C-o>zz', opts) -- Jump back
bind('n', '<C-i>', '<C-i>zz', opts) -- Jump forward
bind('n', 'H', 'g^', opts) -- Start of line
bind('n', 'L', 'g_', opts) -- End of line
bind('v', 'H', 'g^', opts)
bind('v', 'L', 'g_', opts)

-- Buffer Management
bind('n', '<leader>ll', '<CMD>bp<CR>', opts) -- Previous buffer
bind('n', '<leader>hh', '<CMD>bn<CR>', opts) -- Next buffer
bind('n', '<leader>bd', '<CMD>bdelete<CR>', opts) -- Delete buffer
bind('n', '<leader>ba', '<CMD>bufdo bd<CR>', opts) -- Delete all buffers

-- Resize splits
bind('n', '<S-Up>', '<cmd>resize +2<CR>', opts) -- Increase height
bind('n', '<S-Down>', '<cmd>resize -2<CR>', opts) -- Decrease height
bind('n', '<S-Right>', '<cmd>vertical resize +5<CR>', opts) -- Increase width
bind('n', '<S-Left>', '<cmd>vertical resize -5<CR>', opts) -- Decrease width

-- Window Management
bind('n', '<C-h>', '<C-w>h', opts) -- Move left
bind('n', '<C-j>', '<C-w>j', opts) -- Move down
bind('n', '<C-k>', '<C-w>k', opts) -- Move up
bind('n', '<C-l>', '<C-w>l', opts) -- Move right

-- Select all text
bind('n', '<C-a>', 'ggVG', opts)
bind('n', '<C-Space>', 'ggVGy', opts)

-- Adjust indent in visual mode and reselect
bind('v', '<tab>', '<S->>gv', opts) -- Shift-right and reselect
bind('v', '<S-tab>', '<S-<>gv', opts) -- Shift-left and reselect

-- Move cursor line to top of screen (like `zt`) with `z<space>`
bind('n', 'z<space>', 'zt', opts)

-- Toggle spell check with <leader>st
bind('n', '<leader>st', function()
    vim.opt.spell = not vim.opt.spell -- Toggle spell check
end, vim.tbl_extend('force', opts, { desc = 'Toggle spell check' }))

-- ==========================
-- Plugin-Specific Keymaps
-- ==========================
-- Harpoon
bind('n', '<leader>hx', function()
    require('harpoon.mark').add_file()
end, opts)
bind('n', '<leader>hn', function()
    require('harpoon.ui').nav_next()
end, opts)
bind('n', '<leader>hp', function()
    require('harpoon.ui').nav_prev()
end, opts)
bind('n', '<leader>hm', function()
    require('harpoon.ui').toggle_quick_menu()
end, opts)

-- NvimTree
bind('n', '<leader>nt', '<CMD>NvimTreeToggle<CR>', opts) -- Toggle NvimTree
bind('n', '<leader>nf', '<CMD>NvimTreeFindFile<CR>', opts)

-- Telescope Integration
bind('n', '<leader>ht', '<cmd>Telescope harpoon marks<CR>', opts)
bind('n', '<leader>cf', function()
    require('telescope.builtin').current_buffer_fuzzy_find({
        layout_config = { width = 0.8, height = 0.4 },
        sorting_strategy = 'ascending',
        win_options = { number = false, relativenumber = false },
    })
end, opts) -- Search in the current file without line numbers
