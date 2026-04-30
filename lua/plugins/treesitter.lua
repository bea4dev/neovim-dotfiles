return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "TSUpdate", "TSInstall", "TSInstallInfo", "TSUpdateSync" },
    main = "nvim-treesitter.config",
    opts = {
      ensure_installed = {
        "lua",
        "luadoc",
        "vim",
        "vimdoc",
        "query",
        "bash",
        "markdown",
        "markdown_inline",
        "json",
        "yaml",
        "toml",
      },
      auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      indent = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-Space>",
          node_incremental = "<C-Space>",
          scope_incremental = false,
          node_decremental = "<BS>",
        },
      },
    },
  },
}
