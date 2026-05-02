-- lua/config/lazy.lua
-- lazy.nvim Plugin-Manager Setup

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- lazy.nvim setup
require("lazy").setup("plugins", {
  defaults = {
    lazy = false,
    version = false,
  },
  install = {
    missing = true,
    colorscheme = { "tokyonight", "habamax" },
  },
  checker = {
    enabled = true,
    notify = false,
  },
  change_detection = {
    enabled = true,
    notify = false,
  },
  performance = {
    cache = {
      enabled = true,
    },
    reset_packpath = true,
    rtp = {
      reset = true,
      paths = {},
      disabled_plugins = {
        "2html_plugin",
        "bugreport",
        "getscript",
        "gzip",
        "logiPat",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "rrhelper",
        "spellfile",
        "tarPlugin",
        "tohtml",
        "tutor",
        "vimball",
        "zipPlugin",
      },
    },
  },
})
