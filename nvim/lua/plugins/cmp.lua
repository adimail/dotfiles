local M = {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-path',
        'saadparwaiz1/cmp_luasnip',
    },
}

function M.config()
    local cmp_status_ok, cmp = pcall(require, 'cmp')
    if not cmp_status_ok then
        return
    end

    local luasnip = require('luasnip')

    local has_words_before = function()
        local cursor = vim.api.nvim_win_get_cursor(0)
        local line, col = cursor[1], cursor[2]
        return col ~= 0
            and not vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s')
    end

    cmp.setup({
        enabled = function()
            local context = require('cmp.config.context')
            return not (
                context.in_treesitter_capture('comment') or context.in_syntax_group('Comment')
            )
        end,

        window = {
            completion = cmp.config.window.bordered(),
            documentation = cmp.config.window.bordered(),
        },

        experimental = {
            ghost_text = false,
            git = {
                async = true,
            },
        },

        preselect = cmp.PreselectMode.Item,

        completion = {
            completeopt = 'menu,menuone,noinsert',
        },

        matching = {
            disallow_fuzzy_matching = true,
            disallow_fullfuzzy_matching = true,
            disallow_partial_fuzzy_matching = false,
            disallow_partial_matching = false,
            disallow_prefix_unmatching = true,
        },

        sorting = {
            priority_weight = 1.0,
            comparators = {
                cmp.config.compare.locality,
                cmp.config.compare.recently_used,
                cmp.config.compare.score,
                cmp.config.compare.offset,
                cmp.config.compare.order,
            },
        },

        formatting = {
            fields = { 'kind', 'abbr', 'menu' },
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

                if lspkind_icons[vim_item.kind] then
                    vim_item.kind =
                        string.format('%s %s', lspkind_icons[vim_item.kind], vim_item.kind)
                end

                vim_item.menu = ({
                    buffer = '[Buffer]',
                    nvim_lsp = vim_item.kind,
                    path = '[Path]',
                    luasnip = '[LuaSnip]',
                })[entry.source.name] or ''

                return vim_item
            end,
        },

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

        snippet = {
            expand = function(args)
                luasnip.lsp_expand(args.body)
            end,
        },

        sources = cmp.config.sources({
            { name = 'nvim_lsp', priority = 50 },
            { name = 'luasnip', priority = 100 },
            { name = 'path', priority = 99 },
            { name = 'buffer', priority = 50, keyword_length = 2, max_item_count = 5 },
        }),
    })

    cmp.setup.filetype({ 'handlebars', 'hbs' }, {
        sources = cmp.config.sources({
            { name = 'nvim_lsp' },
            { name = 'buffer', keyword_length = 2, max_item_count = 5 },
            { name = 'path' },
        }),
    })

    cmp.setup.filetype('TelescopePrompt', { sources = {} })

    cmp.setup.filetype({ 'vim', 'markdown' }, {
        sources = cmp.config.sources({
            { name = 'luasnip', priority = 100 },
            { name = 'buffer', priority = 50, keyword_length = 2, max_item_count = 5 },
            { name = 'path', priority = 99 },
            { name = 'nvim_lsp', priority = 50 },
        }),
    })
end

return M
