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
          ProgrammingPrompt = {
            prompt = "Du bist ein hilfreicher Programmierassistent. Antworte in deutsch",
            description = "Programmierassistent",
          },
        },
        window = {
          layout = "vertical",
          width = 80,         -- Fixed width in columns
          height = 20,        -- Fixed height in rows
          border = "rounded", -- 'single', 'double', 'rounded', 'solid'
          title = "🤖 AI Assistant",
          zindex = 100,       -- Ensure window stays on top
        },
        headers = {
          user = '👤 You',
          assistant = '🤖 Copilot',
          tool = '🔧 Tool',
        },
        separator = '━━',
        auto_fold = true, -- Automatically folds non-assistant messages
        debug = false,
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
        vim.api.nvim_win_set_option(current_window, 'winfixwidth', true)
        vim.api.nvim_win_set_option(current_window, 'winfixheight', true)
      end

      -- use the settings if CopilotChat is open
      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "copilot-chat",
        callback = setup_copilot_window,
      })

      -- Keymaps for CopilotChat
      vim.keymap.set("n", "<leader>cc", ":CopilotChat<CR>", { noremap = true, silent = true })
      vim.keymap.set("n", "<leader>cq", ":CopilotChatOpen<CR>", { noremap = true, silent = true })
      vim.keymap.set("n", "<leader>ce", ":CopilotChatExplain<CR>", { noremap = true, silent = true })
      vim.keymap.set("n", "<leader>cr", ":CopilotChatReview<CR>", { noremap = true, silent = true })
      vim.keymap.set("n", "<leader>cf", ":CopilotChatFix<CR>", { noremap = true, silent = true })
      vim.keymap.set("n", "<leader>ct", ":CopilotChatTests<CR>", { noremap = true, silent = true })
      vim.keymap.set("v", "<leader>cc", ":CopilotChat<CR>", { noremap = true, silent = true })
      vim.keymap.set("v", "<leader>ce", ":CopilotChatExplain<CR>", { noremap = true, silent = true })
      vim.keymap.set("v", "<leader>cr", ":CopilotChatReview<CR>", { noremap = true, silent = true })
      vim.keymap.set("v", "<leader>cf", ":CopilotChatFix<CR>", { noremap = true, silent = true })
    end,
  },
}
