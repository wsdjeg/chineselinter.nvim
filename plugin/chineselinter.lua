vim.api.nvim_create_user_command("CheckChinese", function(opt)
	require("chineselinter").check()
end, { nargs = "*" })
