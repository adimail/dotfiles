local M = {
    'stevearc/conform.nvim',
    event = 'VeryLazy',
    ft = {
        'lua',
        'go',
        'yaml',
        'javascript',
        'typescript',
        'javascriptreact',
        'typescriptreact',
        'python',
        'json',
        'markdown',
        'html',
        'shfmt',
        'sh',
    },
    -- Uncomment below to bind a key for manual formatting
    -- keys = { { '<leader>ef', '<cmd>ConformFormat<cr>', desc = 'Format current file.' } },
}

function M.config()
    local conform = require('conform')

    conform.setup({
        format_after_save = {
            lsp_fallback = true,
        },

        -- Logging and notifications
        log_level = vim.log.levels.ERROR, -- Log only errors
        notify_on_error = true, -- Show notification if an error occurs during formatting

        -- Define formatters for specific filetypes
        formatters_by_ft = {
            -- Lua files use 'stylua' for formatting
            lua = { 'stylua' },

            -- rust
            rust = { 'rustfmt' },

            -- Ocaml
            ocaml = { 'ocamlformat' },

            -- cpp formatters
            cpp = { 'clang-format' },

            -- Go files run 'goimports' and 'gofumpt' in sequence
            go = { 'goimports', 'gofumpt' },

            -- JavaScript/TypeScript files use 'prettierd', fallback to 'prettier' if unavailable
            javascript = { 'prettierd', 'prettier' },
            typescript = { 'prettierd', 'prettier' },
            javascriptreact = { 'prettierd', 'prettier' },
            typescriptreact = { 'prettierd', 'prettier' },

            -- JSON files use 'jq' for lightweight formatting
            json = { 'jq' },

            -- Markdown files rely on 'prettierd' for consistent formatting
            markdown = { 'prettierd' },

            -- HTML, CSS, and SCSS use 'prettierd' as primary formatter
            html = { 'prettierd', 'prettier' },
            htmldjango = { 'djlint' },

            css = { 'prettierd', 'prettier' },
            scss = { 'prettierd', 'prettier' },

            -- Python files prioritize 'ruff_format' if available; otherwise, use 'isort' and 'black'
            python = function(bufnr)
                local formatter_info = conform.get_formatter_info('ruff_format', bufnr)
                if formatter_info.available then
                    return { 'ruff_format' } -- Use ruff's formatter if available
                else
                    return { 'isort', 'black' } -- Fallback to isort (imports) and black (code)
                end
            end,

            -- Catch-all: Trim trailing whitespace for all files
            ['_'] = { 'trim_whitespace' },

            sh = { 'shfmt' },
        },

        -- Enable parallel formatting (optional for faster execution)
        -- parallel_formatting = true, -- Uncomment if you want to enable parallel formatting
    })
end

return M
