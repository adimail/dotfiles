local set_hl = vim.api.nvim_set_hl

set_hl(0, 'TreesitterContext', { fg = '#ddc7a1', bg = '#3c3836' })
set_hl(0, 'NormalFloat', { fg = '#ddc7a1', bg = '#1E2021' })
set_hl(0, 'FloatBorder', { fg = '#a9b665', bg = '#1E2021' })
set_hl(0, 'Pmenu', { fg = '#ddc7a1', bg = '#1E2021' })
set_hl(0, 'PmenuSel', { fg = '#FFFFFF', bg = '#d79921', bold = true })
set_hl(0, 'DiagnosticError', { fg = 'Red' })
set_hl(0, 'DiagnosticWarn', { fg = 'Orange' })
set_hl(0, 'DiagnosticHint', { fg = 'LightGrey' })

local clear_groups = {
    'Keyword',
    'Identifier',
    'Function',
    'Statement',
    'Type',
    'Constant',
    'String',
    'Operator',
    'PreProc',
    'Special',
    'GitSignsCurrentLineBlame',
}

for _, group in ipairs(clear_groups) do
    set_hl(0, group, {})
end

set_hl(0, 'Comment', { fg = '#989898' })
set_hl(0, 'GitSignsCurrentLineBlame', { fg = '#928374' })
set_hl(0, 'TSTYPE', { fg = '#D1A863' })
set_hl(0, '@module', { fg = '#D1A863' })
set_hl(0, 'Goplements', { italic = true })

set_hl(0, 'InstantUser1', { bg = '#b8bb26', fg = '#1d2021' })
set_hl(0, 'InstantName1', { fg = '#b8bb26', bold = true })
set_hl(0, 'InstantUser2', { bg = '#83a598', fg = '#1d2021' })
set_hl(0, 'InstantName2', { fg = '#83a598', bold = true })
set_hl(0, 'InstantUser3', { bg = '#fe8019', fg = '#1d2021' })
set_hl(0, 'InstantName3', { fg = '#fe8019', bold = true })
set_hl(0, 'InstantUser4', { bg = '#d3869b', fg = '#1d2021' })
set_hl(0, 'InstantName4', { fg = '#d3869b', bold = true })
