local spec = {
    'onsails/lspkind.nvim',
    event = 'LspAttach', -- Load when LSP attaches to a buffer
    dependencies = {
        'hrsh7th/nvim-cmp', -- Required for integration with nvim-cmp
    },
}

function spec.config()
    require('lspkind').init({
        mode = 'symbol_text', -- Show both symbol and text
        preset = 'default', -- Default preset icons
        symbol_map = {
            Text = '',
            Method = '',
            Function = '',
            Constructor = '',
            Field = '',
            Variable = '',
            Class = 'ﴯ',
            Interface = '',
            Module = '',
            Property = 'ﰠ',
            Unit = '',
            Value = '',
            Enum = '',
            Keyword = '',
            Snippet = '',
            Color = '',
            File = '',
            Reference = '',
            Folder = '',
            EnumMember = '',
            Constant = '',
            Struct = '',
            Event = '',
            Operator = '',
            TypeParameter = '',
        },
    })
end

return spec
