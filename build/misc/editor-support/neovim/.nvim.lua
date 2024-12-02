local lspconfig = require("lspconfig")

lspconfig.buck2.setup({})
lspconfig.rust_analyzer.setup({
	settings = {
		["rust-analyzer"] = {
			["check.overrideCommand"] = {
				"buck2",
				"run",
				"-v=0",
				"--console=none",
				"third_party//tools/rust-project:bin",
				"--",
				"check",
				"$saved_file",
			},
			["workspace.discoverConfig"] = {
				command = {
					"buck2",
					"run",
					"-v=0",
					"--console=none",
					"third_party//tools/rust-project:bin",
					"--",
					"develop-json",
					"--sysroot-mode=rustc",
					"{arg}",
				},

				progressLabel = "rust-analyzer[buck2]",
				filesToWatch = { "BUCK", "PACKAGE" },
			},
		},
	},
})

vim.filetype.add({
	extension = {
		bxl = "bzl",
	},
	filename = {
		[".buckconfig"] = "dosini",
		["PACKAGE"] = "bzl",
	},
})
