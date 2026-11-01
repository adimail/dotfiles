return {
    {
        'HiPhish/rainbow-delimiters.nvim',
        event = { 'BufReadPost', 'BufNewFile' },
        config = function()
            local rainbow_delimiters = require('rainbow-delimiters')

            vim.g.rainbow_delimiters = {
                strategy = {
                    [''] = rainbow_delimiters.strategy['global'],
                    vim = rainbow_delimiters.strategy['local'],
                },
                query = {
                    [''] = 'rainbow-delimiters',
                    lua = 'rainbow-blocks',
                },
                highlight = {
                    'RainbowDelimiterYellow',
                    'RainbowDelimiterRed',
                    'RainbowDelimiterOrange',
                    'RainbowDelimiterBlue',
                    'RainbowDelimiterGreen',
                    'RainbowDelimiterViolet',
                    'RainbowDelimiterCyan',
                },
            }
        end,
    },
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        event = { 'BufReadPost', 'BufNewFile' },
        cmd = { 'TSUpdate', 'TSInstall' },
        dependencies = { 'nvim-treesitter/nvim-treesitter-textobjects' },
        config = function()
            require('nvim-treesitter.configs').setup({
                ensure_installed = {
                    'bash',
                    'c',
                    'cmake',
                    'cpp',
                    'css',
                    'diff',
                    'dockerfile',
                    'fish',
                    'gitignore',
                    'go',
                    'groovy',
                    'html',
                    'http',
                    'java',
                    'javascript',
                    'jsdoc',
                    'json',
                    'jsonc',
                    'latex',
                    'lua',
                    'markdown',
                    'markdown_inline',
                    'nix',
                    'norg',
                    'org',
                    'perl',
                    'php',
                    'python',
                    'query',
                    'regex',
                    'rust',
                    'scss',
                    'sql',
                    'toml',
                    'tsx',
                    'typescript',
                    'vue',
                    'yaml',
                    'astro',
                },
                sync_install = false,
                auto_install = false,
                highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = false,
                },
            })
        end,
    },
}
