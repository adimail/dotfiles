-- lua/snippets/java.lua
local ls = require('luasnip')
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
    -- psvm / main method
    s('psvm', {
        t({ 'public static void main(String[] args) {', '    ' }),
        i(1, '// code'),
        t({ '', '}' }),
    }),
    -- sout
    s('sout', {
        t('System.out.println('),
        i(1, ''),
        t(');'),
    }),
    -- serr
    s('serr', {
        t('System.err.println('),
        i(1, ''),
        t(');'),
    }),
}
