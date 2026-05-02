-- lua/plugins/mason-tools.lua
-- Mason Tools: Formatter, Linter, DAP Adapters, etc.

return {
  -- Mason Tool Installer
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = "williamboman/mason.nvim",
    config = function()
      require("mason-tool-installer").setup({
        ensure_installed = {
          -- Formatters
          "prettier",
          "xmlformatter",
          "shfmt",
          "clang-format",

          -- Linters
          "kube-linter",
          "ruff",
          "commitlint",

          -- Debugger
          "delve",

          -- Language server
          "bash-language-server",
          "docker-language-server",
          "gopls",
          "lua-language-server",
          "pyright",
          "svelte-language-server",
          "yaml-language-server",

          -- Other Tools
          "glow",
          "uv",
        },
        auto_update = true,
        run_on_start = true,
      })
    end,
  },
}


