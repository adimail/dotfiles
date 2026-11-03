local M = {
    'nvim-tree/nvim-tree.lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    lazy = false,
    cmd = { 'NvimTreeToggle', 'NvimTreeOpen', 'NvimTreeFocus', 'NvimTreeFindFile' },
    keys = {
        { '<M-n>', '<Cmd>NvimTreeToggle<CR>', desc = 'Toggle NvimTree' },
        { '<leader>nt', '<Cmd>NvimTreeToggle<CR>', desc = 'Toggle NvimTree' },
    },
}

function M.config()
    if vim.g.started_by_firenvim then
        return
    end

    local status_ok, nvim_tree = pcall(require, 'nvim-tree')
    if not status_ok then
        return
    end

    local function open_tab_silent(node)
        local api = require('nvim-tree.api')
        api.node.open.tab(node)
        vim.cmd.tabprev()
    end

    local function duplicate_file_auto()
        local api = require('nvim-tree.api')
        local node = api.tree.get_node_under_cursor()

        if not node or not node.absolute_path then
            return
        end

        local src_path = node.absolute_path
        local src_name = vim.fn.fnamemodify(src_path, ':t')
        local src_dir = vim.fn.fnamemodify(src_path, ':h')

        local new_file_name = src_name:gsub('(%..+)$', '-copy%1')
        if new_file_name == src_name then
            new_file_name = src_name .. '-copy'
        end
        local dest_path = src_dir .. '/' .. new_file_name

        if vim.fn.filereadable(dest_path) == 1 then
            return
        end

        local contents = vim.fn.readfile(src_path)
        vim.fn.writefile(contents, dest_path)
        api.tree.reload()
    end

    local function duplicate_file_custom()
        local api = require('nvim-tree.api')
        local node = api.tree.get_node_under_cursor()

        if not node or not node.absolute_path then
            return
        end

        local src_path = node.absolute_path
        local src_dir = vim.fn.fnamemodify(src_path, ':h')

        local new_file_name = vim.fn.input('Enter new file name: ', '', 'file')
        if new_file_name == '' then
            return
        end

        local dest_path = src_dir .. '/' .. new_file_name

        while vim.fn.filereadable(dest_path) == 1 do
            new_file_name = vim.fn.input('File exists! Enter new file name: ', '', 'file')
            if new_file_name == '' then
                return
            end
            dest_path = src_dir .. '/' .. new_file_name
        end

        local contents = vim.fn.readfile(src_path)
        vim.fn.writefile(contents, dest_path)
        api.tree.reload()
    end

    local function reveal_in_explorer()
        local api = require('nvim-tree.api')
        local node = api.tree.get_node_under_cursor()

        if not node or not node.absolute_path then
            return
        end

        local path = node.absolute_path

        if vim.fn.has('win32') == 1 then
            vim.fn.system({ 'explorer', '/select,', path })
        elseif vim.fn.has('mac') == 1 then
            vim.fn.system({ 'open', '-R', path })
        elseif vim.fn.has('unix') == 1 then
            vim.fn.system({ 'xdg-open', vim.fn.fnamemodify(path, ':h') })
        end
    end

    local function on_attach(bufnr)
        local api = require('nvim-tree.api')

        vim.opt_local.statusline = '%#Normal# '

        local function opts(desc)
            return {
                desc = 'nvim-tree: ' .. desc,
                buffer = bufnr,
                noremap = true,
                silent = true,
                nowait = true,
            }
        end

        api.config.mappings.default_on_attach(bufnr)

        vim.keymap.set('n', '<CR>', api.node.open.edit, opts('Open'))
        vim.keymap.set('n', 'l', api.node.open.edit, opts('Open'))
        vim.keymap.set('n', '<2-leftmouse>', api.node.open.edit, opts('Open'))
        vim.keymap.set('n', 'v', api.node.open.vertical, opts('Open: Vertical Split'))
        vim.keymap.set('n', 's', api.node.open.horizontal, opts('Open: Horizontal Split'))
        vim.keymap.set('n', 'h', api.node.navigate.parent_close, opts('Close Directory'))
        vim.keymap.set('n', 'P', function()
            local node = api.tree.get_node_under_cursor()
            if node then
                print(node.absolute_path)
            end
        end, opts('Print Node Path'))
        vim.keymap.set('n', 'o', api.node.run.system, opts('Run System'))
        vim.keymap.set('n', 'T', open_tab_silent, opts('Open Tab Silent'))
        vim.keymap.set('n', 'e', reveal_in_explorer, opts('Reveal in Explorer'))
        vim.keymap.set('n', 'D', duplicate_file_auto, opts('Duplicate File'))
        vim.keymap.set('n', 'Y', duplicate_file_custom, opts('Duplicate File with Custom Name'))
    end

    require('nvim-web-devicons').setup({
        override_by_extension = {
            ['toml'] = { icon = '', color = '#708085', name = 'Log' },
            ['jinja2'] = { icon = '', color = '#E34F26', name = 'HTML' },
        },
    })

    nvim_tree.setup({
        auto_reload_on_write = true,
        disable_netrw = false,
        hijack_cursor = false,
        hijack_netrw = true,
        hijack_unnamed_buffer_when_opening = false,
        root_dirs = {},
        prefer_startup_root = true,
        sync_root_with_cwd = true,
        reload_on_bufenter = true,
        respect_buf_cwd = true,
        on_attach = on_attach,
        select_prompts = true,
        sort = {
            sorter = 'name',
            folders_first = true,
            files_first = false,
        },
        view = {
            adaptive_size = true,
            centralize_selection = false,
            cursorline = true,
            width = 30,
            side = 'left',
            preserve_window_proportions = false,
            number = false,
            relativenumber = false,
            signcolumn = 'yes',
        },
        renderer = {
            add_trailing = false,
            group_empty = false,
            highlight_git = false,
            full_name = true,
            highlight_opened_files = 'name',
            highlight_modified = 'none',
            root_folder_label = ':~:s?$?/..?',
            indent_width = 2,
            indent_markers = {
                enable = true,
                inline_arrows = true,
                icons = {
                    corner = '└',
                    edge = '│',
                    item = '│',
                    bottom = '─',
                    none = ' ',
                },
            },
            icons = {
                webdev_colors = true,
                git_placement = 'before',
                modified_placement = 'after',
                padding = ' ',
                symlink_arrow = ' ➛ ',
                show = {
                    file = true,
                    folder = true,
                    folder_arrow = true,
                    git = true,
                    modified = true,
                },
                glyphs = {
                    default = '',
                    symlink = '',
                    bookmark = '',
                    modified = '●',
                    folder = {
                        arrow_closed = '▶',
                        arrow_open = '▼',
                        default = '',
                        open = '',
                        empty = '',
                        empty_open = '',
                        symlink = '',
                        symlink_open = '',
                    },
                    git = {
                        unstaged = '✗',
                        staged = '✓',
                        unmerged = '',
                        renamed = '➜',
                        untracked = '󰜄',
                        deleted = '',
                        ignored = '◌',
                    },
                },
            },
            special_files = {
                'Cargo.toml',
                'Makefile',
                'README.md',
                'readme.md',
                'package.json',
                'package-lock.json',
            },
            symlink_destination = true,
        },
        update_focused_file = {
            enable = true,
            debounce_delay = 100,
            update_root = true,
            ignore_list = { 'toggleterm', 'term' },
        },
        diagnostics = {
            enable = true,
            show_on_dirs = false,
            show_on_open_dirs = true,
            debounce_delay = 50,
            severity = {
                min = vim.diagnostic.severity.HINT,
                max = vim.diagnostic.severity.ERROR,
            },
            icons = { hint = '', info = '', warning = '', error = '' },
        },
        filters = {
            dotfiles = false,
            git_clean = false,
            no_buffer = false,
            custom = { '^\\.git$' },
            exclude = {},
        },
        filesystem_watchers = {
            enable = true,
            debounce_delay = 50,
            ignore_dirs = {},
        },
        git = {
            enable = true,
            ignore = false,
            show_on_dirs = true,
            show_on_open_dirs = true,
            timeout = 400,
        },
        modified = {
            enable = false,
            show_on_dirs = true,
            show_on_open_dirs = true,
        },
        actions = {
            use_system_clipboard = true,
            change_dir = {
                enable = true,
                global = false,
                restrict_above_cwd = false,
            },
            expand_all = { max_folder_discovery = 300, exclude = {} },
            open_file = {
                quit_on_open = false,
                resize_window = true,
                window_picker = {
                    enable = true,
                    picker = 'default',
                    chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890',
                    exclude = {
                        filetype = {
                            'notify',
                            'packer',
                            'qf',
                            'diff',
                            'fugitive',
                            'fugitiveblame',
                        },
                        buftype = { 'nofile', 'terminal', 'help' },
                    },
                },
            },
            remove_file = { close_window = true },
        },
        trash = { cmd = 'trash-put', require_confirm = true },
        live_filter = { prefix = '[FILTER]: ', always_show_folders = true },
        tab = { sync = { open = false, close = false, ignore = {} } },
        notify = { threshold = vim.log.levels.INFO },
    })
end

return M
