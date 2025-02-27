return {
    'hat0uma/csvview.nvim',
    cmd = { 'CsvViewEnable', 'CsvViewDisable', 'CsvViewToggle' },
    opts = {
        parser = {
            comments = { '#', '//' },
        },
        keymaps = {
            -- Text objects for selecting fields
            textobject_field_inner = { 'if', mode = { 'o', 'x' } },
            textobject_field_outer = { 'af', mode = { 'o', 'x' } },
            -- Excel-like navigation
            jump_next_field_end = { '<Tab>', mode = { 'n', 'v' } },
            jump_prev_field_end = { '<S-Tab>', mode = { 'n', 'v' } },
            jump_next_row = { '<Enter>', mode = { 'n', 'v' } },
            jump_prev_row = { '<S-Enter>', mode = { 'n', 'v' } },
        },
    },
    config = function()
        -- Set up the plugin with the provided options
        require('csvview').setup()

        -- Define custom highlight groups for column text colors (foreground only)
        local colors = {
            { name = 'CsvColumn1', guifg = '#FF5555' }, -- Red
            { name = 'CsvColumn2', guifg = '#55FF55' }, -- Green
            { name = 'CsvColumn3', guifg = '#5555FF' }, -- Blue
            { name = 'CsvColumn4', guifg = '#FFFF55' }, -- Yellow
            { name = 'CsvColumn5', guifg = '#FF55FF' }, -- Magenta
            { name = 'CsvColumn6', guifg = '#55FFFF' }, -- Cyan
            { name = 'CsvColumn7', guifg = '#FFAA55' }, -- Orange
            { name = 'CsvColumn8', guifg = '#AA55FF' }, -- Purple
            { name = 'CsvColumn9', guifg = '#55AAFF' }, -- Light Blue
            { name = 'CsvColumn10', guifg = '#AAAAAA' }, -- Gray
        }

        -- Set up the highlight groups with only foreground colors
        for _, color in ipairs(colors) do
            vim.api.nvim_set_hl(0, color.name, { fg = color.guifg })
        end

        -- Function to apply column text color highlights
        local function highlight_columns()
            local bufnr = vim.api.nvim_get_current_buf()
            local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
            if #lines == 0 then
                return
            end

            -- Clear previous highlights
            vim.api.nvim_buf_clear_namespace(bufnr, -1, 0, -1)

            -- Process each line
            for lnum, line in ipairs(lines) do
                local col_start = 0
                local col_num = 1
                local in_field = false

                for i = 1, #line do
                    local char = line:sub(i, i)
                    if char == ',' and not in_field then
                        -- Apply text color to the previous field
                        if col_start < i - 1 then
                            local hl_group = colors[col_num] and colors[col_num].name
                                or 'CsvColumn10'
                            vim.api.nvim_buf_add_highlight(
                                bufnr,
                                -1,
                                hl_group,
                                lnum - 1,
                                col_start,
                                i - 1
                            )
                        end
                        col_start = i
                        col_num = col_num + 1
                    elseif char == '"' then
                        in_field = not in_field -- Toggle quote state
                    end
                end

                -- Apply text color to the last field
                if col_start < #line then
                    local hl_group = colors[col_num] and colors[col_num].name or 'CsvColumn10'
                    vim.api.nvim_buf_add_highlight(bufnr, -1, hl_group, lnum - 1, col_start, #line)
                end
            end
        end

        -- Create an autocommand group
        local group = vim.api.nvim_create_augroup('CsvViewCustom', { clear = true })

        -- Hook into CsvViewAttach event to apply highlights
        vim.api.nvim_create_autocmd('User', {
            pattern = 'CsvViewAttach',
            group = group,
            callback = function()
                highlight_columns()
            end,
        })
    end,
}
