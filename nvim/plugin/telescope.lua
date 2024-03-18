if vim.g.did_load_telescope_plugin then
  return
end
vim.g.did_load_telescope_plugin = false

local telescope = require('telescope')
local actions = require('telescope.actions')

local builtin = require('telescope.builtin')
local wk = require('which-key')

-- Fall back to find_files if not in a git repo
local project_files = function()
  local opts = {} -- define here if you want to define something
  local ok = pcall(builtin.git_files, opts)
  if not ok then
    builtin.find_files(opts)
  end
end

-- vim.keymap.set('n', '<M-f>', fuzzy_grep_current_file_type, { desc = '[telescope] fuzzy grep filetype' })
---@param picker function the telescope picker to use
local function grep_current_file_type(picker)
  local current_file_ext = vim.fn.expand('%:e')
  local additional_vimgrep_arguments = {}
  if current_file_ext ~= '' then
    additional_vimgrep_arguments = {
      '--type',
      current_file_ext,
    }
  end
  local conf = require('telescope.config').values
  picker {
    vimgrep_arguments = vim.tbl_flatten {
      conf.vimgrep_arguments,
      additional_vimgrep_arguments,
    },
  }
end

--- Grep the string under the cursor, filtering for the current file type
local function grep_string_current_file_type()
  grep_current_file_type(builtin.grep_string)
end

--- Live grep, filtering for the current file type
local function live_grep_current_file_type()
  grep_current_file_type(builtin.live_grep)
end

vim.keymap.set('n', '<C-g>', live_grep_current_file_type, { desc = 'Telescope Live Grep Filetype' })

wk.register({
  f = {
    f = { builtin.find_files, 'Find Files' },
    g = { builtin.live_grep, 'Live Grep' },
  },
  t = {
    p = { project_files, 'Telescope Project Files' },
    c = { builtin.quickfix, 'Telescope Quickfix List' },
    g = { builtin.quickfix, 'Telescope Command History' },
    l = { builtin.loclist, 'Telescope Loclist' },
    r = { builtin.registers, 'Telescope Registers' },
    d = { grep_string_current_file_type, 'Telescope Grep String in Filetype' },
    o = { builtin.lsp_dynamic_workspace_symbols, 'Telescope Dynamic Workspace Symbols' },
    b = {
      b = { builtin.buffers, 'Telescope Buffers' },
      f = { builtin.current_buffer_fuzzy_find, 'Telescope Current Buffer Fuzzy Find' },
    },
  },
  ['*'] = { builtin.grep_string, 'Grep String' }
}, { prefix = '<leader>' })

-- local layout_config = {
--   vertical = {
--     width = function(_, max_columns)
--       return math.floor(max_columns * 0.99)
--     end,
--     height = function(_, _, max_lines)
--       return math.floor(max_lines * 0.99)
--     end,
--     prompt_position = 'bottom',
--     preview_cutoff = 0,
--   },
-- }
-- --- Like live_grep, but fuzzy (and slower)
-- local function fuzzy_grep(opts)
--   opts = vim.tbl_extend('error', opts or {}, { search = '', prompt_title = 'Fuzzy grep' })
--   builtin.grep_string(opts)
-- end
--
-- local function fuzzy_grep_current_file_type()
--   grep_current_file_type(fuzzy_grep)
-- end
--
-- vim.keymap.set('n', '<leader>ff', builtin.find_files , { desc = '[t]elescope find files - ctrl[p] style' })
-- vim.keymap.set('n', '<loader>fg', builtin.live_grep, { desc = '[telescope] live grep' })
-- vim.keymap.set('n', '<M-p>', builtin.oldfiles, { desc = '[telescope] old files' })
-- telescope.setup {
--   defaults = {
--     path_display = {
--       'truncate',
--     },
--     layout_strategy = 'vertical',
--     layout_config = layout_config,
--     mappings = {
--       i = {
--         ['<C-q>'] = actions.send_to_qflist,
--         ['<C-l>'] = actions.send_to_loclist,
--         -- ['<esc>'] = actions.close,
--         ['<C-s>'] = actions.cycle_previewers_next,
--         ['<C-a>'] = actions.cycle_previewers_prev,
--       },
--       n = {
--         q = actions.close,
--       },
--     },
--     preview = {
--       treesitter = true,
--     },
--     history = {
--       path = vim.fn.stdpath('data') .. '/telescope_history.sqlite3',
--       limit = 1000,
--     },
--     color_devicons = true,
--     set_env = { ['COLORTERM'] = 'truecolor' },
--     prompt_prefix = '   ',
--     selection_caret = '  ',
--     entry_prefix = '  ',
--     initial_mode = 'insert',
--     vimgrep_arguments = {
--       'rg',
--       '-L',
--       '--color=never',
--       '--no-heading',
--       '--with-filename',
--       '--line-number',
--       '--column',
--       '--smart-case',
--     },
--   },
--   extensions = {
--     fzy_native = {
--       override_generic_sorter = false,
--       override_file_sorter = true,
--     },
--   },
-- }
--
telescope.load_extension('fzy_native')
-- telescope.load_extension('smart_history')
