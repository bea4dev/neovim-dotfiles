local M = {}

local menu_items = {}

local function actions_menu(node)
  local pickers = require 'telescope.pickers'
  local finders = require 'telescope.finders'
  local sorters = require 'telescope.sorters'
  local actions = require 'telescope.actions'
  local action_state = require 'telescope.actions.state'
  local themes = require 'telescope.themes'

  local opts = themes.get_dropdown {
    prompt_title = 'NvimTree',
    layout_strategy = 'center',
    layout_config = { width = 60, height = 15 },
  }

  pickers
    .new(opts, {
      finder = finders.new_table {
        results = menu_items,
        entry_maker = function(item)
          return { value = item, ordinal = item.name, display = item.name }
        end,
      },
      sorter = sorters.get_generic_fuzzy_sorter(),
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          action_state.get_selected_entry().value.handler(node)
        end)
        return true
      end,
    })
    :find()
end

local function build_commands()
  local api = require 'nvim-tree.api'
  local tree, fs, node = api.tree, api.fs, api.node

  return {
    { '', tree.change_root_to_node, 'CD' },
    { '', node.open.replace_tree_buffer, 'Open: In Place' },
    { '', node.show_info_popup, 'Info' },
    { '', fs.rename_sub, 'Rename: Omit Filename' },
    { '', node.open.tab, 'Open: New Tab' },
    { '', node.open.vertical, 'Open: Vertical Split' },
    { '', node.open.horizontal, 'Open: Horizontal Split' },
    { '<BS>', node.navigate.parent_close, 'Close Directory' },
    { '<CR>', node.open.edit, 'Open' },
    { '<Tab>', node.open.preview, 'Open Preview' },
    { '>', node.navigate.sibling.next, 'Next Sibling' },
    { '<', node.navigate.sibling.prev, 'Previous Sibling' },
    { '.', node.run.cmd, 'Run Command' },
    { '-', tree.change_root_to_parent, 'Up' },
    { 'c', fs.create, 'Create' },
    { '', api.marks.bulk.move, 'Move Bookmarked' },
    { 'B', tree.toggle_no_buffer_filter, 'Toggle No Buffer' },
    { '', fs.copy.node, 'Copy' },
    { 'C', tree.toggle_git_clean_filter, 'Toggle Git Clean' },
    { '[c', node.navigate.git.prev, 'Prev Git' },
    { ']c', node.navigate.git.next, 'Next Git' },
    { 'd', fs.remove, 'Delete' },
    { 't', fs.trash, 'Trash' },
    { 'E', tree.expand_all, 'Expand All' },
    { '', fs.rename_basename, 'Rename: Basename' },
    { ']e', node.navigate.diagnostics.next, 'Next Diagnostic' },
    { '[e', node.navigate.diagnostics.prev, 'Prev Diagnostic' },
    { 'F', api.live_filter.clear, 'Clean Filter' },
    { 'f', api.live_filter.start, 'Filter' },
    { 'g?', tree.toggle_help, 'Help' },
    { 'gy', fs.copy.absolute_path, 'Copy Absolute Path' },
    { 'H', tree.toggle_hidden_filter, 'Toggle Dotfiles' },
    { 'I', tree.toggle_gitignore_filter, 'Toggle Git Ignore' },
    { 'J', node.navigate.sibling.last, 'Last Sibling' },
    { 'K', node.navigate.sibling.first, 'First Sibling' },
    { 'm', api.marks.toggle, 'Toggle Bookmark' },
    { 'o', node.open.edit, 'Open' },
    { 'O', node.open.no_window_picker, 'Open: No Window Picker' },
    { '', fs.paste, 'Paste' },
    { 'P', node.navigate.parent, 'Parent Directory' },
    { 'q', tree.close, 'Close' },
    { 'r', fs.rename, 'Rename' },
    { 'R', tree.reload, 'Refresh' },
    { 's', node.run.system, 'Run System' },
    { 'S', tree.search_node, 'Search' },
    { 'U', tree.toggle_custom_filter, 'Toggle Hidden' },
    { 'W', tree.collapse_all, 'Collapse' },
    { '', fs.cut, 'Cut' },
    { 'y', fs.copy.filename, 'Copy Name' },
    { 'Y', fs.copy.relative_path, 'Copy Relative Path' },
    { '<Space>', actions_menu, 'Command' },
  }
end

function M.on_attach(bufnr)
  local api = require 'nvim-tree.api'
  api.config.mappings.default_on_attach(bufnr)

  local commands = build_commands()
  menu_items = {}
  for _, cmd in ipairs(commands) do
    table.insert(menu_items, { name = cmd[3], handler = cmd[2] })
    if #cmd[1] > 0 then
      vim.keymap.set('n', cmd[1], cmd[2], {
        desc = 'nvim-tree: ' .. cmd[3],
        buffer = bufnr,
        nowait = true,
      })
    end
  end
end

return M
