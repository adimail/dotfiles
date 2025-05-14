local M = {
    'nvim-tree/nvim-tree.lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    lazy = false,
}

function M.config()
    if vim.g.started_by_firenvim then
        return
    end

    local status_ok, nvim_tree = pcall(require, 'nvim-tree')
    if not status_ok then
        return
    end

    -- always open nvim-tree
    local function open_nvim_tree(data)
        -- buffer is a real file on the disk
        local real_file = vim.fn.filereadable(data.file) == 1

        -- buffer is a [No Name]
        local no_name = data.file == '' and vim.bo[data.buf].buftype == ''

        if not real_file and not no_name then
            return
        end

        -- skip ignored filetypes
        local filetype = vim.bo[data.buf].ft
        local IGNORED_FT = { 'dashboard' }
        if vim.tbl_contains(IGNORED_FT, filetype) then
            return
        end

        -- open the tree but don't focus it
        require('nvim-tree.api').tree.toggle({ focus = false })
    end

    -- open nvimTree by default.
    vim.api.nvim_create_autocmd({ 'VimEnter' }, { callback = open_nvim_tree })

    vim.keymap.set('n', '<M-n>', '<Cmd>NvimTreeToggle<CR>')

    -- Silently open a new tab
    local function open_tab_silent(node)
        local api = require('nvim-tree.api')

        api.node.open.tab(node)
        vim.cmd.tabprev()
    end

    local function duplicate_file_auto()
        local api = require('nvim-tree.api')
        local node = api.tree.get_node_under_cursor()

        if not node or not node.absolute_path then
            print('No file selected to duplicate!')
            return
        end

        local src_path = node.absolute_path
        local src_name = vim.fn.fnamemodify(src_path, ':t') -- Extract filename
        local src_dir = vim.fn.fnamemodify(src_path, ':h') -- Extract directory

        -- Define the new file name
        local new_file_name = src_name:gsub('(%..+)$', '-copy%1')
        if new_file_name == src_name then
            new_file_name = src_name .. '-copy' -- Handle files without extensions
        end
        local dest_path = src_dir .. '/' .. new_file_name

        -- Check if file exists
        if vim.fn.filereadable(dest_path) == 1 then
            print('Error: File "' .. new_file_name .. '" already exists! Aborting.')
            return
        end

        -- Read and write file contents
        local contents = vim.fn.readfile(src_path)
        vim.fn.writefile(contents, dest_path)

        print('File duplicated to: ' .. dest_path)
        api.tree.reload() -- Refresh nvim-tree
    end

    local function duplicate_file_custom()
        local api = require('nvim-tree.api')
        local node = api.tree.get_node_under_cursor()

        if not node or not node.absolute_path then
            print('No file selected to duplicate!')
            return
        end

        local src_path = node.absolute_path
        local src_dir = vim.fn.fnamemodify(src_path, ':h') -- Extract directory

        -- Prompt for new filename
        local new_file_name = vim.fn.input('Enter new file name: ', '', 'file')
        if new_file_name == '' then
            print('Error: No file name provided. Aborting.')
            return
        end

        local dest_path = src_dir .. '/' .. new_file_name

        -- Check if file exists, ask to retry
        while vim.fn.filereadable(dest_path) == 1 do
            print('Error: File "' .. new_file_name .. '" already exists! Try again.')
            new_file_name = vim.fn.input('Enter new file name: ', '', 'file')
            if new_file_name == '' then
                print('Error: No file name provided. Aborting.')
                return
            end
            dest_path = src_dir .. '/' .. new_file_name
        end

        -- Read and write file contents
        local contents = vim.fn.readfile(src_path)
        vim.fn.writefile(contents, dest_path)

        print('File duplicated to: ' .. dest_path)
        api.tree.reload() -- Refresh nvim-tree
    end

    local function reveal_in_explorer()
        local api = require('nvim-tree.api')
        local node = api.tree.get_node_under_cursor()

        if not node or not node.absolute_path then
            print('No file selected to reveal!')
            return
        end

        local path = node.absolute_path

        -- Platform-specific commands
        if vim.fn.has('win32') == 1 then
            -- Windows command to open File Explorer
            vim.fn.system({ 'explorer', '/select,', path })
        elseif vim.fn.has('mac') == 1 then
            -- macOS command to open Finder
            vim.fn.system({ 'open', '-R', path })
        elseif vim.fn.has('unix') == 1 then
            -- Linux command to open the default file manager
            vim.fn.system({ 'xdg-open', vim.fn.fnamemodify(path, ':h') })
        else
            print('Reveal in explorer not supported on this platform!')
        end
    end

    vim.keymap.set('n', 'T', open_tab_silent)
    -- NEW: keymapping Migration (default)
    local function on_attach(bufnr)
        local api = require('nvim-tree.api')

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
        -- END_DEFAULT_ON_ATTACH

        -- Mappings migrated from view.mappings.list
        --
        -- You will need to insert "your code goes here" for any mappings with a custom action_cb
        vim.keymap.set('n', '<cr>', api.node.open.edit, opts('Open'))
        vim.keymap.set('n', 'l', api.node.open.edit, opts('Open'))
        vim.keymap.set('n', '<2-leftmouse>', api.node.open.edit, opts('Open'))
        vim.keymap.set('n', 'v', api.node.open.vertical, opts('Open: Vertical Split'))
        vim.keymap.set('n', 's', api.node.open.horizontal, opts('Open: Horizontal Split'))
        vim.keymap.set('n', 'h', api.node.navigate.parent_close, opts('Close Directory'))
        vim.keymap.set('n', 'P', api.node.navigate.parent_close, opts('Close Directory'))
        vim.keymap.set('n', 'P', function()
            local node = api.tree.get_node_under_cursor()
            print(node.absolute_path)
        end, opts('Print Node Path'))

        vim.keymap.set('n', 'o', api.node.run.system, opts('Run System'))

        -- File management
        vim.keymap.set('n', '<leader>Fa', api.fs.create, opts('Create File/Folder'))
        vim.keymap.set('n', '<leader>Fr', api.fs.rename, opts('Rename File/Folder'))
        vim.keymap.set('n', '<leader>Fs', api.fs.rename_sub, opts('Rename with Substitution'))
        vim.keymap.set('n', '<leader>Fd', api.fs.remove, opts('Delete File/Folder'))
        vim.keymap.set('n', '<leader>Ft', api.fs.trash, opts('Move to Trash'))
        vim.keymap.set('n', '<leader>Fy', api.fs.copy.node, opts('Copy File/Folder'))
        vim.keymap.set('n', '<leader>Fx', api.fs.cut, opts('Cut File/Folder'))
        vim.keymap.set('n', '<leader>Fp', api.fs.paste, opts('Paste File/Folder'))
        vim.keymap.set('n', '<leader>Fc', api.fs.copy.filename, opts('Copy Filename'))
        vim.keymap.set('n', '<leader>Fv', api.fs.copy.relative_path, opts('Copy Relative Path'))
        vim.keymap.set('n', '<leader>Fb', api.fs.copy.absolute_path, opts('Copy Absolute Path'))
        vim.keymap.set('n', '<leader>Fe', reveal_in_explorer, { desc = 'Reveal in Explorer' })
        vim.keymap.set('n', '<leader>FDd', duplicate_file_auto, opts('Duplicate File'))
        vim.keymap.set(
            'n',
            '<leader>FDa',
            duplicate_file_custom,
            opts('Duplicate File with Custom Name')
        )
    end

    -- END: keymapping Migration
    --
    -- change TOML icon
    require('nvim-web-devicons').setup({
        override_by_extension = {
            ['toml'] = {
                icon = '',
                color = '#708085',
                name = 'Log',
            },
            ['jinja2'] = {
                icon = '',
                color = '#E34F26',
                name = 'HTML',
            },
        },
    })
    --
    -- setup with all defaults
    -- each of these are documented in `:help nvim-tree.OPTION_NAME`
    nvim_tree.setup({ -- BEGIN_DEFAULT_OPTS
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
            float = {
                enable = false,
                quit_on_focus_loss = true,
                open_win_config = {
                    relative = 'editor',
                    border = 'rounded',
                    width = 30,
                    height = 30,
                    row = 1,
                    col = 1,
                },
            },
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
        -- hijack_directories = { enable = true, auto_open = true },
        update_focused_file = {
            enable = true,
            debounce_delay = 15,
            update_root = true,
            ignore_list = { 'toggleterm', 'term' },
        },
        system_open = { cmd = '', args = {} },
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
            custom = { '^\\.git$' }, -- Only hide the `.git` folder
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
            file_popup = {
                open_win_config = {
                    col = 1,
                    row = 1,
                    relative = 'cursor',
                    border = 'shadow',
                    style = 'minimal',
                },
            },
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
        log = {
            enable = false,
            truncate = false,
            types = {
                all = false,
                config = false,
                copy_paste = false,
                dev = false,
                diagnostics = true,
                git = false,
                profile = false,
                watcher = false,
            },
        },
    }) -- END_DEFAULT_OPTS
end

return M
