return {
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      'rafamadriz/friendly-snippets',
    },
    config = function()
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'

      require('luasnip.loaders.from_vscode').lazy_load()

      local kind_icons = {
        Text = '\u{ea93}',
        Method = '\u{ea8c}',
        Function = '\u{ea8c}',
        Constructor = '\u{ea8c}',
        Field = '\u{eb5f}',
        Variable = '\u{ea88}',
        Class = '\u{eb5b}',
        Interface = '\u{eb61}',
        Module = '\u{ea8b}',
        Property = '\u{eb65}',
        Unit = '\u{ea96}',
        Value = '\u{ea95}',
        Enum = '\u{ea95}',
        Keyword = '\u{eb62}',
        Snippet = '\u{eb66}',
        Color = '\u{eb5c}',
        File = '\u{ea7b}',
        Reference = '\u{ea94}',
        Folder = '\u{ea83}',
        EnumMember = '\u{eb5e}',
        Constant = '\u{eb5d}',
        Struct = '\u{ea91}',
        Event = '\u{ea86}',
        Operator = '\u{eb64}',
        TypeParameter = '\u{ea92}',
      }

      local source_labels = {
        nvim_lsp = '[LSP]',
        luasnip = '[Snip]',
        buffer = '[Buf]',
        path = '[Path]',
      }

      local kind_groups = {
        'Text',
        'Method',
        'Function',
        'Constructor',
        'Field',
        'Variable',
        'Class',
        'Interface',
        'Module',
        'Property',
        'Unit',
        'Value',
        'Enum',
        'Keyword',
        'Snippet',
        'Color',
        'File',
        'Reference',
        'Folder',
        'EnumMember',
        'Constant',
        'Struct',
        'Event',
        'Operator',
        'TypeParameter',
      }

      local function apply_hl()
        vim.api.nvim_set_hl(0, 'CmpNormal', { link = 'Normal' })
        vim.api.nvim_set_hl(0, 'CmpBorder', { fg = '#ffffff', bg = 'NONE' })
        vim.api.nvim_set_hl(0, 'CmpSel', { bg = '#2f4f4f' })

        for _, kind in ipairs(kind_groups) do
          local group = 'CmpItemKind' .. kind
          local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
          vim.api.nvim_set_hl(0, group, { fg = hl.fg })
        end
        local default_hl = vim.api.nvim_get_hl(0, { name = 'CmpItemKind', link = false })
        vim.api.nvim_set_hl(0, 'CmpItemKind', { fg = default_hl.fg })
      end
      apply_hl()
      vim.api.nvim_create_autocmd('ColorScheme', {
        group = vim.api.nvim_create_augroup('user-cmp-hl', { clear = true }),
        callback = apply_hl,
      })

      local PAIRS = { ['{'] = '}', ['['] = ']', ['('] = ')' }

      local function smart_pair_split()
        local pos = vim.api.nvim_win_get_cursor(0)
        local row, col = pos[1], pos[2]
        local line = vim.api.nvim_get_current_line()
        local before = line:sub(col, col)
        local after = line:sub(col + 1, col + 1)
        if PAIRS[before] ~= after then
          return false
        end

        local indent = line:match '^[ \t]*' or ''
        local extra = vim.bo.expandtab and string.rep(' ', vim.bo.shiftwidth > 0 and vim.bo.shiftwidth or vim.bo.tabstop) or '\t'
        local left = line:sub(1, col)
        local right = line:sub(col + 1)
        vim.api.nvim_buf_set_lines(0, row - 1, row, false, {
          left,
          indent .. extra,
          indent .. right,
        })
        vim.api.nvim_win_set_cursor(0, { row + 1, #indent + #extra })
        return true
      end

      cmp.setup {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        window = {
          completion = {
            border = 'rounded',
            winhighlight = 'Normal:CmpNormal,FloatBorder:CmpBorder,CursorLine:CmpSel,Search:None',
            scrollbar = true,
            side_padding = 1,
          },
          documentation = {
            border = 'rounded',
            winhighlight = 'Normal:CmpNormal,FloatBorder:CmpBorder,Search:None',
          },
        },
        mapping = cmp.mapping.preset.insert {
          ['<Down>'] = cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Select },
          ['<Up>'] = cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Select },
          ['<C-n>'] = cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Select },
          ['<C-p>'] = cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Select },
          ['<C-d>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.confirm { select = true }
            elseif smart_pair_split() then
              -- handled
            else
              fallback()
            end
          end, { 'i', 's' }),
        },
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'path' },
        }, {
          { name = 'buffer' },
        }),
        formatting = {
          fields = { 'kind', 'abbr', 'menu' },
          format = function(entry, vim_item)
            local icon = kind_icons[vim_item.kind] or ''
            vim_item.kind = string.format(' %s  %s', icon, vim_item.kind or '')
            vim_item.menu = source_labels[entry.source.name] or ''
            return vim_item
          end,
        },
        experimental = {
          ghost_text = false,
        },
      }
    end,
  },
}
