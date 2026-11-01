local M = {}

M.setup_ui = function()
    vim.diagnostic.config({
        signs = {
            text = {
                [vim.diagnostic.severity.ERROR] = ' ✗',
                [vim.diagnostic.severity.WARN] = ' ❢',
                [vim.diagnostic.severity.HINT] = ' ',
                [vim.diagnostic.severity.INFO] = ' 𝓲',
            },
        },
        update_in_insert = false,
        underline = true,
        severity_sort = true,
        virtual_text = true,
        float = {
            border = 'rounded',
            focusable = true,
            style = 'minimal',
            source = true,
            header = '',
            prefix = '',
        },
    })

    vim.api.nvim_set_hl(0, 'DiagnosticsBorder', { fg = '#00ff00', bg = '#1E2021' })
    vim.cmd([[
        highlight! link FloatBorder DiagnosticsBorder
        highlight! link NormalFloat DiagnosticsBackground
    ]])
end

M.capabilities = vim.lsp.protocol.make_client_capabilities()
local cmp_ok, cmp_lsp = pcall(require, 'cmp_nvim_lsp')
if cmp_ok then
    M.capabilities = cmp_lsp.default_capabilities(M.capabilities)
end
M.capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true,
}

M.on_attach = function(client, _)
    local disable_formatting = { 'ts_ls', 'lua_ls', 'html', 'jsonls', 'python' }
    if vim.tbl_contains(disable_formatting, client.name) then
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
    end
end

return M
