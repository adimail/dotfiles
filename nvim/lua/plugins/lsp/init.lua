local M = {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
        'hrsh7th/cmp-nvim-lsp',
        'b0o/schemastore.nvim',
    },
}

function M.config()
    local lspconfig = require('lspconfig')
    local handlers = require('plugins.lsp.handlers')
    local servers = require('plugins.lsp.servers')

    handlers.setup_ui()

    local configs = require('lspconfig.configs')
    if not configs.nginx_ls then
        configs.nginx_ls = {
            default_config = {
                cmd = { 'nginx-language-server' },
            },
        }
    end

    for server_name, server_opts in pairs(servers) do
        local server = lspconfig[server_name]
        if server then
            local cmd = server_opts.cmd or (server.document_config and server.document_config.default_config and server.document_config.default_config.cmd)
            local exe = cmd and cmd[1]
            if not exe or vim.fn.executable(exe) == 1 then
                local final_opts = vim.tbl_deep_extend('force', {
                    on_attach = handlers.on_attach,
                    capabilities = handlers.capabilities,
                }, server_opts)
                server.setup(final_opts)
            end
        end
    end
end

return M
