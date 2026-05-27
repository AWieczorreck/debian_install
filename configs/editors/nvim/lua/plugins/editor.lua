-- lua/plugins/editor.lua
-- Editor Plugins: Syntax Highlighting, Comments, Auto Pairs

return {
	-- Treesitter (Syntax Highlighting)
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		build = ":TSUpdate",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			vim.schedule(function()
				local ok, ts = pcall(require, "nvim-treesitter.configs")
				if not ok then
					return
				end

				ts.setup({
					ensure_installed = {
						"bash",
                        "c",
						"css",
						"dockerfile",
						"diff",
						"go",
						"html",
						"javascript",
						"json",
						"lua",
						"svelte",
						"markdown",
						"python",
						"typescript",
						"vim",
						"yaml",
					},
					sync_install = false,
					auto_install = true,
					highlight = {
						enable = true,
					},
					indent = {
						enable = true,
					},
				})
			end)
		end,
	},

	-- Comments
	{
		"numToStr/Comment.nvim",
		config = function()
			require("Comment").setup()
		end,
	},

	-- Auto Pairs
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = function()
			require("nvim-autopairs").setup()
		end,
	},

	-- Trouble (Diagnostics & LSP Errors)
	{
		"folke/trouble.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("trouble").setup({
				-- win = {
				--   position = "right",
				--   size = 50,
				-- },
				auto_open = false,
				auto_close = false,
			})

			-- Trouble Keymaps
			vim.keymap.set(
				"n",
				"<leader>xx",
				"<cmd>Trouble diagnostics toggle<CR>",
				{ noremap = true, silent = true, desc = "Trouble Toggle" }
			)
			vim.keymap.set(
				"n",
				"<leader>xw",
				"<cmd>Trouble diagnostics toggle filter.severity=nil<CR>",
				{ noremap = true, silent = true, desc = "Workspace Diagnostics" }
			)
			vim.keymap.set(
				"n",
				"<leader>xd",
				"<cmd>Trouble diagnostics toggle filter.buf=0<CR>",
				{ noremap = true, silent = true, desc = "Document Diagnostics" }
			)
			vim.keymap.set(
				"n",
				"<leader>xn",
				"<cmd>Trouble next<CR>",
				{ noremap = true, silent = true, desc = "Next Trouble" }
			)
			vim.keymap.set(
				"n",
				"<leader>xp",
				"<cmd>Trouble prev<CR>",
				{ noremap = true, silent = true, desc = "Previous Trouble" }
			)
		end,
	},
	-- ToDo-Comments
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {},
	},

	-- Formatter
	{
		"stevearc/conform.nvim",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("conform").setup({
				formatters_by_ft = {
					bash = { "shfmt" },
					c = { "clang-format" },
					docker = { "prettier" },
					go = { "gofmt" },
					javascript = { "prettier" },
					json = { "prettier" },
					lua = { "stylua" },
					markdown = { "prettier" },
					python = { "ruff_format" },
					svelte = { "prettier" },
					typescript = { "prettier" },
				},
			})

			-- Formatter Keymap
			vim.keymap.set("n", "<leader>fm", function()
				require("conform").format({ async = true, lsp_fallback = true })
			end, { noremap = true, silent = true, desc = "Format code" })

			vim.keymap.set("v", "<leader>fm", function()
				require("conform").format({ async = true, lsp_fallback = true })
			end, { noremap = true, silent = true, desc = "Format selected code" })
		end,
	},
}
