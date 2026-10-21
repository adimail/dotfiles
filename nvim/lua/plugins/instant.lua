return {
    'jbyuki/instant.nvim',
    cmd = {
        'InstantStartServer',
        'InstantStartSingle',
        'InstantStartSession',
        'InstantJoinSingle',
        'InstantJoinSession',
        'InstantStop',
        'InstantFollow',
        'InstantFollowStop',
    },
    init = function()
        vim.g.instant_cursor_hl_group_user1 = 'InstantUser1'
        vim.g.instant_name_hl_group_user1 = 'InstantName1'
        vim.g.instant_cursor_hl_group_user2 = 'InstantUser2'
        vim.g.instant_name_hl_group_user2 = 'InstantName2'
        vim.g.instant_cursor_hl_group_user3 = 'InstantUser3'
        vim.g.instant_name_hl_group_user3 = 'InstantName3'
        vim.g.instant_cursor_hl_group_user4 = 'InstantUser4'
        vim.g.instant_name_hl_group_user4 = 'InstantName4'
    end,
    keys = {
        {
            '<leader>is',
            function()
                if vim.g.instant_status then
                    vim.notify('Already in a session. Stop it first with \\ix', vim.log.levels.WARN)
                    return
                end

                vim.ui.input({ prompt = 'Port (default 8080): ' }, function(port)
                    if port == nil then return end
                    port = port ~= '' and port or '8080'

                    local handle = io.popen('lsof -i :' .. port .. ' -t 2>/dev/null')
                    local result = handle:read('*a')
                    handle:close()

                    if result ~= '' then
                        vim.notify(
                            'Port ' .. port .. ' is already in use. Try a different port.',
                            vim.log.levels.ERROR
                        )
                        return
                    end

                    local ok, err = pcall(vim.cmd, 'InstantStartServer 0.0.0.0 ' .. port)
                    if not ok then
                        vim.notify('Failed to start server: ' .. err, vim.log.levels.ERROR)
                        return
                    end

                    vim.defer_fn(function()
                        local ok2, err2 = pcall(vim.cmd, 'InstantStartSession localhost ' .. port)
                        if not ok2 then
                            vim.notify('Server started but session failed: ' .. err2, vim.log.levels.ERROR)
                            pcall(vim.cmd, 'InstantStop')
                            return
                        end

                        local ip = vim.fn.system('hostname -I'):match('%S+')
                            or vim.fn.system('ipconfig getifaddr en0'):gsub('%s+', '')
                        vim.g.instant_status = true
                        vim.notify('⚡ Session started — share with pair: ' .. ip .. ':' .. port, vim.log.levels.INFO)
                    end, 300)
                end)
            end,
            desc = 'Instant: Start session (host)',
        },
        {
            '<leader>ij',
            function()
                if vim.g.instant_status then
                    vim.notify('Already in a session. Stop it first with \\ix', vim.log.levels.WARN)
                    return
                end

                vim.ui.input({ prompt = 'Host IP: ' }, function(ip)
                    if not ip or ip == '' then
                        vim.notify('No IP entered, aborting.', vim.log.levels.WARN)
                        return
                    end

                    vim.ui.input({ prompt = 'Port (default 8080): ' }, function(port)
                        if port == nil then return end
                        port = port ~= '' and port or '8080'

                        local ok, err = pcall(vim.cmd, 'InstantJoinSession ' .. ip .. ' ' .. port)
                        if not ok then
                            vim.notify('Failed to join session: ' .. err, vim.log.levels.ERROR)
                            return
                        end

                        vim.g.instant_status = true
                        vim.notify('⚡ Joined session at ' .. ip .. ':' .. port, vim.log.levels.INFO)
                    end)
                end)
            end,
            desc = 'Instant: Join session (guest)',
        },
        {
            '<leader>ix',
            function()
                if not vim.g.instant_status then
                    vim.notify('No active session.', vim.log.levels.WARN)
                    return
                end

                local ok, err = pcall(vim.cmd, 'InstantStop')
                if not ok then
                    vim.notify('Error stopping session: ' .. err, vim.log.levels.ERROR)
                    return
                end

                vim.g.instant_status = false
                vim.notify('Session stopped.', vim.log.levels.INFO)
            end,
            desc = 'Instant: Stop session',
        },
        {
            '<leader>ii',
            function()
                local ip = vim.fn.system('hostname -I 2>/dev/null'):match('%S+')
                if not ip or ip == '' then
                    ip = vim.fn.system('ipconfig getifaddr en0 2>/dev/null'):gsub('%s+', '')
                end
                if not ip or ip == '' then
                    vim.notify('Could not determine IP address.', vim.log.levels.ERROR)
                    return
                end
                vim.notify('Your IP: ' .. ip, vim.log.levels.INFO)
            end,
            desc = 'Instant: Show my IP',
        },
        {
            '<leader>ib',
            function()
                if not vim.g.instant_status then return end
                local bufs = vim.api.nvim_list_bufs()
                local instant_bufs = {}
                for _, buf in ipairs(bufs) do
                    if vim.api.nvim_buf_is_loaded(buf) then
                        local name = vim.api.nvim_buf_get_name(buf)
                        if name ~= '' and vim.fn.filereadable(name) == 0 then
                            table.insert(instant_bufs, { buf = buf, name = name })
                        end
                    end
                end
                if #instant_bufs == 0 then
                    vim.notify('No active pair programming buffers found.', vim.log.levels.INFO)
                    return
                end
                vim.ui.select(instant_bufs, {
                    prompt = 'Select Instant Buffer:',
                    format_item = function(item)
                        return vim.fn.fnamemodify(item.name, ':t') .. ' (' .. item.name .. ')'
                    end,
                }, function(choice)
                    if choice then
                        vim.api.nvim_set_current_buf(choice.buf)
                    end
                end)
            end,
            desc = 'Instant: Session Buffers',
        },
        {
            '<leader>if',
            function()
                if not vim.g.instant_status then return end
                local users = {}
                local seen = {}
                for ns_name, ns_id in pairs(vim.api.nvim_get_namespaces()) do
                    if ns_name:match('instant') then
                        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                            if vim.api.nvim_buf_is_loaded(buf) then
                                local marks = vim.api.nvim_buf_get_extmarks(buf, ns_id, 0, -1, {details = true})
                                for _, mark in ipairs(marks) do
                                    if mark[4] and mark[4].virt_text then
                                        for _, vt in ipairs(mark[4].virt_text) do
                                            local uname = vt[1]
                                            if uname and not seen[uname] and uname ~= vim.g.instant_username then
                                                seen[uname] = true
                                                table.insert(users, uname)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                if #users == 0 then
                    vim.ui.input({ prompt = 'Enter username to follow: ' }, function(input)
                        if input and input ~= '' then vim.cmd('InstantFollow ' .. input) end
                    end)
                    return
                end
                vim.ui.select(users, { prompt = 'Select user to follow:' }, function(choice)
                    if choice then vim.cmd('InstantFollow ' .. choice) end
                end)
            end,
            desc = 'Instant: Follow User',
        },
        {
            '<leader>iF',
            function()
                if vim.g.instant_status then vim.cmd('InstantFollowStop') end
            end,
            desc = 'Instant: Stop Following',
        },
    },
}
