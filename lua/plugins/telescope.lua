return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    event = "LspAttach",
    keys = {
      {
        "<leader>sg",
        function() require("telescope.builtin").live_grep() end,
        desc = "Search by grep (project)",
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function() return vim.fn.executable("make") == 1 end,
      },
      "nvim-telescope/telescope-ui-select.nvim",
    },
    config = function()
      local telescope = require("telescope")
      local themes = require("telescope.themes")

      local rounded_borderchars = {
        prompt = { "─", "│", " ", "│", "╭", "╮", "│", "│" },
        results = { "─", "│", "─", "│", "├", "┤", "╯", "╰" },
        preview = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
      }

      telescope.setup({
        defaults = {
          layout_strategy = "horizontal",
          layout_config = { prompt_position = "top" },
          sorting_strategy = "ascending",
          path_display = { "truncate" },
          borderchars = {
            "─", "│", "─", "│", "╭", "╮", "╯", "╰",
          },
        },
        extensions = {
          ["ui-select"] = {
            themes.get_dropdown({
              layout_strategy = "center",
              layout_config = { width = 60, height = 15 },
              borderchars = rounded_borderchars,
            }),
          },
        },
      })

      pcall(telescope.load_extension, "fzf")
      pcall(telescope.load_extension, "ui-select")

      local function apply_telescope_hl()
        local groups = {
          "TelescopeNormal",
          "TelescopeBorder",
          "TelescopePromptNormal",
          "TelescopePromptBorder",
          "TelescopePromptTitle",
          "TelescopeResultsNormal",
          "TelescopeResultsBorder",
          "TelescopeResultsTitle",
          "TelescopePreviewNormal",
          "TelescopePreviewBorder",
          "TelescopePreviewTitle",
        }
        for _, g in ipairs(groups) do
          local hl = vim.api.nvim_get_hl(0, { name = g, link = false })
          vim.api.nvim_set_hl(0, g, vim.tbl_extend("force", hl, { bg = "NONE" }))
        end
      end
      apply_telescope_hl()
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("user-telescope-hl", { clear = true }),
        callback = apply_telescope_hl,
      })
    end,
  },
}
