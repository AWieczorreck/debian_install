-- lua/plugins/ai.lua
-- AI Plugins: CopilotChat (no inline suggestions)

return {
	-- GitHub Copilot (dependency for CopilotChat)
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		config = function()
			require("copilot").setup({
				suggestion = {
					enabled = false,
				},
				panel = {
					enabled = false,
				},
				server_opts_overrides = {
					settings = {
						telemetry = {
							telemetryLevel = "off",
						},
					},
				},
			})
		end,
	},

	-- CopilotChat (Chat-Interface for Copilot)
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		branch = "main",
		dependencies = {
			{ "zbirenbaum/copilot.lua" },
			{ "nvim-lua/plenary.nvim" },
		},
		build = "make tiktoken",
		config = function()
			require("CopilotChat").setup({
				prompts = {
					GenerateCode = {
						prompt = "Schreibe vollständigen, produktionsreifen Code",
						system_prompt = [[
              You are an API programming assistant.
              When asked for your name, you must respond with "GitHub Copilot".
              Follow the user's requirements carefully & to the letter.
              Follow Microsoft content policies.
              Avoid content the violates copyrights.
              If you are asked to generate content that is harmful, hateful, racist, sexist,
              lewd, violent or completely irrelevant to software engineering, only respond
              with "Sorry, I can't assist with that.".
              Keep your answers short and impersonal.
              The user works in an IDE called Neovim which has a concept for editors with
              open files, integrated unit test support, an output pane that shows the output
              of running the code as well as an integrated terminal.
              The user is working on a Linux machine. Please respond with system specific
              commands if applicable.
              Your task is to modify the provided code according to the user's request.
              Follow these instructions precisely:

              1. Return *ONLY* the complete modified code.
              2. *DO NOT* include any explanations, comments or line numbers in your response.
              3. Ensure the returned code is complete and can be directly used as a replacement for the original code.
              4. Preserve the original structure, indentation and formatting of the code as much as possible.
              5. *DO NOT* omit any parts of the code, even if they are unchanged.
              6. Maintain the *SAME INDENTATION* in the returned code as in the source code.
              7. *ONLY* return the new code snippets to be updated, *DO NOT* return the entire file content.
              8. If the response do not fits in a single message, split the response into multiple messages.
              9. Directly above every returned code snippet, add `[file:<file_name>](<file_path) line:
              <start_line>-<end_line>`.
              ]],
						description = "Code generieren",
						mapping = "<leader>ccgen",
					},
				},
				window = {
					layout = "vertical",
					width = 80,
					height = 20,
					border = "rounded",
					title = "🤖 AI Assistant",
					zindex = 100,
				},
				headers = {
					user = "👤 You",
					assistant = "🤖 Copilot",
					tool = "🔧 Tool",
				},
				language = "German",
				separator = "━━",
				auto_fold = true,
				debug = false,
				trusted_tools = true,
				model = "claude-haiku-4.5",
				temperature = 0.1,
				show_help = true,
				show_folds = true,
				highlight_selection = true,
				highlight_insertion = true,
				highlight_headers = true,
				auto_follow_cursor = true,
				auto_insert_mode = true,
				clear_chat_on_new_prompt = false,
				question_header = "## User ",
				answer_header = "## Copilot ",
				error_header = "## Error ",
			})

			-- window settings for CopilotChat
			local function setup_copilot_window()
				local current_window = vim.api.nvim_get_current_win()
				vim.api.nvim_win_set_option(current_window, "winfixwidth", true)
				vim.api.nvim_win_set_option(current_window, "winfixheight", true)
			end

			-- use the settings if CopilotChat is open
			vim.api.nvim_create_autocmd("BufEnter", {
				pattern = "copilot-chat",
				callback = setup_copilot_window,
			})

			-- Keymaps for CopilotChat
			-- vim.keymap.set("n", "<leader>cc", ":CopilotChat<CR>", { noremap = true, silent = true })
			-- vim.keymap.set("n", "<leader>cq", ":CopilotChatOpen<CR>", { noremap = true, silent = true })
			-- vim.keymap.set("n", "<leader>ce", ":CopilotChatExplain<CR>", { noremap = true, silent = true })
			-- vim.keymap.set("n", "<leader>cr", ":CopilotChatReview<CR>", { noremap = true, silent = true })
			-- vim.keymap.set("n", "<leader>cf", ":CopilotChatFix<CR>", { noremap = true, silent = true })
			-- vim.keymap.set("n", "<leader>ct", ":CopilotChatTests<CR>", { noremap = true, silent = true })
			-- vim.keymap.set("n", "<leader>cg", ":CopilotChatGenerateCode<CR>", { noremap = true, silent = true })
			-- vim.keymap.set("v", "<leader>cc", ":CopilotChat<CR>", { noremap = true, silent = true })
			-- vim.keymap.set("v", "<leader>ce", ":CopilotChatExplain<CR>", { noremap = true, silent = true })
			-- vim.keymap.set("v", "<leader>cr", ":CopilotChatReview<CR>", { noremap = true, silent = true })
			-- vim.keymap.set("v", "<leader>cf", ":CopilotChatFix<CR>", { noremap = true, silent = true })
			-- vim.keymap.set("v", "<leader>cg", ":CopilotChatGenerateCode<CR>", { noremap = true, silent = true })
		end,
	},
}
