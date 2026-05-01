return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    cmd = { "ToggleTerm", "TermExec" },
    keys = {
      { "<leader>tt", "<cmd>ToggleTerm<CR>", desc = "Toggle terminal" },
      { "<Esc><Esc>", [[<C-\><C-n>]], mode = "t", desc = "Exit terminal mode" },
    },
    opts = {
      direction = "float",
      float_opts = {
        border = "curved",
        winblend = 0,
      },
      highlights = {
        Normal       = { link = "HoverNormal" },
        FloatBorder  = { link = "HoverBorder" },
      },
      shade_terminals = false,
      start_in_insert = true,
      persist_mode = true,
    },
  },
}
