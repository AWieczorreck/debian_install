-- lua/plugins/navigation.lua
-- Navigation Plugins: File Explorer, Fuzzy Finder

return {
  -- File Explorer
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "s1n7ax/nvim-window-picker",
    },
    config = function()
      -- nvim-window-picker Setup
      require("window-picker").setup({
        hint = "floating-big-letter",
        filter_rules = {
          include_current_win = false,
          autoselect_one = true,
          bo = {
            filetype = { "NvimTree", "neo-tree", "notify" },
            buftype = { "terminal", "quickfix" },
          },
        },
      })

      require("nvim-tree").setup({
        view = {
          width = 30,
        },
        renderer = {
          icons = {
            show = {
              file = true,
              folder = true,
              folder_arrow = true,
              git = true,
            },
          },
        },
        filters = {
          dotfiles = false,
        },
        actions = {
          open_file = {
            window_picker = {
              enable = true,
              picker = "default",
              chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
            },
          },
        },
      })
      -- Keymaps
      vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { silent = true })
    end,
  },

  -- FZF (Fuzzy Finder)
  {
    "junegunn/fzf",
    build = "./install --all",
  },
  {
    "junegunn/fzf.vim",
    dependencies = "junegunn/fzf",
    config = function()
      -- Keymaps
      vim.keymap.set("n", "<leader>ff", ":Files<CR>", { silent = true })
      vim.keymap.set("n", "<leader>fg", ":Rg<CR>", { silent = true })
      vim.keymap.set("n", "<leader>fb", ":Buffers<CR>", { silent = true })
      vim.keymap.set("n", "<leader>fh", ":History<CR>", { silent = true })
    end,
  },
  {
    "szw/vim-maximizer",
    config = function()
      vim.keymap.set("n", "<leader>m", ":MaximizerToggle<CR>", { noremap = true, silent = true })
    end,
  },
  {
    "folke/snacks.nvim",
    opts = {
      indent = { enabled = true },
      scope = { enabled = true },
      scroll = { enabled = true },
      statuscolumn = { enabled = true },
      words = { enabled = true },
    },
  },
}
