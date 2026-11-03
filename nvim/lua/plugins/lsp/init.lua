local M = {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
        'hrsh7th/cmp-nvim-lsp',
        'b0o/schemastore.nvim',
    },
}

function M.config()
    local handlers = require('plugins.lsp.handlers')
    local servers = require('plugins.lsp.servers')

    handlers.setup_ui()

    for server_name, server_opts in pairs(servers) do
        local final_opts = vim.tbl_deep_extend('force', {
            on_attach = handlers.on_attach,
            capabilities = handlers.capabilities,
        }, server_opts)

        local cmd = final_opts.cmd
        local exe = cmd and cmd[1]
        if not exe or vim.fn.executable(exe) == 1 then
            vim.lsp.config(server_name, final_opts)
            vim.lsp.enable(server_name)
        end
    end
end

return M
