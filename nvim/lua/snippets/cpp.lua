local ls = require('luasnip')
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local rep = require('luasnip.extras').rep

return {
    -- main function
    s('main', {
        t({ '#include <bits/stdc++.h>', '', 'using namespace std;', '', 'int main() {', '    ' }),
        i(1, 'cout << "Hello, World!" << endl;'),
        t({ '', '    return 0;', '}' }),
    }),
    -- for loop
    s('for', {
        t('for (int '),
        i(1, 'i'),
        t(' = 0; '),
        i(2, 'i'),
        t(' < '),
        i(3, 'n'),
        t('; '),
        i(4, 'i++'),
        t({ ') {', '    ' }),
        i(5, '// Code'),
        t({ '', '}' }),
    }),
    -- class
    s('class', {
        t({ 'class ' }),
        i(1, 'ClassName'),
        t({ ' {', 'public:', '    ' }),
        t(i(2, 'ClassName'), '('),
        i(3, 'args'),
        t({ ');', 'private:', '    ' }),
        t('// Private members'),
        t({ '', '};' }),
    }),
    -- cout snippet
    s('cout', {
        t('cout << "'),
        i(1, ''),
        t('" << endl;'),
    }),
    -- leetcode solution
    s('lc', {
        t({
            '#include <iostream>',
            '',
            'using namespace std;',
            '',
            'class Solution {',
            'public:',
            '    int ',
        }),
        i(1, 'methodname'),
        t('() {'),
        t({ '', '    }', '};', '', 'int main() {', '    Solution sol;', '    cout << sol.' }),
        rep(1),
        t('() << endl;'),
        t({ '', '    return 0;', '}' }),
    }),
}
