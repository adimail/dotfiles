-- lua/snippets/rust.lua
local ls = require('luasnip')
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
    -- main function
    s('fnmain', {
        t({ 'fn main() {', '    ' }),
        i(1, 'println!("Hello, world!");'),
        t({ '', '}' }),
    }),
    -- println!
    s('pr', {
        t('println!("'),
        i(1, '{}'),
        t('", '),
        i(2, 'val'),
        t(');'),
    }),
    -- dbg!
    s('db', {
        t('dbg!('),
        i(1, 'expr'),
        t(');'),
    }),
    -- unit test module
    s('modtest', {
        t({
            '#[cfg(test)]',
            'mod tests {',
            '    use super::*;',
            '',
            '    #[test]',
            '    fn ',
        }),
        i(1, 'test_name'),
        t({ '() {', '        ' }),
        i(2, 'assert!(true);'),
        t({ '', '    }', '}' }),
    }),
}
