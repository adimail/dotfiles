local opt = vim.opt

opt.inccommand = 'nosplit'
opt.completeopt = 'menu,menuone,noselect'
opt.hlsearch = true
opt.incsearch = true
opt.number = true
opt.hidden = true
opt.breakindent = true
opt.showbreak = '⤿ '
opt.clipboard = 'unnamed'
opt.swapfile = false
opt.ignorecase = true
opt.smartcase = true
opt.updatetime = 200
vim.wo.signcolumn = 'yes'
opt.lazyredraw = true
opt.redrawtime = 100
opt.termguicolors = true
opt.shortmess:append('ISc')
opt.whichwrap:append('<>hl')
opt.autoindent = true
opt.smartindent = true
opt.history = 10000
opt.wildmenu = true
opt.wrap = true
opt.linebreak = true
opt.cursorline = true
opt.autoread = true
opt.autowrite = true
opt.backup = true
opt.writebackup = false
opt.ruler = true
opt.showmatch = true
opt.showmode = false
opt.relativenumber = true
opt.pumheight = 15
opt.cmdheight = 1
opt.scrolloff = 5
opt.sidescrolloff = 5
opt.wildignorecase = true
opt.ttimeout = true
opt.ttimeoutlen = 5
opt.timeout = true
opt.timeoutlen = 300
opt.showcmd = false
opt.tabstop = 4
opt.shiftwidth = 4
opt.foldenable = true
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
opt.grepprg = 'rg --vimgrep --no-heading'
opt.grepformat = '%f:%l:%c:%m,%f:%l:%m'
opt.joinspaces = false

opt.directory = vim.fn.stdpath('state') .. '/swap'
opt.backupdir = vim.fn.stdpath('state') .. '/backup'
opt.undodir = vim.fn.stdpath('state') .. '/undo'

if vim.fn.executable('python3') == 1 then
    vim.g.python3_host_prog = vim.fn.exepath('python3')
end

vim.g.loaded_python_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrw = 1

vim.g.gruvbox_material_transparent_background = 1
vim.g.gruvbox_material_sign_column_background = 'none'
