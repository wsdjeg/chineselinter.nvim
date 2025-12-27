local M = {}
local punctuation_en = '[､,:;?!-]'

-- 中文标点符号
local punctuation_cn = '[、，：；。？！‘’“”（）《》『』＂＇／＜＞＝［］｛｝【】]'

-- 中文汉字
local chars_cn = '[\\u4e00-\\u9fff]'

-- 数字
local numbers = '[0-9]'

-- 全角数字
local numbers_cn = '[\\uff10-\\uff19]'

-- 英文字母
local chars_en = '[a-zA-Z]'

local rules = {
	E001 = {
		enable = true,
		regex = chars_cn .. punctuation_en,
		desc = "中文字符后存在英文标点",
	},
}

local function find_errors(line, rule)
	local re = vim.regex(rule.regex)

	local col = re:match_str(line)

	return col
end

function M.check()
	local bufnr = vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local lint_results = {}
	for nr, line in ipairs(lines) do
		for err, rule in pairs(rules) do
			if rule.enable then
				local col = find_errors(line, rule)
				if col then
					table.insert(lint_results, {
						bufnr = bufnr,
						lnum = nr,
						col = col,
						text = rule.desc,
						type = "E",
						nr = err,
					})
				end
			end
		end
	end

	vim.fn.setqflist(lint_results)

	vim.cmd("copen")
end

function M.setup(opt)
	opt = opt or {}

	if type(opt) ~= "table" then
		return
	end

	for _, err in ipairs(opt.ignored_errors) do
		if rules[err] then
			rules[err].enable = false
		end
	end
end

return M
