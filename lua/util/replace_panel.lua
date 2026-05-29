local M = {}

local PREFIX_BEFORE = 'Before: '
local PREFIX_AFTER = 'After : '

local function get_input(buf, lnum, prefix)
  local line = vim.api.nvim_buf_get_lines(buf, lnum, lnum + 1, false)[1] or ''
  if vim.startswith(line, prefix) then
    return line:sub(#prefix + 1)
  end
  return line
end

local function highlight_matches(target_buf, ns, pattern)
  vim.api.nvim_buf_clear_namespace(target_buf, ns, 0, -1)
  if pattern == '' then
    return
  end
  local ok, regex = pcall(vim.regex, [[\v]] .. pattern)
  if not ok then
    return
  end

  local lines = vim.api.nvim_buf_get_lines(target_buf, 0, -1, false)
  for lnum, line in ipairs(lines) do
    local offset = 0
    while offset <= #line do
      local s, e = regex:match_str(line:sub(offset + 1))
      if not s then
        break
      end
      local hs = offset + s
      local he = offset + e
      pcall(vim.api.nvim_buf_set_extmark, target_buf, ns, lnum - 1, hs, {
        end_col = he,
        hl_group = 'Search',
        priority = 200,
      })
      if he == hs then
        offset = offset + 1
      else
        offset = he
      end
    end
  end
end

local function execute_project(pat, rep)
  if vim.fn.executable 'rg' ~= 1 then
    vim.notify('ripgrep (rg) is required for project replace', vim.log.levels.ERROR)
    return
  end
  local cwd = vim.fn.getcwd()
  local files = vim.fn.systemlist { 'rg', '-l', '--no-messages', '--', pat, cwd }
  if vim.v.shell_error ~= 0 or #files == 0 then
    vim.notify('No matching files', vim.log.levels.INFO)
    return
  end

  local choice = vim.fn.confirm(('Replace in %d file(s) under %s?'):format(#files, cwd), '&Yes\n&No', 2)
  if choice ~= 1 then
    return
  end

  local pat_e = pat:gsub('/', '\\/')
  local rep_e = rep:gsub('/', '\\/')

  local saved = vim.fn.argv()
  pcall(vim.cmd, 'silent! %argdelete')

  local quoted = {}
  for _, f in ipairs(files) do
    table.insert(quoted, vim.fn.fnameescape(f))
  end
  pcall(vim.cmd, 'args ' .. table.concat(quoted, ' '))

  local ok, err = pcall(vim.cmd, ('silent! argdo keeppatterns %%s/\\v%s/%s/ge | update'):format(pat_e, rep_e))

  pcall(vim.cmd, 'silent! %argdelete')
  if #saved > 0 then
    local q = {}
    for _, f in ipairs(saved) do
      table.insert(q, vim.fn.fnameescape(f))
    end
    pcall(vim.cmd, 'args ' .. table.concat(q, ' '))
  end

  if not ok then
    vim.notify('Project replace failed: ' .. tostring(err), vim.log.levels.ERROR)
  else
    vim.notify(('Replaced in %d file(s)'):format(#files), vim.log.levels.INFO)
  end
end

function M.open(opts)
  opts = opts or {}
  local mode = opts.mode == 'project' and 'project' or 'file'
  local title = mode == 'project' and ' Replace · ENTIRE PROJECT (regex) ' or ' Replace · File (regex) '

  local target_buf = vim.api.nvim_get_current_buf()
  local target_win = vim.api.nvim_get_current_win()
  if mode == 'file' and vim.bo[target_buf].buftype ~= '' then
    vim.notify('Replace: not a normal buffer', vim.log.levels.WARN)
    return
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].swapfile = false
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { PREFIX_BEFORE, PREFIX_AFTER })

  local width = math.max(50, math.floor(vim.o.columns * 0.5))
  local height = 2
  local row = math.floor((vim.o.lines - height) / 2) - 2
  local col = math.floor((vim.o.columns - width) / 2)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    row = row,
    col = col,
    width = width,
    height = height,
    style = 'minimal',
    border = 'rounded',
    title = title,
    title_pos = 'center',
  })
  vim.wo[win].winhighlight = 'Normal:HoverNormal,FloatBorder:HoverBorder'
  vim.wo[win].cursorline = false
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].signcolumn = 'no'

  local label_ns = vim.api.nvim_create_namespace 'user-replace-label'
  vim.api.nvim_buf_set_extmark(buf, label_ns, 0, 0, { end_col = #PREFIX_BEFORE, hl_group = 'Comment' })
  vim.api.nvim_buf_set_extmark(buf, label_ns, 1, 0, { end_col = #PREFIX_AFTER, hl_group = 'Comment' })

  local match_ns = vim.api.nvim_create_namespace 'user-replace-match'

  local function refresh()
    if vim.api.nvim_buf_is_valid(target_buf) and vim.bo[target_buf].buftype == '' then
      highlight_matches(target_buf, match_ns, get_input(buf, 0, PREFIX_BEFORE))
    end
  end

  local group = vim.api.nvim_create_augroup('user-replace-panel-' .. buf, { clear = true })
  vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI' }, {
    group = group,
    buffer = buf,
    callback = function()
      local l1 = vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] or ''
      local l2 = vim.api.nvim_buf_get_lines(buf, 1, 2, false)[1] or ''
      if not vim.startswith(l1, PREFIX_BEFORE) then
        vim.api.nvim_buf_set_lines(buf, 0, 1, false, { PREFIX_BEFORE .. l1 })
      end
      if not vim.startswith(l2, PREFIX_AFTER) then
        vim.api.nvim_buf_set_lines(buf, 1, 2, false, { PREFIX_AFTER .. l2 })
      end
      refresh()
    end,
  })

  local closed = false
  local function close()
    if closed then
      return
    end
    closed = true
    if vim.api.nvim_buf_is_valid(target_buf) then
      vim.api.nvim_buf_clear_namespace(target_buf, match_ns, 0, -1)
    end
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end

  vim.api.nvim_create_autocmd('WinClosed', {
    group = group,
    pattern = tostring(win),
    callback = close,
  })

  local function jump_to(lnum)
    local line = vim.api.nvim_buf_get_lines(buf, lnum - 1, lnum, false)[1] or ''
    vim.api.nvim_win_set_cursor(win, { lnum, #line })
    vim.cmd 'startinsert!'
  end

  local function execute_replace()
    local pat = get_input(buf, 0, PREFIX_BEFORE)
    local rep = get_input(buf, 1, PREFIX_AFTER)
    if pat == '' then
      close()
      return
    end
    close()

    if mode == 'project' then
      execute_project(pat, rep)
      return
    end

    local pat_e = pat:gsub('/', '\\/')
    local rep_e = rep:gsub('/', '\\/')

    if vim.api.nvim_win_is_valid(target_win) then
      vim.api.nvim_set_current_win(target_win)
    end
    local ok, err = pcall(function()
      vim.api.nvim_buf_call(target_buf, function()
        vim.cmd(('keeppatterns %%s/\\v%s/%s/g'):format(pat_e, rep_e))
      end)
    end)
    if not ok then
      vim.notify('Replace failed: ' .. tostring(err), vim.log.levels.ERROR)
    end
  end

  vim.keymap.set({ 'n', 'i' }, '<CR>', function()
    local lnum = vim.api.nvim_win_get_cursor(win)[1]
    if lnum == 1 then
      jump_to(2)
    else
      execute_replace()
    end
  end, { buffer = buf, nowait = true, silent = true })

  vim.keymap.set('i', '<BS>', function()
    local pos = vim.api.nvim_win_get_cursor(win)
    local lnum, ccol = pos[1], pos[2]
    local prefix_len = lnum == 1 and #PREFIX_BEFORE or #PREFIX_AFTER
    if ccol <= prefix_len then
      return ''
    end
    return '<BS>'
  end, { buffer = buf, expr = true, nowait = true })

  vim.keymap.set('n', '<Esc>', close, { buffer = buf, nowait = true, silent = true })
  vim.keymap.set('n', 'q', close, { buffer = buf, nowait = true, silent = true })

  jump_to(1)
end

return M
