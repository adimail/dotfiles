local M = {
    'CRAG666/code_runner.nvim',
    ft = { 'python', 'cpp', 'c', 'go', 'java' },
    event = 'VeryLazy',
    keys = {
        {
            '<leader>rr',
            '<cmd>RunCode<cr>',
            desc = 'Run Code (code_runner.nvim)',
        },
    },
}

function M.config()
    require('code_runner').setup({
        mode = 'term',
        focus = true,
        startinsert = true,
        filetype = {
            python = 'python3 $file',
            cpp = 'g++ -std=c++17 $file -o out && ./out',
            c = 'gcc $file -o out && ./out',
            go = 'go run $file',
            java = 'javac $file && java $basename',
        },
    })
end

return M
