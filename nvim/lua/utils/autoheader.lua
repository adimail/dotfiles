function SetTitle()
    if vim.fn.expand('%:e') == 'sh' then
        vim.fn.setline(1, '#!/bin/bash')
        vim.fn.setline(10, '')
        vim.fn.setline(11, '')
    end
end

vim.api.nvim_create_autocmd('BufNewFile', {
    pattern = { '*.sh', '*.py' },
    callback = SetTitle,
})
