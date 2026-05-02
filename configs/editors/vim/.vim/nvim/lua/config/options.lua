-- lua/config/options.lua

local opt = vim.opt
local g = vim.g

-- basic settings
opt.number = true                  -- show linenumber
opt.relativenumber = true          -- relative linenumber
opt.mouse = "a"                    -- mouse support ;-)
opt.clipboard = "unnamedplus"      -- use system clipboard

-- indentation
opt.tabstop = 2                    -- tab = 2 spaces
opt.shiftwidth = 2                 -- automatic indent = 2 spaces
opt.expandtab = true               -- convert tab to spaces
opt.autoindent = true              -- auto indent

-- search behavior
opt.ignorecase = true              -- ignore case
opt.smartcase = true               -- use smart case
opt.incsearch = true               -- incremental search

-- ui
opt.termguicolors = true           -- true color support
opt.cursorline = true              -- highlight current line
opt.signcolumn = "yes"             -- always show sign column
opt.splitbelow = true              -- open new horizontel split window below current window
opt.splitright = true              -- open new vertics split window right of current window
opt.wrap = false                   -- no text wrap
opt.splitkeep = "screen"           -- keep window proposition at splitting

-- performance
opt.updatetime = 200               -- updatespeed in ms
opt.timeoutlen = 300               -- keymap timeout
opt.ttimeoutlen = 100              -- terminal timeout

-- other
opt.completeopt = { "menu", "menuone", "noselect" }  -- completion optionen
opt.fileencoding = "utf-8"         -- use utf-8 encoding
opt.showmode = false               -- don't show mode in statusline

-- leader key
g.mapleader = " "
g.maplocalleader = " "
