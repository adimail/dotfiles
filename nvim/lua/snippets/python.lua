local ls = require('luasnip')
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
    -- function
    s('def', {
        t('def '),
        i(1, 'function_name'),
        t('('),
        i(2, 'args'),
        t({ '):', '    ' }),
        i(3, 'pass'),
    }),
    -- class
    s('class', {
        t('class '),
        i(1, 'ClassName'),
        t({ ':', '    def __init__(self, ' }),
        i(2, 'args'),
        t({ '):', '        ' }),
        t('self.'),
        i(3, 'attr'),
        t(' = '),
        i(4, 'value'),
    }),
    -- main function
    s('main', {
        t({ "if __name__ == '__main__':", '    ' }),
        i(1, 'main()'),
    }),
}
