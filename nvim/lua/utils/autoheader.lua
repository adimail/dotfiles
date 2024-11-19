vim.cmd([[
autocmd BufNewFile *.sh,*.py lua SetTitle()
]])

function SetTitle()
    if vim.fn.expand('%:e') == 'sh' then
        vim.fn.setline(1, '#!/bin/bash')
        vim.fn.setline(10, '')
        vim.fn.setline(11, '')
    end
end

vim.cmd([[
autocmd BufNewFile * normal G
]])
