-- lua/plugins/lsp.lua
-- LSP Configuration

return {
  {
    'b0o/SchemaStore.nvim',
    lazy = true,
    version = false,
  },
  {
    "evanleck/vim-svelte",
    ft = { "svelte" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      { "williamboman/mason.nvim", config = true },
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
      "b0o/SchemaStore.nvim"
    },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Python Language Server
      vim.lsp.config("pyright", {
        cmd = { "pyright-langserver", "--stdio" },
        capabilities = capabilities,
        filetypes = { "python", "py", "py3" },
      })

      -- Lua Language Server
      vim.lsp.config("lua_ls", {
        cmd = { "lua-language-server" },
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" },
            },
          },
        },
      })

      -- Docker LS
      vim.lsp.config("dockerls", {
        cmd = { "docker-langserver", "--stdio" },
        capabilities = capabilities,
        filetypes = { "dockerfile" },
      })

      -- Go Language Server (gopls)
      vim.lsp.config("gopls", {
        cmd = { "gopls" },
        capabilities = capabilities,
        filetypes = { "go", "gomod" },
        settings = {
          gopls = {
            analyses = {
              unusedparams = true,
            },
            staticcheck = true,
            gofumpt = true,
          },
        },
      })

      -- Svelte Language Server
      vim.lsp.config("svelte", {
        cmd = { "svelteserver", "--stdio" },
        capabilities = capabilities,
        filetypes = { "svelte" },
        root_markers = { "package.json", "svelte.config.js" },
      })

      -- Bash Language Server
      vim.lsp.config("bashls", {
        cmd = { "bash-language-server", "start" },
        capabilities = capabilities,
        filetypes = { "sh" }
      })

      -- Yaml Language Server
      vim.lsp.config("yamlls", {
        cmd = { "yaml-language-server", "--stdio" },
        capabilities = capabilities,
        filetypes = { "yaml", "yml" },
        settings = {
          yaml = {
            schemaStore = {
              enable = true,
              url = "https://www.schemastore.org/json/",
            },
            schemas = require('schemastore').yaml.schemas(),
            validate = true,
            completion = true,
            hover = true,
            -- Optional: Indentation-Validierung
            indentation = 2,
          },
        },
      })

      -- start all LSP
      vim.lsp.enable("pyright")
      vim.lsp.enable("lua_ls")
      vim.lsp.enable("gopls")
      vim.lsp.enable("dockerls")
      vim.lsp.enable("svelte")
      vim.lsp.enable("bashls")
      vim.lsp.enable("yamlls")

      -- Keymaps
      vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, { noremap = true })
      vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, { noremap = true })
      vim.keymap.set("n", "<leader>gh", vim.lsp.buf.hover, { noremap = true })
      vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { noremap = true })

      -- kube-linter für Kubernetes YAML Dateien
      vim.keymap.set("n", "<leader>kl", function()
        local file = vim.fn.expand("%:p")
        local filetype = vim.bo.filetype

        -- Prüfe ob es eine Kubernetes Datei ist
        if filetype ~= "yaml" and filetype ~= "yml" then
          vim.notify("kube-linter: Nur für YAML Dateien", vim.log.levels.WARN)
          return
        end

        -- Führe kube-linter aus
        local cmd = "kube-linter lint " .. file .. " 2>&1"
        local handle = io.popen(cmd)
        local result = handle:read("*a")
        handle:close()

        -- Prüfe auf Error count
        local error_count = result:match("Error: found (%d+)")

        if not error_count or tonumber(error_count) == 0 then
          vim.notify("kube-linter: Keine Fehler gefunden! ✓", vim.log.levels.INFO)
          return
        end

        -- Parse Output und erstelle Diagnostics
        local diagnostics = {}
        local lines = vim.split(result, "\n")

        for i, line in ipairs(lines) do
          -- Suche nach Zeilen die den Dateinamen enthalten und ein ) haben
          if line:find(vim.fn.expand("%:t")) and line:find("%)") then
            -- Extrahiere die Fehlermeldung nach ") "
            local message = line:match("%)%s+(.+)$")

            if message then
              -- Entferne newlines/umbrüche
              message = message:gsub("\n", " ")

              table.insert(diagnostics, {
                lnum = 0,
                col = 0,
                end_lnum = 0,
                end_col = 100,
                severity = vim.diagnostic.severity.WARN,
                message = message,
                source = "kube-linter",
              })
            end
          end
        end

        -- Setze die Diagnostics
        local buf = vim.api.nvim_get_current_buf()
        vim.diagnostic.set(vim.api.nvim_create_namespace("kube-linter"), buf, diagnostics)

        if #diagnostics == 0 then
          vim.notify("kube-linter: Fehler beim Parsen (gefunden: " .. error_count .. ")", vim.log.levels.WARN)
        else
          vim.notify("kube-linter: " .. #diagnostics .. " Fehler gefunden", vim.log.levels.INFO)
          -- Öffne Trouble automatisch
          vim.cmd("Trouble diagnostics toggle filter.buf=0")
        end
      end, { noremap = true, silent = true, desc = "Run kube-linter" })

      -- Preview Window global aktivieren
      vim.opt.completeopt = { "menu", "menuone", "noselect", "preview" }
    end,
  },

  -- Autocompletion
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-nvim-lsp",
      "L3MON4D3/LuaSnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = {
          autocomplete = false,
          completeopt = "menu,menuone,noselect,preview",
        },
        window = {
          completion = cmp.config.window.bordered({
            border = "rounded",
            side_padding = 1,
            max_width = 80,
            max_height = 15,
            zindex = 1001,
          }),
          documentation = cmp.config.window.bordered({
            border = "rounded",
            side_padding = 1,
            max_width = 80,
            max_height = 20,
            zindex = 1000,
          }),
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-d>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<C-Space>"] = cmp.mapping.complete(),
          -- Toggle Documentation Window
          ["<C-h>"] = cmp.mapping(function()
            if cmp.visible_docs() then
              cmp.close_docs()
            else
              cmp.open_docs()
            end
          end),
          -- dropdown navigation up/down
          ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp", priority = 100 },
          { name = "luasnip",  priority = 90 },
          { name = "buffer",   priority = 80 },
          { name = "path",     priority = 70 },
        }),
      })
    end,
  },
}
