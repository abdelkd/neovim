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
  f = { builtin.find_files, 'Find Files' },
  g = { builtin.live_grep, 'Live Grep' },
  t = {
    h = { builtin.help_tags, 'Telescope Search Help' },
    k = { builtin.keymaps, 'Telescope Search Keymaps' },
    p = { project_files, 'Telescope Project Files' },
    c = { builtin.quickfix, 'Telescope Quickfix List' },
    g = { builtin.command_history, 'Telescope Command History' },
    l = { builtin.loclist, 'Telescope Loclist' },
    r = { builtin.resume, 'Telescope Resume Search' },
    d = { grep_string_current_file_type, 'Telescope Grep String in Filetype' },
    o = { builtin.lsp_dynamic_workspace_symbols, 'Telescope Dynamic Workspace Symbols' },
    f = { builtin.current_buffer_fuzzy_find, 'Telescope Current Buffer Fuzzy Find' },
  },
  ['*'] = { builtin.grep_string, 'Grep String' },
  ['<leader>'] = { builtin.buffers, 'Telescope Buffers' },
  ['/'] = { function()
      -- You can pass additional configuration to telescope to change theme, layout, etc.
      builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
        winblend = 10,
        previewer = false,
      })
    end, '[/] Fuzzily search in current buffer' }
}, { prefix = '<leader>f' })

telescope.setup {
  defaults = {
    path_display = {
      'truncate',
    },
    layout_strategy = 'vertical',
    mappings = {
      i = {
        ['<C-q>'] = actions.send_to_qflist,
        ['<C-l>'] = actions.send_to_loclist,
        -- ['<esc>'] = actions.close,
        ['<C-s>'] = actions.cycle_previewers_next,
        ['<C-a>'] = actions.cycle_previewers_prev,
      },
      n = {
        q = actions.close,
      },
    },
    preview = {
      treesitter = true,
    },
    history = {
      path = vim.fn.stdpath('data') .. '/telescope_history.sqlite3',
      limit = 1000,
    },
    color_devicons = true,
    set_env = { ['COLORTERM'] = 'truecolor' },
    prompt_prefix = '   ',
    selection_caret = '  ',
    entry_prefix = '  ',
    initial_mode = 'insert',
    vimgrep_arguments = {
      'rg',
      '-L',
      '--color=never',
      '--no-heading',
      '--with-filename',
      '--line-number',
      '--column',
      '--smart-case',
    },
  },
  extensions = {
    fzy_native = {
      override_generic_sorter = false,
      override_file_sorter = true,
    },
    ['ui-select'] = {
      require('telescope.themes').get_dropdown(),
    },
  },
}

-- telescope.load_extension('fzy_native')
-- telescope.load_extension('smart_history')

pcall(require('telescope').load_extension, 'fzf')
pcall(require('telescope').load_extension, 'ui-select')
