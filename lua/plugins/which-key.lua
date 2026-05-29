return {
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {
      preset = 'modern',
      delay = 200,
      win = {
        border = 'rounded',
        wo = {
          winblend = 0,
          winhighlight = 'Normal:HoverNormal,FloatBorder:HoverBorder',
        },
      },
      icons = {
        mappings = true,
      },
      spec = {
        { '<leader>e', group = 'Entire (project)' },
        { '<leader>t', group = 'Toggle / Terminal' },
        { '<leader>s', group = 'Search' },
        { '<leader>r', group = 'Rename / Refactor' },
        { '<leader>c', group = 'Code' },
        { '<leader>h', group = 'Git Hunk' },
      },
    },
    keys = {
      {
        '<leader>?',
        function()
          require('which-key').show { global = false }
        end,
        desc = 'Buffer keymaps (which-key)',
      },
    },
  },
}
