if vim.g.did_load_which_key_plugin then
  return
end
vim.g.did_load_which_key_plugin = true

-- Set leader key to space
vim.g.mapleader = ' '

local wk = require('which-key')
local conform = require('conform')

-- Set timeout for key mappings
vim.o.timeout = true
vim.o.timeoutlen = 500

local M = {}

local keymap = vim.keymap

-- General Keymaps
function M.general_keymaps()
  -- Exit insert mode with jk
  keymap.set('i', 'jk', '<ESC>', { desc = 'Exit insert mode with jk' })

  -- Register general keymaps
  wk.add {
    { '<leader>q', '<cmd>q<CR>', desc = 'Quit' },
    { '<leader>w', '<cmd>w<CR>', desc = 'Save' },
    { '<leader>x', '<cmd>q!<CR>', desc = 'Force Quit' },
    { '<leader>h', '<cmd>nohlsearch<CR>', desc = 'Clear Search Highlight' },
    { '<leader>+', '<C-a>', desc = 'Increment Number' },
    { '<leader>-', '<C-a>', desc = 'Decrement Number' },

    -- Window Management
    { '<leader>sv', '<C-w>v', desc = 'Split Window Vertically' },
    { '<leader>sh', '<C-w>h', desc = 'Split Window Horizontally' },
    { '<leader>se', '<C-w>=', desc = 'Make Splits Equal' },
    { '<leader>sx', '<cmd>close<CR>', desc = 'Close Current Split' },

    -- Tab Management
    { '<leader>to', '<cmd>tabnew<CR>', desc = 'Open New Tab' },
    { '<leader>tx', '<cmd>tabclose<CR>', desc = 'Close Current Tab' },
    { '<leader>tn', '<cmd>tabn<CR>', desc = 'Next Tab' },
    { '<leader>tp', '<cmd>tabp<CR>', desc = 'Previous Tab' },
    { '<leader>tf', '<cmd>tabnew %<CR>', desc = 'Current Buffer in New Tab' },

    -- Git
    { '<leader>gg', '<cmd>Telescope git_status<CR>', desc = 'Git Status' },
    { '<leader>gb', '<cmd>Telescope git_branches<CR>', desc = 'Git Branches' },
  }
end

-- Telescope Keymaps
function M.telescope_keymaps()
  wk.add {
    { '<leader>ff', '<cmd>Telescope find_files<CR>', desc = 'Find Files' },
    { '<leader>fr', '<cmd>Telescope oldfiles<CR>', desc = 'Recent Files' },
    { '<leader>fg', '<cmd>Telescope live_grep<CR>', desc = 'Live Grep' },
    { '<leader>fb', '<cmd>Telescope buffers<CR>', desc = 'List Buffers' },
  }
end

-- LSP Keymaps
function M.lsp_keymaps(bufnr)
  wk.add({
    { 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', desc = 'Go to Definition' },
    { 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', desc = 'Find References' },
    { 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', desc = 'Go to Implementation' },
    { 'gt', '<cmd>Telescope lsp_type_definitions<CR>', desc = 'Type Definitions' },
    { '<leader>lr', '<cmd>lua vim.lsp.buf.rename()<CR>', desc = 'Rename Symbol' },
    { '<leader>la', '<cmd>lua vim.lsp.buf.code_action()<CR>', desc = 'Code Action' },
    { '<leader>le', '<cmd>lua vim.lsp.buf.open_float()<CR>', desc = 'Show Diagnostics' },
    { '<leader>lq', '<cmd>lua vim.lsp.buf.setloclist()<CR>', desc = 'Quickfix Diagnostics' },
    { '<leader>ld', '<cmd>Telescope diagnostics bufnr=0<CR>', desc = 'Show Buffer Diagnostics' },
    {
      '<leader>ll',
      '<cmd>lua vim.diagnostic.open_float(nil, { scope = "line" })<CR>',
      desc = 'Show Line Diagnostics',
    },
    { '<leader>lh', '<cmd>lua vim.lsp.buf.hover()<CR>', desc = 'Hover Documentation' },
    { '<leader>lR', '<cmd>lua vim.lsp.restart_client()<CR>', desc = 'Restart LSP Server' },
    { '<leader>lc', '<cmd>lua vim.lsp.codelens.run()<CR>', desc = 'Run CodeLens Action' },
  }, { buffer = bufnr })
end

-- Formatting Keymaps
function M.formatting_keymaps()
  wk.add {
    {
      '<leader>Ff',
      function()
        conform.format { lsp_fallback = true, async = false, timeout_ms = 1000 }
      end,
      desc = 'Format File',
    },
  }
end

function M.setup()
  M.general_keymaps()
  M.telescope_keymaps()
  M.formatting_keymaps()
end

return M
