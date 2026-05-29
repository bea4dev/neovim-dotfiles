vim.filetype.add {
  extension = {
    tyml = 'tyml',
  },
}

local function find_binary()
  local candidates = {
    vim.fn.expand '~/Documents/development/tyml/target/debug/tyml-lsp-server',
    vim.fn.exepath 'tyml-lsp-server',
  }
  for _, p in ipairs(candidates) do
    if p and p ~= '' and vim.fn.executable(p) == 1 then
      return p
    end
  end
  return nil
end

local notified_missing = false

local function start_tyml(bufnr, force)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  if not force then
    for _, c in ipairs(vim.lsp.get_clients { bufnr = bufnr }) do
      if c.name ~= 'tyml' then
        return
      end
    end
  end

  for _, c in ipairs(vim.lsp.get_clients { bufnr = bufnr, name = 'tyml' }) do
    if c.attached_buffers[bufnr] then
      return
    end
  end

  local bin = find_binary()
  if not bin then
    if not notified_missing then
      notified_missing = true
      vim.notify('[tyml-lsp] tyml-lsp-server が見つかりません', vim.log.levels.ERROR)
    end
    return
  end

  local fname = vim.api.nvim_buf_get_name(bufnr)
  local root = vim.fs.root(fname ~= '' and fname or bufnr, {
    'tyml.toml',
    'tyml.json',
    '.git',
  }) or (fname ~= '' and vim.fs.dirname(fname) or vim.fn.getcwd())

  vim.lsp.start({
    name = 'tyml',
    cmd = { bin, '--stdio' },
    root_dir = root,
    capabilities = (function()
      local caps = vim.lsp.protocol.make_client_capabilities()
      local ok, cmp = pcall(require, 'cmp_nvim_lsp')
      if ok then
        caps = vim.tbl_deep_extend('force', caps, cmp.default_capabilities())
      end
      return caps
    end)(),
  }, {
    bufnr = bufnr,
    reuse_client = function(client)
      return client.name == 'tyml'
    end,
  })
end

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('user-tyml-lsp', { clear = true }),
  pattern = { 'tyml', 'json', 'toml', 'ini', 'dosini' },
  callback = function(ev)
    local force = vim.bo[ev.buf].filetype == 'tyml'
    if force then
      start_tyml(ev.buf, true)
    else
      vim.schedule(function()
        start_tyml(ev.buf, false)
      end)
    end
  end,
})
