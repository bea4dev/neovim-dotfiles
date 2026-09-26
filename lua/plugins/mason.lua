local system_lua_ls = '/run/current-system/sw/bin/lua-language-server'

local use_system_lua_ls = vim.fn.executable(system_lua_ls) == 1

return {
  {
    'williamboman/mason.nvim',
    cmd = 'Mason',
    build = ':MasonUpdate',
    opts = {
      PATH = 'append',
      ui = {
        border = 'rounded',
        icons = {
          package_installed = '✓',
          package_pending = '➜',
          package_uninstalled = '✗',
        },
      },
    },
  },

  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = {
      'williamboman/mason.nvim',
      'neovim/nvim-lspconfig',
      'hrsh7th/cmp-nvim-lsp',
    },
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
      ensure_installed = use_system_lua_ls
        and {}
        or { 'lua_ls' },
    
      automatic_enable = true,
    },
    config = function(_, opts)
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local ok, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
      if ok then
        capabilities = vim.tbl_deep_extend('force', capabilities, cmp_nvim_lsp.default_capabilities())
      end

      vim.lsp.config('*', {
        capabilities = capabilities,
      })

      vim.lsp.config('lua_ls', {
        cmd = use_system_lua_ls
          and { system_lua_ls }
          or { 'lua-language-server' },
      
        settings = {
          Lua = {
            runtime = { version = 'LuaJIT' },
            workspace = {
              checkThirdParty = false,
              library = vim.api.nvim_get_runtime_file('', true),
            },
            diagnostics = { globals = { 'vim' } },
            telemetry = { enable = false },
          },
        },
      })

      require('mason-lspconfig').setup(opts)

      if use_system_lua_ls then
        vim.lsp.enable('lua_ls')
      end

      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('user-lsp-attach', { clear = true }),
        callback = function(ev)
          local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, desc = desc })
          end
          -- LSP locations via Telescope, matching the old nvim_old behavior.
          map('n', 'gd', function()
            require('telescope.builtin').lsp_definitions()
          end, 'Go to definition')
          map('n', 'gD', vim.lsp.buf.declaration, 'Go to declaration')
          map('n', 'gr', function()
            require('telescope.builtin').lsp_references()
          end, 'References')
          map('n', 'gi', function()
            require('telescope.builtin').lsp_implementations()
          end, 'Go to implementation')
          map('n', 'gI', function()
            require('telescope.builtin').lsp_implementations()
          end, 'Go to implementation')
          map('n', '<leader>D', function()
            require('telescope.builtin').lsp_type_definitions()
          end, 'Type definition')
          map('n', '<leader>ds', function()
            require('telescope.builtin').lsp_document_symbols()
          end, 'Document symbols')
          map('n', '<leader>ws', function()
            require('telescope.builtin').lsp_dynamic_workspace_symbols()
          end, 'Workspace symbols')
          map('n', 'K', vim.lsp.buf.hover, 'Hover')
          map('n', '<leader>rn', vim.lsp.buf.rename, 'Rename')
          map('n', '<leader>ca', vim.lsp.buf.code_action, 'Code action')
          map('n', '[d', function()
            vim.diagnostic.jump { count = -1 }
          end, 'Previous diagnostic')
          map('n', ']d', function()
            vim.diagnostic.jump { count = 1 }
          end, 'Next diagnostic')

          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if client and client:supports_method 'textDocument/inlayHint' then
            vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
          end

          if client and client:supports_method 'textDocument/documentHighlight' then
            local hl_group = vim.api.nvim_create_augroup('user-lsp-doc-highlight-' .. ev.buf, { clear = true })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              group = hl_group,
              buffer = ev.buf,
              callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              group = hl_group,
              buffer = ev.buf,
              callback = vim.lsp.buf.clear_references,
            })
            vim.api.nvim_create_autocmd('LspDetach', {
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
