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
}

function M.config()
    local conform = require('conform')

    conform.setup({
        format_after_save = {
            lsp_fallback = true,
        },
        log_level = vim.log.levels.ERROR,
        notify_on_error = true,
        formatters_by_ft = {
            lua = { 'stylua' },
            rust = { 'rustfmt' },
            ocaml = { 'ocamlformat' },
            cpp = { 'clang-format' },
            go = { 'goimports', 'gofumpt' },
            java = { 'google-java-format' },
            javascript = { 'prettierd', 'prettier', stop_after_first = true },
            typescript = { 'prettierd', 'prettier', stop_after_first = true },
            javascriptreact = { 'prettierd', 'prettier', stop_after_first = true },
            typescriptreact = { 'prettierd', 'prettier', stop_after_first = true },
            json = { 'jq' },
            markdown = { 'prettierd', 'prettier', stop_after_first = true },
            html = { 'prettierd', 'prettier', stop_after_first = true },
            htmldjango = { 'djlint' },
            css = { 'prettierd', 'prettier', stop_after_first = true },
            scss = { 'prettierd', 'prettier', stop_after_first = true },
            python = function(bufnr)
                local formatter_info = conform.get_formatter_info('ruff_format', bufnr)
                if formatter_info.available then
                    return { 'ruff_format' }
                else
                    return { 'isort', 'black' }
                end
            end,
            ['_'] = { 'trim_whitespace' },
            sh = { 'shfmt' },
        },
    })
end

return M
