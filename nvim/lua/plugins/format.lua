local M = {
    'stevearc/conform.nvim',
    event = 'VeryLazy',
    ft = { 'lua', 'go', 'yaml', 'javascript', 'python', 'json', 'markdown' },
    -- keys = { { '<leader>ef', '<cmd>GuardFmt<cr>', desc = 'Format current file.' } },
}

function M.config()
    local conform = require('conform')

    -- Setup the conform plugin
    conform.setup({
        -- Automatically format files on save with optional LSP fallback
        format_after_save = {
            lsp_fallback = true, -- Use LSP formatter if no other formatter is found
        },

        -- Error logging configuration
        log_level = vim.log.levels.ERROR, -- Only log errors
        notify_on_error = true, -- Notify the user when an error occurs

        -- Define formatters for specific filetypes
        formatters_by_ft = {
            -- Lua files will use 'stylua'
            lua = { 'stylua' },

            -- Go files will run both 'goimports' and 'gofumpt'
            go = { 'goimports', 'gofumpt' },

            -- JavaScript files will try 'prettierd', then 'prettier' if the first isn't available
            javascript = { 'prettierd', 'prettier' },

            -- Python files use 'ruff_format' if available, otherwise fallback to 'isort' and 'black'
            python = function(bufnr)
                local formatter_info = conform.get_formatter_info('ruff_format', bufnr)
                if formatter_info.available then
                    return { 'ruff_format' }
                else
                    return { 'isort', 'black' }
                end
            end,

            -- JSON files will use 'jq' for formatting
            json = { 'jq' },

            -- Markdown files will use 'prettierd' for formatting
            markdown = { 'prettierd' },

            -- All filetypes will use 'codespell' to check for common spelling mistakes
            ['*'] = { 'codespell' },

            -- Default formatting for unknown filetypes
            ['_'] = { 'trim_whitespace' },
        },

        -- Optional: Parallel formatting
        -- You can configure this if you prefer parallel execution of formatters for improved performance
        -- parallel_formatting = true, -- Enable running formatters in parallel (optional)
    })
end

return M
