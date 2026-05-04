return {
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    opts = {
      ui = {
        border = "rounded",
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    },
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
      "hrsh7th/cmp-nvim-lsp",
    },
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      ensure_installed = {
        "lua_ls",
      },
      automatic_enable = true,
    },
    config = function(_, opts)
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
      if ok then
        capabilities = vim.tbl_deep_extend("force", capabilities, cmp_nvim_lsp.default_capabilities())
      end

      vim.lsp.config("*", {
        capabilities = capabilities,
      })

      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            workspace = {
              checkThirdParty = false,
              library = vim.api.nvim_get_runtime_file("", true),
            },
            diagnostics = { globals = { "vim" } },
            telemetry = { enable = false },
          },
        },
      })

      require("mason-lspconfig").setup(opts)

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("user-lsp-attach", { clear = true }),
        callback = function(ev)
          local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, desc = desc })
          end
          map("n", "gd", vim.lsp.buf.definition, "Go to definition")
          map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
          map("n", "gr", vim.lsp.buf.references, "References")
          map("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
          map("n", "K", vim.lsp.buf.hover, "Hover")
          map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
          map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
          map("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, "Previous diagnostic")
          map("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end, "Next diagnostic")

          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if client and client:supports_method("textDocument/inlayHint") then
            vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
          end

          if client and client:supports_method("textDocument/documentHighlight") then
            local hl_group = vim.api.nvim_create_augroup(
              "user-lsp-doc-highlight-" .. ev.buf, { clear = true })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              group = hl_group,
              buffer = ev.buf,
              callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              group = hl_group,
              buffer = ev.buf,
              callback = vim.lsp.buf.clear_references,
            })
            vim.api.nvim_create_autocmd("LspDetach", {
              group = hl_group,
              buffer = ev.buf,
              callback = function(detach)
                if detach.data.client_id == client.id then
                  vim.lsp.buf.clear_references()
                  pcall(vim.api.nvim_del_augroup_by_id, hl_group)
                end
              end,
            })
          end
        end,
      })
    end,
  },
}
