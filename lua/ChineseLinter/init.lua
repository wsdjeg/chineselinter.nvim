local M = {}

local ignored_errors = {}

local chinese_punctuation = '[\\u2010-\\u201f\\u2026\\uff01-\\uff0f\\uff1a-\\uff1f\\uff3b-\\uff40\\uff5b-\\uff5e]'

local punctuation_en = '[､,:;?!-]'

-- 中文标点符号
local punctuation_cn =
    '[、，：；。？！‘’“”（）《》『』＂＇／＜＞＝［］｛｝【】]'

-- 中文汉字
local chars_cn = '[\\u4e00-\\u9fff]'

-- 数字
local numbers = '[0-9]'

-- 全角数字
local numbers_cn = '[\\uff10-\\uff19]'

-- 英文字母
local chars_en = '[a-zA-Z]'

-- 单位
-- TODO: 需要添加更多的单位，单位见以下链接
-- https://unicode-table.com/cn/blocks/cjk-compatibility/
-- https://unicode-table.com/cn/#2031
-- https://unicode-table.com/cn/#2100
local symbol = '[%‰‱\\u3371-\\u33df\\u2100-\\u2109]'

-- 空白符号
local blank = '\\(\\s\\|[\\u3000]\\)'

local rules = {
    E001 = {
        { '中文字符后存在英文标点', chars_cn .. '[､,:;?!]' },
    },
    E002 = {
        { '中文与英文之间没有空格', chars_cn .. chars_en },
        { '英文与中文之间没有空格', chars_en .. chars_cn },
    },
    E003 = {
        { '中文与数字之间没有空格', chars_cn .. numbers },
        { '数字与中文之间没有空格', numbers .. chars_cn },
    },
    E004 = {
        {
            '中文标点前存在空格',
            blank .. '\\+\\ze' .. chinese_punctuation,
        },
        {
            '中文标点后存在空格',
            chinese_punctuation .. '\\zs' .. blank .. '\\+',
        },
    },
    --   'E005' : [
    --                 ['行尾有空格'                          , s:blank . '\+$'],
    --            ],
    --   'E006' : [
    --                 ['数字和单位之间有空格'                , s:numbers . '\zs' . s:blank . '\+\ze' . s:symbol],
    --            ],
    --   'E007' : [
    --                 ['数字使用了全角数字'                  , s:numbers_cn . '\+'],
    --            ],
    --   'E008' : [
    --                 ['汉字之间存在空格'                    , s:chars_cn . '\zs' . s:blank . '\+\ze' . s:chars_cn],
    --            ],
    --   'E009' : [
    --                 ['中文标点符号重复'                    , '\(' . s:punctuation_cn . '\)\1\+'],
    --                 ['连续多个中文标点符号'                , '[、，：；。！？]\{2,}'],
    --            ],
    --   'E010' : [
    --                 ['英文标点前侧存在空格'                , s:blank . '\+\ze' . '[､,:;?!]'],
    --                 ['英文标点符号后侧的空格数量多于 1 个' , '[､,:;?!]' . s:blank . '\{2,}'],
    --                 ['英文标点与英文之间没有空格'          , '[､,:;?!]' . s:chars_en],
    --                 ['英文标点与中文之间没有空格'          , '[､,:;?!]' . s:chars_cn],
    --                 ['英文标点与数字之间没有空格'          , '[､,:;?!]' . s:numbers],
    --            ],
    --   'E011' : [
    --                 ['中文与英文之间空格数量多于 1 个'     , '\%#=2' . s:chars_cn . '\zs' . s:blank . '\{2,}\ze' . s:chars_en],
    --                 ['英文与中文之间空格数量多于 1 个'     , '\%#=2' . s:chars_en . '\zs' . s:blank . '\{2,}\ze' . s:chars_cn],
    --            ],
    --   'E012' : [
    --                 ['中文与数字之间空格数量多于 1 个'     , '\%#=2' . s:chars_cn . '\zs' . s:blank . '\{2,}\ze' . s:numbers],
    --                 ['数字与中文之间空格数量多于 1 个'     , '\%#=2' . s:numbers . '\zs' . s:blank . '\{2,}\ze' . s:chars_cn],
    --            ],
    --   'E013' : [
    --                 ['英文与数字之间没有空格'              , s:chars_en . s:numbers],
    --                 ['数字与英文之间没有空格'              , s:numbers . s:chars_en],
    --            ],
    --   'E014' : [
    --                 ['英文与数字之间空格数量多于 1 个'     , s:chars_en . '\zs' . s:blank . '\{2,}\ze' . s:numbers],
    --                 ['数字与英文之间空格数量多于 1 个'     , s:numbers . '\zs' . s:blank . '\{2,}\ze' . s:chars_en],
    --            ],
    --   'E015' : [
    --                 ['英文标点符号重复'                    , '\(' . s:punctuation_en . s:blank . '*\)\1\+'],
    --                 ['连续多个英文标点符号'                , '\(' . '[,:;?!-]' . s:blank . '*\)\{2,}'],
    --            ],
    --   'E016' : [
    --                 ['连续的空行数量大于 2 行'             , '^\(' . s:blank . '*\n\)\{3,}'],
    --            ],
    --   'E017' : [
    --                 ['数字之间存在空格'                    , s:numbers . '\zs' . s:blank . '\+\ze' . s:numbers],
    --            ],
    --   'E018' : [
    --                 ['行首有空格'                          , '^' . s:blank . '\+'],
    --            ],
    --   'E019' : [
    --                 ['存在不应出现在行首的标点'            , '^' . '[､,:;｡?!\/)]】}’”、，：；。？！／》』）］】｝]'],
    --                 ['存在不应出现在行尾的标点'            , '[､,\/([【{‘“、，／《『（［【｛]' . '$'],
    --            ],
    --   'E020' : [
    --                 ['省略号“…”的数量只有 1 个'            , '\(^\|[^…]\)' . '\zs' . '…' . '\ze' . '\([^…]\|$\)'],
    --                 ['省略号“…”的数量大于 2 个'            , '…\{3,}'],
    --            ],
    --   'E021' : [
    --                 ['破折号“—”的数量只有 1 个'            , '\(^\|[^—]\)' . '\zs' . '—' . '\ze' . '\([^—]\|$\)'],
    --                 ['破折号“—”的数量大于 2 个'            , '—\{3,}'],
    --            ],
}

local function find_errors(line, rule)
    if type(rule.regex) == 'string' then
        local re = vim.regex(rule.regex)

        local col = re:match_str(line)

        return col
    else
        for _, regex in ipairs(rule.regex) do
            local re = vim.regex(regex)

            local col = re:match_str(line)

            return col
        end
    end
end

function M.check()
    local bufnr = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local lint_results = {}
    for nr, line in ipairs(lines) do
        for err, rule in pairs(rules) do
            if not vim.tbl_contains(ignored_errors, err) then
                local col = find_errors(line, rule)
                if col then
                    table.insert(lint_results, {
                        bufnr = bufnr,
                        lnum = nr,
                        col = col,
                        text = rule.desc,
                        type = 'E',
                        nr = err,
                    })
                end
            end
        end
    end

    vim.fn.setqflist(lint_results)

    if #lint_results > 0 then
        vim.cmd('copen')
    else
        vim.cmd('cclose')
    end
end

function M.setup(opt)
    opt = opt or {}

    if type(opt) ~= 'table' then
        return
    end

    ignored_errors = opt.ignored_errors or ignored_errors
end

return M
