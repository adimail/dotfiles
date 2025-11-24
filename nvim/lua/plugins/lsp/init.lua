local M = {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
        'hrsh7th/nvim-cmp', -- Auto-completion plugin
        'hrsh7th/cmp-nvim-lsp', -- LSP completions
        'hrsh7th/cmp-buffer', -- Buffer completions
        'hrsh7th/cmp-path', -- Path completions
        'b0o/schemastore.nvim', -- JSON/YAML schema support
    },
}

function M.config()
    ------------------------------------------------------------------
    -- Plugin Setup & Required Modules
    ------------------------------------------------------------------
    require('neodev').setup({})
    local nvim_lsp = require('lspconfig')
    local navic = require('nvim-navic')

    local on_attach = function(client, bufnr)
        if client.server_capabilities.documentSymbolProvider then
            navic.attach(client, bufnr)
        end
    end

    -- nvim-cmp supports additional completion capabilities
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
    capabilities.textDocument.foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true,
    }

    ------------------------------------------------------------------
    -- General Diagnostic Settings
    ------------------------------------------------------------------
    vim.fn.sign_define('DiagnosticSignError', {
        texthl = 'DiagnosticSignError',
        text = ' ✗',
        numhl = 'DiagnosticSignError',
    })
    vim.fn.sign_define('DiagnosticSignWarn', {
        texthl = 'DiagnosticSignWarn',
        text = ' ❢',
        numhl = 'DiagnosticSignWarn',
    })
    vim.fn.sign_define('DiagnosticSignHint', {
        texthl = 'DiagnosticSignHint',
        text = ' ',
        numhl = 'DiagnosticSignHint',
    })
    vim.fn.sign_define('DiagnosticSignInfo', {
        texthl = 'DiagnosticSignInfo',
        text = ' 𝓲',
        numhl = 'DiagnosticSignInfo',
    })

    ------------------------------------------------------------------
    -- Common LSP Servers Setup
    ------------------------------------------------------------------
    local servers = {
        'bashls',
        'sqlls',
        'clangd',
        'texlab',
        'dockerls',
        'marksman',
        'ansiblels',
        'ts_ls',
        'jdtls',
    }

    for _, lsp in ipairs(servers) do
        nvim_lsp[lsp].setup({
            on_attach = on_attach,
            capabilities = capabilities,
            root_dir = function()
                return vim.fn.getcwd()
            end,
        })
    end

    ------------------------------------------------------------------
    -- Language Specific LSP Configurations
    ------------------------------------------------------------------

    -- Go LSP Settings
    nvim_lsp.gopls.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        root_dir = nvim_lsp.util.root_pattern('go.mod'),
        settings = {
            gopls = {
                gofumpt = true,
                usePlaceholders = true,
                completeUnimported = true,
                experimentalPostfixCompletions = true,
                analyses = {
                    unusedparams = true,
                    shadow = true,
                },
                hints = {
                    assignVariableTypes = true,
                    compositeLiteralFields = true,
                    compositeLiteralTypes = true,
                    constantValues = true,
                    functionTypeParameters = true,
                    parameterNames = true,
                    rangeVariableTypes = true,
                },
                staticcheck = true,
            },
        },
    })

    -- YAML LSP Settings
    nvim_lsp.yamlls.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        filetypes = { 'yaml' },
        root_dir = function()
            return vim.fn.getcwd()
        end,
        settings = {
            yaml = {
                -- schemas = {
                --     ['file:///Users/agou-ops/.k8s/master-local/all.json'] = '/*.yaml',
                -- },
                -- 以下参考自：https://github.com/Allaman/nvim/blob/main/lua/core/plugins/lsp/settings/yaml.lua
                schemaStore = {
                    enable = true,
                    url = 'https://www.schemastore.org/api/json/catalog.json',
                },
                schemas = {
                    kubernetes = '*.yaml',
                    ['http://json.schemastore.org/github-workflow'] = '.github/workflows/*',
                    ['http://json.schemastore.org/github-action'] = '.github/action.{yml,yaml}',
                    ['https://raw.githubusercontent.com/microsoft/azure-pipelines-vscode/master/service-schema.json'] = 'azure-pipelines.yml',
                    ['http://json.schemastore.org/ansible-stable-2.9'] = 'roles/tasks/*.{yml,yaml}',
                    ['http://json.schemastore.org/prettierrc'] = '.prettierrc.{yml,yaml}',
                    ['http://json.schemastore.org/kustomization'] = 'kustomization.{yml,yaml}',
                    ['http://json.schemastore.org/ansible-playbook'] = '*play*.{yml,yaml}',
                    ['http://json.schemastore.org/chart'] = 'Chart.{yml,yaml}',
                    ['https://json.schemastore.org/dependabot-v2'] = '.github/dependabot.{yml,yaml}',
                    ['https://gitlab.com/gitlab-org/gitlab/-/raw/master/app/assets/javascripts/editor/schema/ci.json'] = '*gitlab-ci*.{yml,yaml}',
                    ['https://raw.githubusercontent.com/OAI/OpenAPI-Specification/main/schemas/v3.1/schema.json'] = '*api*.{yml,yaml}',
                    ['https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json'] = '*docker-compose*.{yml,yaml}',
                    ['https://raw.githubusercontent.com/argoproj/argo-workflows/master/api/jsonschema/schema.json'] = '*flow*.{yml,yaml}',
                },
                format = { enabled = false },
                validate = false,
                completion = true,
                hover = true,
            },
        },
        single_file_support = true,
    })

    -- HTML LSP Settings
    capabilities.textDocument.completion.completionItem.snippetSupport = true

    nvim_lsp.html.setup({
        capabilities = capabilities,
        on_attach = on_attach,
        filetypes = { 'html' },
        settings = {
            html = {
                suggest = {
                    html5 = true,
                },
            },
        },
    })

    -- Lua LSP Settings
    local settings = {
        Lua = {
            hint = { enable = true },
            runtime = { version = 'LuaJIT' },
            completion = {
                callSnippet = 'Replace',
            },
            diagnostics = {
                globals = {
                    'vim',
                    'use',
                    'describe',
                    'it',
                    'assert',
                    'before_each',
                    'after_each',
                },
            },
            disable = {
                'lowercase-global',
                'undefined-global',
                'unused-local',
                'unused-function',
                'unused-vararg',
                'trailing-space',
            },
        },
    }

    nvim_lsp.lua_ls.setup({
        on_attach = function(client, bufnr)
            client.server_capabilities.document_formatting = false
            client.server_capabilities.document_range_formatting = false
            on_attach(client, bufnr)
        end,
        settings = settings,
        flags = { debounce_text_changes = 150 },
        capabilities = capabilities,
    })

    -- Nginx LSP Settings
    local configs = require('lspconfig.configs')
    local root_files = {
        'default.conf',
        'nginx.conf',
    }

    -- Check if the config is already defined (useful when reloading this file)
    if not configs.nginx_ls then
        configs.nginx_ls = {
            default_config = {
                cmd = { os.getenv('HOME') .. '/.local/share/nvim/mason/bin/nginx-language-server' },
                filetypes = { 'nginx' },
                root_dir = function(fname)
                    return nvim_lsp.util.root_pattern(unpack(root_files))(fname)
                end,
                settings = {},
            },
        }
    end
    nvim_lsp.nginx_ls.setup({})

    -- SQL LSP Settings (commented out)
    -- nvim_lsp.sqls.setup{
    --   settings = {
    --     sqls = {
    --       connections = {
    --         {
    --           driver = 'mysql',
    --           dataSourceName = 'root:root@tcp(127.0.0.1:13306)/world',
    --         },
    --         {
    --           driver = 'postgresql',
    --           dataSourceName = 'host=127.0.0.1 port=15432 user=postgres password=mysecretpassword1234 dbname=dvdrental sslmode=disable',
    --         },
    --       },
    --     },
    --   },
    -- }

    -- Perl LSP Settings
    nvim_lsp.perlpls.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        root_dir = function()
            return nvim_lsp.util.root_pattern('Makefile', 'Build.PL', 'perl5', 'lib')(
                vim.fn.expand('%:p')
            )
        end,
    })

    -- HTML LSP Settings
    capabilities.textDocument.completion.completionItem.snippetSupport = true
    nvim_lsp.html.setup({
        capabilities = capabilities,
        on_attach = on_attach,
        filetypes = { 'html', 'htmldjango' }, -- Ensure HTML and related filetypes are included
        settings = {
            html = {
                suggest = {
                    html5 = true,
                },
            },
        },
    })

    -- Astro LSP Settings
    nvim_lsp.astro.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        filetypes = { 'astro' }, -- Ensure .astro files are recognized
        root_dir = nvim_lsp.util.root_pattern(
            'astro.config.mjs',
            'astro.config.js',
            'astro.config.ts',
            'package.json',
            '.git'
        ),
        -- init_options = {
        --    typescript = { -- If you need to specify a project-local TypeScript version
        --        tsdk = vim.fn.getcwd() .. "/node_modules/typescript/lib"
        --    }
        -- },
    })

    -- Python LSP Settings
    nvim_lsp.pyright.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
            python = {
                analysis = {
                    typeCheckingMode = 'basic',
                    autoSearchPaths = true,
                    useLibraryCodeForTypes = true,
                    diagnosticMode = 'workspace',
                    autoImportCompletion = true,
                },
            },
        },
    })

    -- JSON LSP settings
    nvim_lsp.jsonls.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
            json = {
                schemas = require('schemastore').json.schemas(),
                validate = { enable = true },
            },
        },
        filetypes = { 'json', 'jsonc' },
    })

    -- CSS LSP Settings
    nvim_lsp.cssls.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        filetypes = { 'css', 'scss', 'less' },
        settings = {
            css = {
                validate = true,
            },
            less = {
                validate = true,
            },
            scss = {
                validate = true,
            },
        },
    })

    -- TypeScript/JavaScript LSP Settings (ts_ls)
    nvim_lsp.ts_ls.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        root_dir = nvim_lsp.util.root_pattern(
            'package.json',
            'tsconfig.json',
            'jsconfig.json',
            '.git'
        ),
        settings = {
            completions = {
                completeFunctionCalls = true,
            },
        },
    })

    -- LaTeX LSP Settings
    nvim_lsp.texlab.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        filetypes = { 'tex', 'bib' },
        settings = {
            texlab = {
                build = {
                    executable = 'latexmk',
                    args = { '-pdf', '-interaction=nonstopmode', '-synctex=1', '%f' },
                    forwardSearchAfter = true,
                    onSave = true,
                },
                forwardSearch = {
                    executable = 'zathura',
                    args = { '--synctex-forward', '%l:1:%f', '%p' },
                },
                chktex = {
                    onOpenAndSave = true,
                    onEdit = false,
                },
                diagnostics = {
                    ignoredPatterns = { '^Overfull', '^Underfull' },
                },
            },
        },
    })

    -- Java LSP Settings (jdtls)
    nvim_lsp.jdtls.setup({
        cmd = { 'jdtls' },
        root_dir = nvim_lsp.util.root_pattern('pom.xml', 'gradle.build', '.git'),
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
            java = {
                signatureHelp = { enabled = true },
                contentProvider = { preferred = 'fernflower' },
                completion = {
                    favoriteStaticMembers = {
                        'org.junit.Assert.*',
                        'org.mockito.Mockito.*',
                        'org.mockito.ArgumentMatchers.*',
                        'org.mockito.Answers.*',
                    },
                    importOrder = {
                        'java',
                        'javax',
                        'com',
                        'org',
                    },
                },
                sources = {
                    organizeImports = {
                        starThreshold = 9999,
                        staticStarThreshold = 9999,
                    },
                },
                codeGeneration = {
                    toString = {
                        template = '${object.className}{${member.name()}=${member.value}, ${otherMembers}}',
                    },
                },
            },
        },
    })

    -- Clangd LSP Settings
    nvim_lsp.clangd.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        cmd = {
            'clangd',
            '--background-index',
            '--clang-tidy',
            '--completion-style=detailed',
            '--header-insertion=never',
        },
        root_dir = nvim_lsp.util.root_pattern('compile_commands.json', 'compile_flags.txt', '.git'),
        settings = {
            clangd = {
                inlayHints = {
                    enabled = true,
                    parameterNames = true,
                    parameterTypes = true,
                    variableTypes = true,
                    functionReturnTypes = true,
                },
            },
        },
    })

    -- OCaml LSP Settings
    nvim_lsp.ocamllsp.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        cmd = { 'ocamllsp' },
        filetypes = {
            'ocaml',
            'ocaml.menhir',
            'ocaml.interface',
            'ocaml.ocamllex',
            'reason',
        },
        root_dir = nvim_lsp.util.root_pattern('*.opam', 'esy.json', 'package.json', '.git'),
        settings = {
            codelens = { enable = true },
            inlayHints = { enable = true },
        },
    })

    -- Ember LSP Settings (Handlebars templates)
    nvim_lsp.ember.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        filetypes = { 'handlebars', 'hbs' },
        root_dir = function(fname)
            return nvim_lsp.util.root_pattern('ember-cli-build.js', 'package.json')(fname)
        end,
    })

    ------------------------------------------------------------------
    -- Diagnostic UI Configuration
    ------------------------------------------------------------------
    vim.api.nvim_set_hl(0, 'DiagnosticsBorder', { fg = '#00ff00', bg = '#1e1e1e' }) -- Green border with a dark background

    vim.diagnostic.config({
        signs = {
            text = {
                [vim.diagnostic.severity.ERROR] = '✗',
                [vim.diagnostic.severity.WARN] = '❢',
                [vim.diagnostic.severity.HINT] = '',
                [vim.diagnostic.severity.INFO] = '𝓲',
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
            format = function(diagnostic)
                return diagnostic.message
            end,
        },
    })

    vim.cmd([[
		highlight! link FloatBorder DiagnosticsBorder
		highlight! link NormalFloat DiagnosticsBackground
	]])
end

return M
