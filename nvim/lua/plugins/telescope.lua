return {
    'nvim-telescope/telescope.nvim',
    event = 'VeryLazy',
    dependencies = {
        {
            'nvim-telescope/telescope-fzf-native.nvim',
            build = function(plugin)
                local obj = vim.system(
                    { 'cmake', '-S.', '-Bbuild', '-DCMAKE_BUILD_TYPE=Release' },
                    { cwd = plugin.dir }
                ):wait()
                if obj.code ~= 0 then
                    error(obj.stderr)
                end
                obj = vim.system(
                    { 'cmake', '--build', 'build', '--config', 'Release' },
                    { cwd = plugin.dir }
                )
                    :wait()
                if obj.code ~= 0 then
                    error(obj.stderr)
                end
                obj = vim.system(
                    { 'cmake', '--install', 'build', '--prefix', 'build' },
                    { cwd = plugin.dir }
                )
                    :wait()
                if obj.code ~= 0 then
                    error(obj.stderr)
                end
            end,
        },
        {
            'nvim-telescope/telescope-dap.nvim',
        },
        {
            'folke/which-key.nvim',
            config = function()
                require('which-key').setup({})
            end,
        },
    },
    keys = {
        {
            '<leader>ff',
            function()
                require('telescope.builtin').find_files({
                    -- cwd = require("lazy.core.config").options.root
                })
            end,
            desc = 'Find Files',
        },
        {
            '<leader>fg',
            function()
                require('telescope.builtin').live_grep({
                    theme = 'dropdown',
                    -- cwd = require("lazy.core.config").options.root
                })
            end,
            desc = 'Live grep file content',
        },
        {
            '<leader>ob',
            function()
                require('telescope.builtin').buffers()
            end,
            desc = 'Search opened buffers',
        },
        {
            '<leader>O',
            function()
                require('telescope.builtin').buffers()
            end,
            desc = 'Search opened buffers',
        },
        {
            '<leader>fh',
            function()
                require('telescope.builtin').help_tags()
            end,
            desc = 'Search help manual page',
        },
        {
            '<leader>td',
            function()
                vim.cmd('TodoTelescope')
            end,
            desc = 'Toggle Todo Telescope',
        },
        {
            '<leader>jl',
            function()
                require('telescope.builtin').jumplist()
            end,
            desc = 'Toggle Telescope jumplist',
        },
        {
            '<leader>fw',
            function()
                require('telescope.builtin').grep_string()
            end,
            desc = 'Grep strings below the cursor',
        },
        {
            '<leader>gd',
            function()
                local success, _ = pcall(function()
                    require('telescope.builtin').lsp_definitions({
                        quiet = true, -- Suppress output unless results are found
                    })
                end)
                if not success then
                    vim.notify('No definition found for this function/type', vim.log.levels.ERROR)
                end
            end,
            desc = 'Go to definition of the function/type under the cursor',
        },
        {
            '<leader>va',
            function()
                -- This should now work without needing to load which_key extension
                require('which-key').show()
            end,
            desc = 'View all keybindings',
        },
    },
    config = function()
        local telescope = require('telescope')
        local actions = require('telescope.actions')
        local trouble = require('trouble.sources.telescope')

        telescope.setup({
            defaults = {
                hidden = true,
                layout_strategy = 'horizontal',
                layout_config = {
                    horizontal = {
                        prompt_position = 'bottom',
                        preview_width = 0.55,
                        results_width = 0.8,
                    },
                    vertical = { mirror = false },
                    width = 0.87,
                    height = 0.80,
                    preview_cutoff = 120,
                },
                sorting_strategy = 'ascending',
                prompt_prefix = '> ',
                selection_caret = ' ',
                winblend = 0,
                file_ignore_patterns = {
                    'vendor/*',
                    '%.lock',
                    '__pycache__/*',
                    '%.sqlite3',
                    '%.ipynb',
                    'node_modules/*',
                    '%.jpg',
                    '%.jpeg',
                    '%.png',
                    '%.svg',
                    '%.otf',
                    '%.ttf',
                    '^\\.git$',
                    '%.webp',
                    '.dart_tool/',
                    '.gradle/',
                    '.idea/',
                    '.settings/',
                    '.vscode/',
                    '__pycache__/',
                    'build/',
                    'env/',
                    'gradle/',
                    'node_modules/',
                    'target/',
                    '%.pdb',
                    '%.dll',
                    '%.class',
                    '%.exe',
                    '%.cache',
                    '%.ico',
                    '%.pdf',
                    '%.dylib',
                    '%.jar',
                    '%.docx',
                    '%.met',
                    'smalljre_*/*',
                    '.vale/',
                    '%.burp',
                    '%.mp4',
                    '%.mkv',
                    '%.rar',
                    '%.zip',
                    '%.7z',
                    '%.tar',
                    '%.bz2',
                    '%.epub',
                    '%.flac',
                    '%.tar.gz',
                },
                mappings = {
                    i = {
                        ['<C-n>'] = actions.cycle_history_next,
                        ['<C-p>'] = actions.cycle_history_prev,

                        ['<C-j>'] = actions.move_selection_next,
                        ['<C-k>'] = actions.move_selection_previous,

                        ['<C-c>'] = actions.close,
                        --
                        ['<Down>'] = actions.move_selection_next,
                        ['<Up>'] = actions.move_selection_previous,

                        ['<CR>'] = actions.select_default,
                        ['<C-s>'] = actions.select_horizontal,
                        ['<C-v>'] = actions.select_vertical,
                        ['<C-t>'] = actions.select_tab,

                        ['<C-u>'] = actions.preview_scrolling_up,
                        ['<C-d>'] = actions.preview_scrolling_down,

                        ['<PageUp>'] = actions.results_scrolling_up,
                        ['<PageDown>'] = actions.results_scrolling_down,

                        ['<Tab>'] = actions.toggle_selection + actions.move_selection_worse,
                        ['<S-Tab>'] = actions.toggle_selection + actions.move_selection_better,
                        ['<C-q>'] = actions.send_to_qflist + actions.open_qflist,
                        ['<M-q>'] = actions.send_selected_to_qflist + actions.open_qflist,
                        ['<C-l>'] = actions.complete_tag,
                        ['<C-_>'] = actions.which_key, -- keys from pressing <C-/>
                        ['<c-t>'] = trouble.open,
                    },

                    n = {
                        ['<esc>'] = actions.close,
                        ['<CR>'] = actions.select_default,
                        ['<C-s>'] = actions.select_horizontal,
                        ['<C-v>'] = actions.select_vertical,
                        ['<C-t>'] = actions.select_tab,

                        ['<Tab>'] = actions.toggle_selection + actions.move_selection_worse,
                        ['<S-Tab>'] = actions.toggle_selection + actions.move_selection_better,
                        ['<C-q>'] = actions.send_to_qflist + actions.open_qflist,
                        ['<M-q>'] = actions.send_selected_to_qflist + actions.open_qflist,

                        ['j'] = actions.move_selection_next,
                        ['k'] = actions.move_selection_previous,
                        ['H'] = actions.move_to_top,
                        ['M'] = actions.move_to_middle,
                        ['L'] = actions.move_to_bottom,

                        ['<Down>'] = actions.move_selection_next,
                        ['<Up>'] = actions.move_selection_previous,
                        ['gg'] = actions.move_to_top,
                        ['G'] = actions.move_to_bottom,

                        ['<C-u>'] = actions.preview_scrolling_up,
                        ['<C-d>'] = actions.preview_scrolling_down,

                        ['<PageUp>'] = actions.results_scrolling_up,
                        ['<PageDown>'] = actions.results_scrolling_down,

                        ['?'] = actions.which_key,
                    },
                },
            },
            extensions = {
                fzf = {
                    fuzzy = true, -- false will only do exact matching
                    override_generic_sorter = true, -- override the generic sorter
                    override_file_sorter = true, -- override the file sorter
                    case_mode = 'smart_case', -- or "ignore_case" or "respect_case"
                    -- the default case_mode is "smart_case"
                },
            },
        })
        telescope.load_extension('fzf')
        -- telescope.load_extension('dap')  -- Uncomment if you want to enable DAP extension
        -- telescope.load_extension('bookmarks')  -- Uncomment if you want to enable bookmarks extension
    end,
}
