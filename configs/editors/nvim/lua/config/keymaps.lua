-- lua/config/keymaps.lua
-- keymaps

local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- enhanced navigation
keymap("n", "<C-h>", "<C-w>h", opts)  -- jump to left window
keymap("n", "<C-j>", "<C-w>j", opts)  -- jump to bottom 
keymap("n", "<C-k>", "<C-w>k", opts)  -- jump to top window
keymap("n", "<C-l>", "<C-w>l", opts)  -- jump to right window

-- window enlarge/reduce
keymap("n", "<C-Up>", ":resize +2<CR>", opts)
keymap("n", "<C-Down>", ":resize -2<CR>", opts)
keymap("n", "<C-Left>", ":vertical resize -2<CR>", opts)
keymap("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- move lines
keymap("n", "<A-j>", ":m .+1<CR>==", opts)
keymap("n", "<A-k>", ":m .-2<CR>==", opts)
keymap("i", "<A-j>", "<Esc>:m .+1<CR>==gi", opts)
keymap("i", "<A-k>", "<Esc>:m .-2<CR>==gi", opts)
keymap("v", "<A-j>", ":m '>+1<CR>gv=gv", opts)
keymap("v", "<A-k>", ":m '<-2<CR>gv=gv", opts)

-- indent in visual modus
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- better paste support
keymap("v", "p", '"_dP', opts)

-- buffer navigation
keymap("n", "<leader>n", ":bnext<CR>", opts)
keymap("n", "<leader>p", ":bprevious<CR>", opts)
keymap("n", "<leader>d", ":bdelete<CR>", opts)

-- clearing highlights
keymap("n", "<leader>h", ":nohlsearch<CR>", opts)
