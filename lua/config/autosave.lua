local DELAY_MS = 1000

local timers = {}

local function should_save(buf)
  if not vim.api.nvim_buf_is_valid(buf) then
    return false
  end
  if vim.bo[buf].buftype ~= '' then
    return false
  end
  if vim.api.nvim_buf_get_name(buf) == '' then
    return false
  end
  if not vim.bo[buf].modified then
    return false
  end
  if not vim.bo[buf].modifiable then
    return false
  end
  if vim.bo[buf].readonly then
    return false
  end
  return true
end

local function cancel(buf)
  local t = timers[buf]
  if t then
    t:stop()
    if not t:is_closing() then
      t:close()
    end
    timers[buf] = nil
  end
end

local function schedule_save(buf)
  cancel(buf)
  local t = vim.uv.new_timer()
  timers[buf] = t
  t:start(
    DELAY_MS,
    0,
    vim.schedule_wrap(function()
      cancel(buf)
      if not should_save(buf) then
        return
      end
      vim.api.nvim_buf_call(buf, function()
        pcall(vim.cmd, 'silent! lockmarks update')
      end)
    end)
  )
end

local group = vim.api.nvim_create_augroup('user-autosave', { clear = true })

vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI' }, {
  group = group,
  callback = function(ev)
    schedule_save(ev.buf)
  end,
})

vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufDelete', 'BufWipeout' }, {
  group = group,
  callback = function(ev)
    cancel(ev.buf)
  end,
})
