-- lua/plugins/init.lua
-- Plugin-Manager: loads all plugin modules

return vim.iter({
  require("plugins.ui"),
  require("plugins.navigation"),
  require("plugins.editor"),
  require("plugins.lsp"),
  require("plugins.mason-tools"),
  require("plugins.git"),
  require("plugins.ai"),
}):flatten():totable()
