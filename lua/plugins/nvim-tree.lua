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
    opts = {
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
          glyphs = {
            default = "",
            symlink = "",
            bookmark = "󰆤",
            modified = "●",
            folder = {
              arrow_closed = "",
              arrow_open = "",
              default = "",
              open = "",
              empty = "",
              empty_open = "",
              symlink = "",
              symlink_open = "",
            },
            git = {
              unstaged = "",
              staged = "",
              unmerged = "",
              renamed = "➜",
              untracked = "",
              deleted = "",
              ignored = "◌",
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
        enable = false,
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
    },
  },
}
