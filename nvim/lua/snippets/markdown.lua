local ls = require('luasnip')
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

return {
    -- Headings
    s('h1', { t('# '), i(1, 'Header 1') }),
    s('h2', { t('## '), i(1, 'Header 2') }),
    s('h3', { t('### '), i(1, 'Header 3') }),
    s('h4', { t('#### '), i(1, 'Header 4') }),
    s('h5', { t('##### '), i(1, 'Header 5') }),
    s('h6', { t('###### '), i(1, 'Header 6') }),

    -- Bold Text
    s('bold', { t('**'), i(1, 'Bold Text'), t('**') }),

    -- Italics
    s('italic', { t('_'), i(1, 'Italic Text'), t('_') }),

    -- Strikethrough
    s('strike', { t('~~'), i(1, 'Strikethrough Text'), t('~~') }),

    -- Blockquote
    s('quote', { t('> '), i(1, 'Blockquote') }),

    -- Unordered List
    s('ul', {
        t('- '),
        i(1, 'List Item'),
        t({ '', '- ' }),
        i(0),
    }),

    -- Ordered List
    s('ol', {
        t('1. '),
        i(1, 'List Item'),
        t({ '', '1. ' }),
        i(0),
    }),

    -- Task List
    s('task', {
        t('- [ ] '),
        i(1, 'Task Item'),
        t({ '', '- [ ] ' }),
        i(0),
    }),

    -- Code Block
    s('code', {
        t('```'),
        i(1, 'language'),
        t({ '', '' }),
        i(2, 'Code goes here'),
        t({ '', '```' }),
    }),

    -- Inline Code
    s('inline', { t('`'), i(1, 'Inline Code'), t('`') }),

    -- Link
    s('link', { t('['), i(1, 'Link Text'), t(']('), i(2, 'URL'), t(')') }),

    -- Image
    s('image', { t('!['), i(1, 'Alt Text'), t(']('), i(2, 'Image URL'), t(')') }),

    -- Table
    s('table', {
        t('| '),
        i(1, 'Header 1'),
        t(' | '),
        i(2, 'Header 2'),
        t(' |'),
        t({ '', '| --- | --- |', '' }),
        t('| '),
        i(3, 'Row 1 Col 1'),
        t(' | '),
        i(4, 'Row 1 Col 2'),
        t(' |'),
    }),

    -- Horizontal Rule
    s('hr', { t('---') }),

    -- Table of Contents
    s('toc', {
        t('- ['),
        i(1, 'Section'),
        t('](#'),
        f(function(args)
            return args[1][1]:lower():gsub('%s+', '-')
        end, { 1 }),
        t(')'),
    }),

    -- Footnote
    s('footnote', { t('[^'), i(1, 'id'), t(']: '), i(2, 'Footnote content') }),

    -- Checkbox
    s('checkbox', {
        t('- [ ] '),
        i(1, 'Unchecked Item'),
        t({ '', '- [x] ' }),
        i(2, 'Checked Item'),
    }),

    -- Emphasis Variations
    s('emphasis', { t('**_'), i(1, 'Emphasized Text'), t('_**') }),

    -- HTML Comment
    s('comment', { t('<!-- '), i(1, 'Comment Text'), t(' -->') }),
}
