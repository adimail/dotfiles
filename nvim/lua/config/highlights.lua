vim.cmd([[
" ===========================
" Group: Custom Highlight Groups (Builtin & Treesitter)
" ===========================
hi TreesitterContext ctermfg=223 ctermbg=237 guifg=#ddc7a1 guibg=#3c3836
hi NormalFloat ctermfg=223 ctermbg=237 guifg=#ddc7a1 guibg=#1E2021
hi FloatBorder ctermfg=142 guifg=#a9b665 guibg=#1E2021

" ===========================
" Group: Statusline and Menu
" ===========================
hi lualine_c_inactive ctermfg=223 ctermbg=237 gui=italic guifg=#ddc7a1 guibg=#3c3836
hi Pmenu ctermfg=223 ctermbg=237 guifg=#ddc7a1 guibg=#1E2021
hi PmenuSel ctermfg=0 ctermbg=66 gui=bold guifg=#FFFFFF guibg=#d79921
hi PmenuSbar ctermbg=237 gui=NONE guibg=#3c3836
hi PmenuThumb ctermfg=NONE ctermbg=66 gui=NONE guibg=#d79921

" ===========================
" Group: Diagnostics and Error Highlighting
" ===========================
hi DiagnosticError ctermfg=1 guifg=Red
hi DiagnosticWarn ctermfg=3 guifg=Orange
hi DiagnosticHint ctermfg=7 guifg=LightGrey

" ===========================
" Group: Clearing Highlights (Disables specific groups)
" ===========================
hi BufferLine ctermbg=NONE guibg=NONE guifg=NONE
hi BufferLineFill ctermbg=NONE guibg=NONE guifg=NONE
hi BufferLineIndicatorSelected ctermbg=NONE guibg=NONE guifg=NONE
hi BufferLineIndicatorVisible ctermbg=NONE guibg=NONE guifg=NONE
hi BufferLineModified ctermbg=NONE guibg=NONE guifg=NONE
hi BufferLineSelected ctermbg=NONE guibg=NONE guifg=NONE
hi BufferLineVisible ctermbg=NONE guibg=NONE guifg=NONE
hi clear Keyword
hi clear Identifier
hi clear Function
hi clear Statement
hi clear Type
hi clear Constant
hi clear String
hi clear Operator
hi clear PreProc
hi clear Special
hi clear GitSignsCurrentLineBlame

" ===========================
" Group: Comment and GitSigns
" ===========================
hi Comment cterm=NONE ctermfg=245 gui=NONE guifg=#989898               " Sets comment color to muted gray (#928374)
hi GitSignsCurrentLineBlame cterm=NONE ctermfg=245 gui=NONE guifg=#928374       " Colors Git blame in muted gray and italicizes it

" ===========================
" Group: Treesitter Highlights (Type, Function, and Keywords)
" ===========================
hi TSTYPE ctermfg=3 guifg=#D1A863                                " Sets Type-related elements to a yellowish color (#D1A863)
hi TSTypeDefinition ctermfg=3 guifg=#D1A863                      " Sets Type Definitions to a yellowish color (#D1A863)
hi @module ctermfg=3 guifg=#D1A863                               " Sets module-related elements to a yellowish color (#D1A863)


" ===========================
" Group: Goplements
" ===========================
hi Goplements ctermfg=7 ctermbg=22 gui=italic guifg=NONE guibg=NONE
]])
