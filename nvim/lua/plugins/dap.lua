return {
    {
        'mfussenegger/nvim-dap',
        dependencies = {
            'rcarriga/nvim-dap-ui',
            'nvim-neotest/nvim-nio',
            'theHamsta/nvim-dap-virtual-text',
        },
        keys = {
            { '<F5>', function() require('dap').continue() end, desc = 'DAP: Continue' },
            { '<F10>', function() require('dap').step_over() end, desc = 'DAP: Step Over' },
            { '<F11>', function() require('dap').step_into() end, desc = 'DAP: Step Into' },
            { '<F12>', function() require('dap').step_out() end, desc = 'DAP: Step Out' },
            { '<leader>b', function() require('dap').toggle_breakpoint() end, desc = 'DAP: Toggle Breakpoint' },
            { '<leader>B', function() require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = 'DAP: Conditional Breakpoint' },
            { '<leader>du', function() require('dapui').toggle() end, desc = 'DAP UI: Toggle' },
            { '<leader>dr', function() require('dap').repl.open() end, desc = 'DAP: Open REPL' },
        },
        config = function()
            local dap = require('dap')
            local dapui = require('dapui')

            require('nvim-dap-virtual-text').setup()
            dapui.setup()

            -- Automatically open/close dap-ui when debugging starts/finishes
            dap.listeners.after.event_initialized['dapui_config'] = function()
                dapui.open()
            end
            dap.listeners.before.event_terminated['dapui_config'] = function()
                dapui.close()
            end
            dap.listeners.before.event_exited['dapui_config'] = function()
                dapui.close()
            end

            -- Customize breakpoint signs
            vim.fn.sign_define('DapBreakpoint', { text = '●', texthl = 'DiagnosticError', linehl = '', numhl = '' })
            vim.fn.sign_define('DapBreakpointCondition', { text = '◆', texthl = 'DiagnosticWarn', linehl = '', numhl = '' })
            vim.fn.sign_define('DapStopped', { text = '▶', texthl = 'DiagnosticInfo', linehl = 'Visual', numhl = '' })
        end,
    },
}
