local system_stylua = '/run/current-system/sw/bin/stylua'
local use_system_stylua = vim.fn.executable(system_stylua) == 1

return {
  {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    dependencies = {
      'williamboman/mason.nvim',
    },
    opts = {
      ensure_installed = use_system_stylua
        and {}
        or { 'stylua' },

      auto_update = false,
      run_on_start = true,
    },
  },

  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    opts = {
      notify_on_error = false,

      formatters_by_ft = {
        lua = { 'stylua' },
      },

      formatters = {
        stylua = {
          command = use_system_stylua
            and system_stylua
            or 'stylua',
        },
      },
    },
  },
}
