local util = require('lspconfig.util')

return {
    -- Servers with default config
    bashls = {},
    sqlls = {},
    dockerls = {},
    marksman = {},
    ansiblels = {},
    jdtls = { root_dir = util.root_pattern('pom.xml', 'gradle.build', '.git') },
    ocamllsp = { root_dir = util.root_pattern('*.opam', 'esy.json', 'package.json', '.git') },

    -- Go
    gopls = {
        root_dir = util.root_pattern('go.mod', '.git'),
        settings = {
            gopls = {
                gofumpt = true,
                usePlaceholders = true,
                completeUnimported = true,
                hints = {
                    assignVariableTypes = true,
                    parameterNames = true,
                    functionTypeParameters = true,
                },
            },
        },
    },

    -- Lua
    lua_ls = {
        settings = {
            Lua = {
                hint = { enable = true },
                diagnostics = { globals = { 'vim' } },
                workspace = { checkThirdParty = false },
            },
        },
    },

    -- TypeScript
    ts_ls = {
        filetypes = { 'javascript', 'typescript', 'javascriptreact', 'typescriptreact' },
        settings = {
            ['typescript.preferences.jsx.jsxRuntime'] = 'react-jsx',
        },
    },

    -- Python
    pyright = {
        settings = {
            python = {
                analysis = { typeCheckingMode = 'basic', autoSearchPaths = true },
            },
        },
    },

    -- YAML
    yamlls = {
        settings = {
            yaml = {
                schemaStore = { enable = true },
                schemas = require('schemastore').yaml.schemas(),
            },
        },
    },

    -- Clangd (C++)
    clangd = {
        cmd = { 'clangd', '--background-index', '--clang-tidy', '--header-insertion=never' },
    },

    -- Nginx (Custom setup handled in init.lua but config stays here)
    nginx_ls = {
        filetypes = { 'nginx' },
        root_dir = util.root_pattern('nginx.conf', 'default.conf'),
    },
}
