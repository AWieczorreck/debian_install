-- lua/plugins/git.lua
-- Git Integration

return {
  -- Git Integration
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        current_line_blame_opts = {
          delay = 100,
        },
      })
      vim.keymap.set("n", "<leader>gb", ":Gitsigns toggle_current_line_blame<CR>", { noremap = true, silent = true })
    end,
  },
}
