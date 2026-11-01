return {
    'mrcjkb/rustaceanvim',
    version = '^5',
    ft = { 'rust' },
    config = function()
        local handlers = require('plugins.lsp.handlers')

        vim.g.rustaceanvim = {
            tools = {
                float_win_config = {
                    border = 'rounded',
                },
                hover_actions = {
                    auto_focus = false,
                },
            },
            server = {
                on_attach = function(client, bufnr)
                    handlers.on_attach(client, bufnr)

                    local opts = { buffer = bufnr, silent = true }

                    vim.keymap.set('n', '<leader>ca', function()
                        vim.cmd.RustLsp('codeAction')
                    end, vim.tbl_extend('force', opts, { desc = 'Rust: Code Action' }))

                    vim.keymap.set('n', 'K', function()
                        vim.cmd.RustLsp({ 'hover', 'actions' })
                    end, vim.tbl_extend('force', opts, { desc = 'Rust: Hover Actions' }))

                    vim.keymap.set('n', '<leader>rd', function()
                        vim.cmd.RustLsp('debuggables')
                    end, vim.tbl_extend('force', opts, { desc = 'Rust: Run / Debug Debuggables' }))

                    vim.keymap.set('n', '<leader>rr', function()
                        vim.cmd.RustLsp('runnables')
                    end, vim.tbl_extend('force', opts, { desc = 'Rust: Runnables' }))

                    vim.keymap.set('n', '<leader>ee', function()
                        vim.cmd.RustLsp('explainError')
                    end, vim.tbl_extend('force', opts, { desc = 'Rust: Explain Error' }))

                    vim.keymap.set('n', '<leader>oc', function()
                        vim.cmd.RustLsp('openCargo')
                    end, vim.tbl_extend('force', opts, { desc = 'Rust: Open Cargo.toml' }))

                    vim.keymap.set('n', '<leader>pm', function()
                        vim.cmd.RustLsp('parentModule')
                    end, vim.tbl_extend('force', opts, { desc = 'Rust: Go to Parent Module' }))

                    if vim.lsp.inlay_hint then
                        vim.keymap.set('n', '<leader>th', function()
                            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
                        end, vim.tbl_extend('force', opts, { desc = 'Rust: Toggle Inlay Hints' }))
                    end
                end,
                default_settings = {
                    ['rust-analyzer'] = {
                        cachePriming = {
                            enable = true,
                        },
                        cargo = {
                            allFeatures = false,
                            targetDir = 'target/rust-analyzer',
                            buildScripts = {
                                enable = false,
                            },
                        },
                        check = {
                            command = 'clippy',
                        },
                        files = {
                            excludeDirs = {
                                'target',
                                '.git',
                                '.cargo',
                            },
                        },
                        procMacro = {
                            enable = true,
                            ignored = {
                                ['async-trait'] = { 'async_trait' },
                                ['napi-derive'] = { 'napi' },
                                ['async-recursion'] = { 'async_recursion' },
                            },
                        },
                        inlayHints = {
                            bindingModeHints = { enable = false },
                            chainingHints = { enable = true },
                            closingBraceHints = { enable = true, minLines = 25 },
                            closureReturnTypeHints = { enable = 'never' },
                            lifetimeElisionHints = { enable = 'never' },
                            parameterHints = { enable = true },
                            typeHints = { enable = true },
                        },
                    },
                },
            },
        }
    end,
}
