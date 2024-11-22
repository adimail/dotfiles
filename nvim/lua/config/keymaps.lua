-- ==========================
-- General Settings
-- ==========================
vim.o.timeoutlen = 300 -- Set the timeout length for mapped sequences in milliseconds

-- Keymap utility
local bind = vim.keymap.set
local opts = { noremap = true, silent = true }

-- ==========================
-- LSP Keymaps
-- ==========================
-- Core LSP mappings
bind('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
bind('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
bind('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
bind('n', '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
bind('n', '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
bind(
    'n',
    '<leader>wl',
    '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>',
    opts
)
bind('n', '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)

-- Diagnostics mappings
bind('n', '<leader>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
bind('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
bind('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
bind('n', '<leader>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)

-- Telescope diagnostics
bind('n', '<leader>so', '<cmd>lua require("telescope.builtin").lsp_document_symbols()<CR>', opts)
bind('n', '<leader>sd', '<cmd>Telescope diagnostics<CR>', opts)

-- Project-wide diagnostics
bind('n', '<leader>ld', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)
bind('n', '<leader>qd', '<cmd>lua vim.diagnostic.setqflist()<CR>', opts)

-- Goto-preview plugin mappings
bind('n', 'gp', '<cmd>lua require("goto-preview").goto_preview_definition()<CR>', opts)
bind('n', 'gpi', '<cmd>lua require("goto-preview").goto_preview_implementation()<CR>', opts)
bind('n', 'gpt', '<cmd>lua require("goto-preview").goto_preview_type_definition()<CR>', opts)
bind('n', 'gF', '<cmd>lua require("goto-preview").goto_preview_references()<CR>', opts)
bind('n', 'gq', '<cmd>lua require("goto-preview").close_all_win()<CR>', opts)

-- Formatting
vim.cmd([[ command! Format execute 'lua vim.lsp.buf.format({ async = true })' ]])

-- ==========================
-- LSP Saga Keymaps
-- ==========================
-- Hover documentation
bind('n', 'K', '<cmd>Lspsaga hover_doc<CR>', opts)

-- LSP Finder
bind('n', 'gf', '<cmd>Lspsaga finder<CR>', opts)
bind('n', '<leader>gf', '<cmd>Lspsaga finder imp<CR>', opts)

-- Code Action
bind('n', 'gx', '<cmd>Lspsaga code_action<CR>', opts)

-- Rename
bind('n', 'gr', '<cmd>Lspsaga rename<CR>', opts)

-- Go to Definition
bind('n', 'gd', '<cmd>Lspsaga goto_definition<CR>', opts)

-- Peek Definition
bind('n', 'gP', '<cmd>Lspsaga peek_definition<CR>', opts)

-- Diagnostic Navigation
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

-- Show Diagnostics
bind('n', '<leader>sl', '<cmd>Lspsaga show_line_diagnostics<CR>', opts)
bind('n', '<leader>sc', '<cmd>Lspsaga show_cursor_diagnostics<CR>', opts)
bind('n', '<leader>sb', '<cmd>Lspsaga show_buf_diagnostics<CR>', opts)

-- Code Action (Leader)
bind('n', '<leader>ca', '<cmd>Lspsaga code_action<CR>', opts)

-- Call Hierarchy
bind('n', '<Leader>co', '<cmd>Lspsaga outgoing_calls<CR>', opts)
bind('n', '<Leader>ci', '<cmd>Lspsaga incoming_calls<CR>', opts)

-- ==========================
-- Basic Keymaps
-- ==========================
-- Undo and redo actions
bind('n', 'u', '<CMD>undo<CR>', opts) -- Undo
bind('n', '<C-r>', '<CMD>redo<CR>', opts) -- Redo

-- Command-line convenience shortcuts
bind('c', 'W', 'w', opts) -- `W` for save
bind('c', 'WQ', 'wq', opts) -- `WQ` for save and quit
bind('c', 'Wq', 'wq', opts) -- `Wq` for save and quit
bind('c', 'QA', 'qa', opts) -- `QA` for quit all

-- Prevent copy to clipboard for delete/change commands
bind('n', 'd', [["_d]], opts) -- Delete without copying to clipboard
bind('v', 'd', [["_d]], opts)
bind('n', 'c', [["_c]], opts) -- Change without copying to clipboard
bind('v', 'c', [["_c]], opts)

-- Center the cursor after jumping back and forward
bind('n', '<C-o>', '<C-o>zz', opts) -- Jump back
bind('n', '<C-i>', '<C-i>zz', opts) -- Jump forward

-- Improved navigation in lines
bind('n', 'H', 'g^', opts) -- Jump to the start of the first non-blank character
bind('n', 'L', 'g_', opts) -- Jump to the end of the last non-blank character
bind('v', 'H', 'g^', opts)
bind('v', 'L', 'g_', opts)

-- Move by visual lines instead of actual lines
bind('n', 'k', 'gk', opts)
bind('n', 'j', 'gj', opts)

-- Adjust indent in visual mode and reselect
bind('v', '<tab>', '<S->>gv', opts) -- Shift-right and reselect
bind('v', '<S-tab>', '<S-<>gv', opts) -- Shift-left and reselect

-- Buffer navigation
bind('n', '<C-left>', '<CMD>bp<CR>', opts) -- Previous buffer
bind('n', '<C-right>', '<CMD>bn<CR>', opts) -- Next buffer
bind('n', '<leader>bd', '<CMD>bdelete<CR>', opts) -- Close the current buffer
bind('n', '<leader>ba', '<CMD>bufdo bd<CR>', opts) -- Close all buffers
bind('n', '<leader>do', '<CMD>:BWipeout other<CR>', opts) -- Delete other buffers

-- Tab management
bind('n', '<C-t>', '<CMD>tabnew<CR>', opts) -- Open a new tab
bind('n', '<ESC>', '<CMD>noh<CR>', opts) -- Clear search highlighting

-- Tab navigation
bind('n', '<leader>0', '<CMD>tablast<CR>', opts) -- Go to the last tab
bind('n', '<leader>dd', ':%bdelete<CR>', opts) -- Close all buffers

-- Copy to system clipboard
bind('n', '<C-c>', '"+y', opts) -- Copy text to the system clipboard

-- Window navigation
bind('n', '<C-h>', '<C-w>h', opts) -- Move to the left window
bind('n', '<C-j>', '<C-w>j', opts) -- Move to the below window
bind('n', '<C-k>', '<C-w>k', opts) -- Move to the above window
bind('n', '<C-l>', '<C-w>l', opts) -- Move to the right window
bind('n', '<C-q>', '<C-w>q', opts) -- Close the current window
bind('n', '<C-\\>', '<C-w><bar>', opts) -- Equalize window size

-- Resize splits
bind('n', '<S-Up>', '<cmd>resize +2<CR>', opts) -- Increase height
bind('n', '<S-Down>', '<cmd>resize -2<CR>', opts) -- Decrease height
bind('n', '<S-Right>', '<cmd>vertical resize +5<CR>', opts) -- Increase width
bind('n', '<S-Left>', '<cmd>vertical resize -5<CR>', opts) -- Decrease width

-- Search with \v enabled
bind('n', '<space>', '/\\v', opts)

-- Exit terminal mode with Escape
bind('t', '<Esc>', '<C-\\><C-n>', opts)

-- Select all text
bind('n', '<C-a>', 'ggVG', opts)

-- Move cursor line to top of screen (like `zt`) with `z<space>`
bind('n', 'z<space>', 'zt', opts)

-- ==========================
-- Plugin Keymaps
-- ==========================
-- LSP Management
bind('n', '<leader>lr', '<CMD>LspRestart<CR>', opts) -- Restart LSP
bind('n', '<leader>ls', '<CMD>LspStop<CR>', opts) -- Stop LSP
bind('n', '<leader>lS', '<CMD>LspStart<CR>', opts) -- Start LSP

-- Git Integration
bind('n', '<leader>go', '<CMD>:!git open<CR><CR>', opts) -- Open the current repo in a browser
bind('n', '<leader>gs', '<CMD>LazyGit<CR>', opts) -- Open LazyGit
bind('n', '<leader>gc', '<CMD>LazyGitConfig<CR>', opts) -- Open LazyGit config view
bind('n', '<leader>gb', '<CMD>LazyGitBranches<CR>', opts) -- Open branch management

-- ToggleTerm
bind('n', '<leader>tf', '<CMD>exe v:count1 . "ToggleTerm"<CR>', opts) -- Open terminal
bind('n', '<leader>tb', '<CMD>ToggleTerm size=12 direction=horizontal<CR>', opts) -- Horizontal terminal
bind('n', '<leader>tt', '<CMD>ToggleTerm direction=tab<CR>', opts) -- Tab terminal

-- NvimTree
bind('n', '<leader>nt', '<CMD>NvimTreeToggle<CR>', opts) -- Toggle NvimTree
bind('n', '<leader>nf', '<CMD>NvimTreeFindFile<CR>', opts) -- Focus on the current file in NvimTree

-- Treesitter Highlight Toggle
bind('n', '<leader>hd', '<CMD>TSDisable highlight<CR>', opts) -- Disable highlight
bind('n', '<leader>he', '<CMD>TSEnable highlight<CR>', opts) -- Enable highlight

-- UndoTree
bind('n', '<leader>oh', ':UndotreeToggle <BAR> :UndotreeFocus<CR>', opts) -- Open UndoTree and focus it

-- Toggle spell check with <leader>st
bind('n', '<leader>st', function()
    vim.opt.spell = not vim.opt.spell -- Toggle spell check
end, vim.tbl_extend('force', opts, { desc = 'Toggle spell check' }))

-- ==========================
-- Harpoon Keymaps
-- ==========================
-- Add the current file to Harpoon
bind('n', '<leader>hx', function()
    require('harpoon.mark').add_file()
end, vim.tbl_extend('force', opts, { desc = 'Harpoon: Mark file' }))

-- Navigate to the next Harpoon mark
bind('n', '<leader>hn', function()
    require('harpoon.ui').nav_next()
end, vim.tbl_extend('force', opts, { desc = 'Harpoon: Navigate next' }))

-- Navigate to the previous Harpoon mark
bind('n', '<leader>hp', function()
    require('harpoon.ui').nav_prev()
end, vim.tbl_extend('force', opts, { desc = 'Harpoon: Navigate previous' }))

-- Open the Harpoon menu
bind('n', '<leader>hm', function()
    require('harpoon.ui').toggle_quick_menu()
end, vim.tbl_extend('force', opts, { desc = 'Harpoon: Open menu' }))

-- Remove a Harpoon mark by index
bind('n', '<leader>hr', function()
    local index = tonumber(vim.fn.input('Enter Harpoon index to remove: '))
    if index then
        require('harpoon.mark').rm_file(index)
        print('Removed Harpoon mark at index: ' .. index)
    else
        print('Invalid index')
    end
end, vim.tbl_extend('force', opts, { desc = 'Harpoon: Remove mark by index' }))

-- Clear all Harpoon marks
bind('n', '<leader>hc', function()
    require('harpoon.mark').clear_all()
    print('Cleared all Harpoon marks!')
end, vim.tbl_extend('force', opts, { desc = 'Harpoon: Clear all marks' }))

-- Telescope integration with Harpoon
bind(
    'n',
    '<leader>ht',
    '<cmd>Telescope harpoon marks<CR>',
    vim.tbl_extend('force', opts, { desc = 'Harpoon: Telescope Marks' })
)

bind(
    'n',
    '<leader>vh',
    '<CMD>vsplit<CR><CMD>BufferLineMoveNext<CR>',
    { noremap = true, silent = true }
)
bind(
    'n',
    '<leader>hh',
    '<CMD>split<CR><CMD>BufferLineMoveNext<CR>',
    { noremap = true, silent = true }
)

-- Window navigation
bind('n', '<C-h>', '<C-w>h', opts) -- Move to the left window
bind('n', '<C-l>', '<C-w>l', opts) -- Move to the right window
bind('n', '<C-j>', '<C-w>j', opts) -- Move to the below window
bind('n', '<C-k>', '<C-w>k', opts) -- Move to the above window
