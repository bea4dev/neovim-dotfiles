-- netrwの無効化
vim.api.nvim_set_var('loaded_netrw', 1)
vim.api.nvim_set_var('loaded_netrwPlugin', 1)

require('nvim-tree').setup {
  view = {
    width = '20%',
    signcolumn = 'no',
  },

  renderer = {
    highlight_git = true,
    highlight_opened_files = 'name',
    icons = {
      glyphs = {
        git = {
          unstaged = '!',
          renamed = '»',
          untracked = '?',
          deleted = '✘',
          staged = '✓',
          unmerged = '',
          ignored = '◌',
        },
      },
      diagnostics_placement = 'before',
    },
  },

  diagnostics = {
    enable = true,
    show_on_dirs = true, -- フォルダにもエラーステータスを表示
    icons = {
      hint = 'H',
      info = 'I',
      warning = 'W',
      error = 'E',
    },
  },

  actions = {
    expand_all = {
      max_folder_discovery = 100,
      exclude = { '.git', 'target', 'build' },
    },
  },
  on_attach = require('plugins.nvim-tree-actions').on_attach,
}

vim.api.nvim_create_user_command('Ex', function()
  vim.cmd.NvimTreeToggle()
end, {})
