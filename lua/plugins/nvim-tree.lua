return {
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    cmd = { "NvimTreeToggle", "NvimTreeFocus", "NvimTreeFindFile", "Ex" },
    init = function()
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
      vim.api.nvim_create_user_command("Ex", "NvimTreeToggle", {})
    end,
    opts = function()
      return {
      on_attach = require("util.nvim_tree_actions").on_attach,
      sort = { sorter = "case_sensitive" },
      view = {
        width = 35,
        side = "left",
        signcolumn = "yes",
      },
      renderer = {
        group_empty = true,
        highlight_git = true,
        indent_markers = {
          enable = true,
          icons = {
            corner = "└",
            edge = "│",
            item = "│",
            bottom = "─",
            none = " ",
          },
        },
        icons = {
          show = {
            file = true,
            folder = true,
            folder_arrow = true,
            git = true,
          },
          diagnostics_placement = "before",
          glyphs = {
            default = "\u{f15b}",
            symlink = "\u{f481}",
            bookmark = "\u{f01a4}",
            modified = "●",
            folder = {
              arrow_closed = "\u{f0da}",
              arrow_open = "\u{f0d7}",
              default = "\u{f07b}",
              open = "\u{f07c}",
              empty = "\u{f114}",
              empty_open = "\u{f115}",
              symlink = "\u{f481}",
              symlink_open = "\u{f482}",
            },
            git = {
              unstaged = "!",
              staged = "\u{f00c}",
              unmerged = "\u{f0c5}",
              renamed = "»",
              untracked = "?",
              deleted = "\u{f00d}",
              ignored = "\u{25cc}",
            },
          },
        },
      },
      git = {
        enable = true,
        ignore = false,
        timeout = 400,
      },
      diagnostics = {
        enable = true,
        show_on_dirs = true,
        show_on_open_dirs = true,
        debounce_delay = 200,
        severity = {
          min = vim.diagnostic.severity.HINT,
          max = vim.diagnostic.severity.ERROR,
        },
        icons = {
          error   = "\u{f0159} ",
          warning = "\u{f002a} ",
          info    = "\u{f02fd} ",
          hint    = "\u{f0336} ",
        },
      },
      filters = {
        dotfiles = false,
        custom = { "^.git$" },
      },
      actions = {
        open_file = {
          quit_on_open = false,
          window_picker = { enable = true },
        },
      },
      update_focused_file = {
        enable = true,
        update_root = false,
      },
      }
    end,
  },
}
