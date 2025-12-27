vim.api.nvim_create_user_command("ChineseLinter", function(opt)
	require("ChineseLinter").check()
end, { nargs = "*" })
