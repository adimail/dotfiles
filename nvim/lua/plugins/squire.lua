local M = {
    dir = '/Users/aditya/personal/tmp/squire.nvim',

    event = 'VeryLazy',

    keys = {
        {
            '<leader>llm',
            mode = { 'n', 'x', 'o' },
            function()
                require('squire').open_chat_window()
            end,
            desc = 'Squire: Chat with LLM',
        },
    },
}

-- function M.config()
--     require('squire').setup({})
-- end

return M
