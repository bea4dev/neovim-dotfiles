local map = vim.keymap.set

map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

map("v", "<", "<gv", { desc = "Indent left and reselect" })
map("v", ">", ">gv", { desc = "Indent right and reselect" })

local function apply_hover_hl()
  vim.api.nvim_set_hl(0, "HoverNormal", { bg = "NONE" })
  vim.api.nvim_set_hl(0, "HoverBorder", { bg = "NONE" })
end
apply_hover_hl()
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("user-hover-hl", { clear = true }),
  callback = apply_hover_hl,
})

local severity_label = { "ERROR", "WARN", "INFO", "HINT" }

local function open_hover_float(lines)
  if not lines or #lines == 0 then return end
  local buf, win = vim.lsp.util.open_floating_preview(lines, "markdown", {
    border = "rounded",
    focusable = true,
    wrap = true,
    max_width = math.min(100, math.floor(vim.o.columns * 0.8)),
    max_height = math.floor(vim.o.lines * 0.6),
  })
  vim.wo[win].winhighlight = "Normal:HoverNormal,FloatBorder:HoverBorder"
  vim.api.nvim_set_current_win(win)
  vim.keymap.set("n", "<Esc>", "<cmd>close<CR>",
    { buffer = buf, nowait = true, silent = true })
end

local function diagnostic_lines_at_cursor(bufnr)
  local pos = vim.api.nvim_win_get_cursor(0)
  local lnum, col = pos[1] - 1, pos[2]
  local line_diags = vim.diagnostic.get(bufnr, { lnum = lnum })
  local at_cursor = {}
  for _, d in ipairs(line_diags) do
    local start_col = d.col or 0
    local end_col = d.end_col or start_col
    if col >= start_col and col <= end_col then
      table.insert(at_cursor, d)
    end
  end
  if #at_cursor == 0 then at_cursor = line_diags end

  local lines = {}
  for _, d in ipairs(at_cursor) do
    local sev = severity_label[d.severity] or "INFO"
    local src = d.source and (" (" .. d.source .. ")") or ""
    for i, msg_line in ipairs(vim.split(d.message, "\n", { plain = true })) do
      if i == 1 then
        table.insert(lines, ("**[%s]%s** %s"):format(sev, src, msg_line))
      else
        table.insert(lines, msg_line)
      end
    end
  end
  return lines
end

local function lsp_hover_focused()
  local bufnr = vim.api.nvim_get_current_buf()
  local diag_lines = diagnostic_lines_at_cursor(bufnr)

  local clients = vim.lsp.get_clients({ bufnr = bufnr, method = "textDocument/hover" })
  if #clients == 0 then
    open_hover_float(diag_lines)
    return
  end

  local params = vim.lsp.util.make_position_params(0, clients[1].offset_encoding or "utf-16")
  vim.lsp.buf_request_all(bufnr, "textDocument/hover", params, function(results)
    local hover_lines = {}
    for _, r in pairs(results or {}) do
      if r.result and r.result.contents then
        local md = vim.lsp.util.convert_input_to_markdown_lines(r.result.contents)
        if md and #md > 0 then
          if #hover_lines > 0 then table.insert(hover_lines, "---") end
          vim.list_extend(hover_lines, md)
        end
      end
    end

    local lines = {}
    vim.list_extend(lines, diag_lines)
    if #diag_lines > 0 and #hover_lines > 0 then
      table.insert(lines, "---")
    end
    vim.list_extend(lines, hover_lines)

    vim.schedule(function() open_hover_float(lines) end)
  end)
end

map("n", "P", lsp_hover_focused, { desc = "LSP hover (focus)" })

map({ "n", "v" }, "<C-q>", function()
  vim.lsp.buf.code_action()
end, { desc = "LSP code action" })

map({ "n", "v" }, "<leader>f", function()
  local ok, conform = pcall(require, "conform")
  if ok then
    conform.format({ async = true, lsp_format = "fallback" })
  else
    vim.lsp.buf.format({ async = true })
  end
end, { desc = "Format buffer" })

map("n", "<leader>fr", function()
  require("util.replace_panel").open({ mode = "file" })
end, { desc = "File Replace (regex)" })

map("n", "<leader>er", function()
  require("util.replace_panel").open({ mode = "project" })
end, { desc = "Entire Replace (project, regex)" })
