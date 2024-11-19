---@diagnostic disable: missing-fields
-- Main module table for nvim-cmp configuration
local M = {
    'hrsh7th/nvim-cmp', -- Autocompletion plugin
    event = 'InsertEnter', -- Lazy load on entering insert mode
    -- lazy = false, -- Uncomment if you want to disable lazy loading
    dependencies = {
        -- Sources for nvim-cmp
        'hrsh7th/cmp-nvim-lsp', -- LSP completion source
        'hrsh7th/cmp-buffer', -- Buffer words completion
        -- 'hrsh7th/cmp-emoji', -- Uncomment to enable emoji completion
        'hrsh7th/cmp-path', -- File path completion
        'hrsh7th/cmp-nvim-lsp-signature-help', -- Function signature completion
        'saadparwaiz1/cmp_luasnip', -- LuaSnip snippets completion
        'octaltree/cmp-look', -- Dictionary completion
        'tzachar/cmp-tabnine', -- TabNine AI-powered completion
        'hrsh7th/cmp-cmdline', -- Command-line completion
        {
            'Exafunction/codeium.nvim', -- Optional AI-based completion
            enabled = false, -- Disabled by default
            cmd = 'Codeium', -- Command for using Codeium
            build = ':Codeium Auth', -- Build step for Codeium
            opts = {}, -- Additional options for Codeium
        },
    },
}

-- Configuration function for nvim-cmp
function M.config()
    -- Safe require for cmp
    local cmp_status_ok, cmp = pcall(require, 'cmp')
    if not cmp_status_ok then
        return
    end

    -- Import LuaSnip for snippet functionality
    local luasnip = require('luasnip')

    -- Helper function to check if there are words before the cursor
    local has_words_before = function()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0
            and not vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s')
    end

    -- Use custom snippets loader (optional)
    -- Uncomment the following line to use your custom snippets instead of VSCode-style snippets
    -- require('luasnip.loaders.from_vscode').lazy_load({ paths = '~/.config/nvim/my_snippets' })

    -- Setup for nvim-cmp
    cmp.setup({
        -- Enable/disable completion in specific contexts
        enabled = function()
            local context = require('cmp.config.context')
            -- Disable completion in comments
            return not (
                context.in_treesitter_capture('comment') or context.in_syntax_group('Comment')
            )
        end,

        -- Window appearance for completion and documentation popups
        window = {
            completion = cmp.config.window.bordered(), -- Bordered window for completions
            documentation = cmp.config.window.bordered(), -- Bordered window for documentation
        },

        -- Experimental features
        experimental = {
            ghost_text = false, -- Disable ghost text (may conflict with other features)
            git = {
                async = true, -- Enable asynchronous Git completion
            },
        },

        -- Preselection behavior
        preselect = cmp.PreselectMode.Item, -- Preselect the first item

        -- Completion behavior
        completion = {
            completeopt = 'menu,menuone,noinsert', -- Customize Vim's completeopt settings
        },

        -- Performance tuning
        performance = {
            debounce = 0, -- Disable input debouncing for faster updates
            throttle = 0, -- Disable input throttling
        },

        -- Matching rules for completion
        matching = {
            disallow_fuzzy_matching = true, -- Disable broad fuzzy matching
            disallow_fullfuzzy_matching = true, -- Avoid full fuzzy matching
            disallow_partial_fuzzy_matching = false, -- Allow partial fuzzy matches
            disallow_partial_matching = false, -- Allow partial prefix matches
            disallow_prefix_unmatching = true, -- Disallow items that don't match the prefix
        },

        -- Sorting rules for completion items
        sorting = {
            priority_weight = 1.0, -- Adjust sorting weights
            comparators = {
                cmp.config.compare.locality, -- Prefer items close to the cursor
                cmp.config.compare.recently_used, -- Prefer recently used items
                cmp.config.compare.score, -- Score-based sorting
                cmp.config.compare.offset, -- Sort by offset
                cmp.config.compare.order, -- Preserve item order
            },
        },

        -- Formatting for completion items
        formatting = {
            fields = { 'kind', 'abbr', 'menu' }, -- Display kind, abbreviation, and menu
            format = function(entry, vim_item)
                local lspkind_icons = {
                    Text = '',
                    Method = '',
                    Function = '󰊕',
                    Constructor = '󰡱',
                    Field = '',
                    Variable = '',
                    Class = '',
                    Interface = '',
                    Module = '',
                    Property = '',
                    Unit = '',
                    Value = '',
                    Enum = '',
                    Keyword = '',
                    Snippet = '',
                    Color = '',
                    File = '',
                    Reference = '',
                    Folder = '',
                    EnumMember = '',
                    Constant = '',
                    Struct = '',
                    Event = '',
                    Operator = '',
                    TypeParameter = '',
                    Robot = '󱚤',
                    Smiley = '',
                    Note = '',
                }

                -- Customize icons for specific sources
                if entry.source.name == 'cmp_tabnine' then
                    vim_item.kind = lspkind_icons['Robot']
                elseif entry.source.name == 'look' then
                    vim_item.kind = lspkind_icons['Note']
                end

                vim_item.menu = ({
                    buffer = '[Buffer]', -- For buffer completions
                    nvim_lsp = vim_item.kind, -- Use kind icons for LSP
                    path = '[Path]', -- For path completions
                    luasnip = '[LuaSnip]', -- For snippets
                    cmp_tabnine = '[TN]', -- TabNine source
                    -- emoji = '[Emoji]', -- Uncomment if using emoji
                    look = '[Dict]', -- Dictionary completions
                })[entry.source.name] or ''

                return vim_item
            end,
        },

        -- Key mappings for completion
        mapping = cmp.mapping.preset.insert({
            ['<C-e>'] = cmp.mapping.abort(),
            ['<CR>'] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = true }),
            ['<Tab>'] = cmp.mapping(function(fallback)
                if cmp.visible() then
                    cmp.select_next_item()
                elseif luasnip.expand_or_jumpable() then
                    luasnip.expand_or_jump()
                elseif has_words_before() then
                    cmp.complete()
                else
                    fallback()
                end
            end, { 'i', 's' }),
            ['<S-Tab>'] = cmp.mapping(function(fallback)
                if cmp.visible() then
                    cmp.select_prev_item()
                elseif luasnip.jumpable(-1) then
                    luasnip.jump(-1)
                else
                    fallback()
                end
            end, { 'i', 's' }),
        }),

        -- Snippet engine setup
        snippet = {
            expand = function(args)
                luasnip.lsp_expand(args.body)
            end,
        },

        -- Configure sources
        sources = {
            { name = 'nvim_lsp', priority = 50 }, -- LSP source
            { name = 'cmp_tabnine', priority = 90 }, -- TabNine AI completions
            { name = 'luasnip', priority = 100 }, -- Snippets source
            { name = 'path', priority = 99 }, -- Path completions
            { name = 'buffer', priority = 50, max_item_count = 5 }, -- Buffer words
            -- { name = 'emoji', priority = 50 }, -- Uncomment if using emoji
            { name = 'nvim_lsp_signature_help', priority = 50 }, -- Signature help
            {
                name = 'look',
                keyword_length = 5,
                max_item_count = 5,
                option = {
                    convert_case = true, -- Enable case conversion
                    loud = true, -- Allow noisy matches
                    -- dict = '/usr/share/dict/words', -- Uncomment to specify dictionary path
                },
            },
        },
    })

    -- Additional filetype-specific configurations
    cmp.setup.filetype('TelescopePrompt', { sources = {} })
    cmp.setup.filetype({ 'vim', 'markdown' }, {
        sources = {
            {
                name = 'look',
                keyword_length = 5,
                max_item_count = 5,
                option = {
                    convert_case = true,
                    loud = true,
                },
            },
        },
    })

    -- Command-line completion
    cmp.setup.cmdline(':', {
        sources = { { name = 'cmdline', max_item_count = 10 } },
    })
    cmp.setup.cmdline('/', {
        sources = { { name = 'buffer' } },
    })
end

return M
