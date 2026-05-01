return {
  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    opts = {
      progress = {
        display = {
          progress_icon = { pattern = "dots", period = 1 },
          done_icon = "\u{f00c}",
        },
      },
      notification = {
        window = {
          winblend = 0,
          border = "none",
        },
      },
    },
  },
}
