local M = {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
        'hrsh7th/cmp-nvim-lsp',
        'b0o/schemastore.nvim',
        'folke/neodev.nvim',
        'smiteshp/nvim-navic',
    },
}

function M.config()
    require('neodev').setup({})
    local lspconfig = require('lspconfig')
    local handlers = require('plugins.lsp.handlers')
    local servers = require('plugins.lsp.servers')

    -- 1. Initialize UI
    handlers.setup_ui()

    -- 2. Handle Custom Server Definitions (like Nginx)
    local configs = require('lspconfig.configs')
    if not configs.nginx_ls then
        configs.nginx_ls = {
            default_config = {
                -- Principle: Point to a standard location or system path
                cmd = { 'nginx-language-server' },
            },
        }
    end

    -- 3. Execution Pipeline
    for server_name, server_opts in pairs(servers) do
        -- Check if server exists in lspconfig
        local server = lspconfig[server_name]
        if not server then
            goto continue
        end

        -- Principle: Human-First Safety Check
        -- Only setup if the binary exists on the system path.
        -- Prevents Neovim from crashing on machines without specific languages.
        local cmd = server.document_config.default_config.cmd
        if cmd and cmd[1] and vim.fn.executable(cmd[1]) == 1 then
            -- Compose global behavior with specific server data
            local final_opts = vim.tbl_deep_extend('force', {
                on_attach = handlers.on_attach,
                capabilities = handlers.capabilities,
            }, server_opts)

            server.setup(final_opts)
        end

        ::continue::
    end
end

return M
