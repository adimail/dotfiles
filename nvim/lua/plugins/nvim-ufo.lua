return {
    'kevinhwang91/nvim-ufo',
    dependencies = 'kevinhwang91/promise-async',
    enabled = true,
    event = 'VeryLazy', -- Load the plugin lazily

    opts = {
        -- Uncomment this section if you prefer to use TreeSitter as the fold provider
        provider_selector = function()
            return { 'treesitter', 'indent' }
        end,

        -- Folding configurations
        open_fold_hl_timeout = 400, -- Time to highlight open folds
        close_fold_kinds_for_ft = { default = { 'imports', 'comment' } }, -- Default fold kinds

        -- Preview window configurations
        preview = {
            win_config = {
                border = { '', '─', '', '', '', '─', '', '' }, -- Custom border for the preview window
                winblend = 0, -- No transparency for the preview window
            },
            mappings = {
                scrollU = '<C-u>', -- Scroll up in preview window
                scrollD = '<C-d>', -- Scroll down in preview window
                jumpTop = '[', -- Jump to the top of the folded lines
                jumpBot = ']', -- Jump to the bottom of the folded lines
            },
        },
    },

    init = function()
        -- Set up folding UI appearance
        vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]] -- Customize fold symbols
        vim.o.foldcolumn = '1' -- Show fold indicators in a column
        vim.o.foldlevel = 99 -- Set the fold level to a high value (we'll adjust per filetype if needed)
        vim.o.foldlevelstart = 99 -- Start with all folds open
        vim.o.foldenable = true -- Enable folding
    end,

    config = function(_, opts)
        -- Custom function to handle virtual text for folded lines
        local handler = function(virtText, lnum, endLnum, width, truncate)
            local newVirtText = {}
            local totalLines = vim.api.nvim_buf_line_count(0)
            local foldedLines = endLnum - lnum
            local suffix = (' 󰦸 %d %d%%'):format(foldedLines, foldedLines / totalLines * 100)
            local sufWidth = vim.fn.strdisplaywidth(suffix)
            local targetWidth = width - sufWidth
            local curWidth = 0

            -- Add virtual text for the folded lines
            for _, chunk in ipairs(virtText) do
                local chunkText = chunk[1]
                local chunkWidth = vim.fn.strdisplaywidth(chunkText)
                if targetWidth > curWidth + chunkWidth then
                    table.insert(newVirtText, chunk)
                else
                    chunkText = truncate(chunkText, targetWidth - curWidth)
                    local hlGroup = chunk[2]
                    table.insert(newVirtText, { chunkText, hlGroup })
                    chunkWidth = vim.fn.strdisplaywidth(chunkText)

                    -- Padding if the truncated text doesn't fill the target width
                    if curWidth + chunkWidth < targetWidth then
                        suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
                    end
                    break
                end
                curWidth = curWidth + chunkWidth
            end

            -- Right-align the suffix (percentage of folded lines)
            local rAlignAppndx =
                math.max(math.min(vim.opt.textwidth['_value'], width - 1) - curWidth - sufWidth, 0)
            suffix = (' '):rep(rAlignAppndx) .. suffix
            table.insert(newVirtText, { suffix, 'MoreMsg' })
            return newVirtText
        end

        opts['fold_virt_text_handler'] = handler
        require('ufo').setup(opts) -- Set up the plugin with the options

        -- Keybindings for folding
        vim.keymap.set('n', 'zR', require('ufo').openAllFolds) -- Open all folds
        vim.keymap.set('n', 'zM', require('ufo').closeAllFolds) -- Close all folds
        vim.keymap.set('n', 'zr', require('ufo').openFoldsExceptKinds) -- Open folds except specified types
    end,
}
