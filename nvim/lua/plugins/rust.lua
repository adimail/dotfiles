-- lua/plugins/rust.lua
return {
    'mrcjkb/rustaceanvim',
    version = '^5',
    lazy = false, -- rustaceanvim handles its own lazy loading via ft
    config = function()
        -- No extra 'cmd' path needed; it will find the rustup version automatically
        vim.g.rustaceanvim = {
            server = {
                on_attach = function(client, bufnr)
                    -- Your keymaps here
                end,
            },
        }
    end,
}
