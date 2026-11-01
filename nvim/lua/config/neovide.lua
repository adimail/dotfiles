if vim.g.neovide then
    vim.o.guifont = 'VictorMono Nerd Font Propo:h17'
    vim.g.neovide_padding_top = 0
    vim.g.neovide_padding_bottom = 0
    vim.g.neovide_padding_right = 0
    vim.g.neovide_padding_left = 0
    vim.g.neovide_transparency = 0.5
    vim.g.transparency = 0.8
    vim.g.neovide_window_blurred = true
    vim.g.neovide_floating_blur_amount_x = 2.0
    vim.g.neovide_floating_blur_amount_y = 2.0
    vim.g.neovide_hide_mouse_when_typing = true
    vim.g.neovide_fullscreen = false
    vim.g.neovide_remember_window_size = true
    vim.g.neovide_profiler = false
    vim.g.neovide_input_macos_alt_is_meta = true
    vim.g.neovide_cursor_vfx_mode = 'ripple'

    vim.opt.laststatus = 3

    function confirm_close_tab()
        local confirm = vim.fn.confirm('Are you sure you want to close this tab?', '&Yes\n&No', 2)
        if confirm == 1 then
            vim.cmd('bdelete')
        end
    end

    vim.keymap.set({ 'i', 'n' }, '<D-a>', '<Esc>ggVG')
    vim.keymap.set({ 'i', 'n' }, '<D-w>', function()
        confirm_close_tab()
    end)
    vim.keymap.set({ 'i', 'n' }, '<D-[>', function()
        vim.cmd('BufferPrevious')
    end)
    vim.keymap.set({ 'i', 'n' }, '<D-]>>', function()
        vim.cmd('BufferNext')
    end)
    vim.keymap.set('i', '<D-t>', '<C-o>:tabnew<CR><Esc>')
    vim.keymap.set('n', '<D-t>', ':tabnew<CR>')
    vim.keymap.set('i', '<D-s>', '<C-o>:w<CR>')
    vim.keymap.set('n', '<D-s>', ':w<CR>')
    vim.keymap.set('x', '<D-x>', '"+dm0i<Esc>`0')
    vim.keymap.set('x', '<D-c>', '"+y')
    vim.keymap.set('i', '<D-v>', '<C-r><C-o>+')
    vim.keymap.set('n', '<D-v>', 'i<C-r><C-o>+<Esc>l')
    vim.keymap.set('x', '<D-v>', '"+P')
    vim.keymap.set('c', '<D-v>', '<C-r>+')
    vim.keymap.set('n', '<D-z>', 'u')
    vim.keymap.set({ 'i', 'n' }, '<D-q>', function()
        vim.cmd('confirm qa')
    end)
end
