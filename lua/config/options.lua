vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opt = vim.opt

opt.number = true
opt.relativenumber = false
opt.signcolumn = "yes"
opt.cursorline = true

opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4
opt.smartindent = true

opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true

opt.splitright = true
opt.splitbelow = true

opt.termguicolors = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.wrap = false

opt.undofile = true
opt.swapfile = false
opt.backup = false

opt.updatetime = 250
opt.timeoutlen = 300

opt.clipboard = "unnamedplus"
opt.mouse = "a"

if vim.env.WAYLAND_DISPLAY and vim.fn.executable("wl-copy") == 1 then
  vim.g.clipboard = {
    name = "wl-clipboard",
    copy = {
      ["+"] = { "wl-copy" },
      ["*"] = { "wl-copy", "--primary" },
    },
    paste = {
      ["+"] = { "wl-paste", "--no-newline" },
      ["*"] = { "wl-paste", "--no-newline", "--primary" },
    },
    cache_enabled = 1,
  }
end

local function apply_user_hl()
  vim.api.nvim_set_hl(0, "LineNr", { fg = "#b0b0b0" })
  local hint = vim.api.nvim_get_hl(0, { name = "LspInlayHint", link = false })
  vim.api.nvim_set_hl(0, "LspInlayHint", vim.tbl_extend("force", hint, { fg = "#8a90a8", bg = "NONE" }))
end
apply_user_hl()
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("user-hl", { clear = true }),
  callback = apply_user_hl,
})

vim.diagnostic.config({
  virtual_text = true,
  update_in_insert = true,
  severity_sort = true,
})
