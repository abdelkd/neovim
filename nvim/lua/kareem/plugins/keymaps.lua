if vim.g.did_load_which_key_plugin then
  return
end
vim.g.did_load_which_key_plugin = true

local wk = require('which-key')
local conform = require('conform')

vim.o.timeout = true
vim.o.timeoutlen = 500

local M = {}

-- General Keymaps
function M.general_keymaps()
  wk.register {
    ['<leader>'] = {
      ['q'] = { '<cmd>q<CR>', 'Quit' },
      ['w'] = { '<cmd>w<CR>', 'Save' },
      ['x'] = { '<cmd>q!<CR>', 'Force Quit' },
      ['h'] = { '<cmd>nohlsearch<CR>', 'Clear Search Highlight' },
      ['sm'] = {},

      -- Git Keymaps
      g = {
        name = 'Git',
        g = { '<cmd>Telescope git_status<CR>', 'Git Status' },
        b = { '<cmd>Telescope git_branches<CR>', 'Git Branches' },
      },
    },
  }
end

-- Telescope Keymaps
function M.telescope_keymaps()
  wk.register {
    ['<leader>'] = {
      f = {
        name = 'File',
        f = { '<cmd>Telescope find_files<CR>', 'Find Files' },
        r = { '<cmd>Telescope oldfiles<CR>', 'Recent Files' },
        g = { '<cmd>Telescope live_grep<CR>', 'Live Grep' },
        b = { '<cmd>Telescope buffers<CR>', 'List Buffers' },
      },
    },
  }
end

-- LSP Keymaps
function M.lsp_keymaps(bufnr)
  wk.register({
    g = {
      name = 'Goto',
      d = { '<cmd>lua vim.lsp.buf.definition()<CR>', 'Go to Definition' },
      r = { '<cmd>lua vim.lsp.buf.references()<CR>', 'Find References' },
      i = { '<cmd>lua vim.lsp.buf.implementation()<CR>', 'Go to Implementation' },
      t = { '<cmd>Telescope lsp_type_definitions<CR>' },
    },
    ['<leader>'] = {
      l = {
        name = 'LSP',
        r = { '<cmd>lua vim.lsp.buf.rename()<CR>', 'Rename Symbol' },
        a = { '<cmd>lua vim.lsp.buf.code_action()<CR>', 'Code Action' },
        e = { '<cmd>lua vim.lsp.buf.open_float()<CR>', 'Show Diagnostics' },
        q = { '<cmd>lua vim.lsp.buf.setloclist()<CR>', 'Quickfix Diagnostics' },
        d = { '<cmd>Telescope diagnostics bufnr=0<CR>', 'Show Buffer Diagnostics' },
        l = { '<cmd>lua vim.diagnostic.open_float(nil, { scope = "line" })<CR>', 'Show Line Diagnostics' },
        h = { '<cmd>lua vim.lsp.buf.hover()<CR>', 'Hover Documentation' },
        R = { '<cmd>lua vim.lsp.restart_client()<CR>', 'Restart LSP Server' },
        c = { '<cmd>lua vim.lsp.codelens.run()<CR>', 'Run CodeLens Action' },
      },
    },
  }, { buffer = bufnr })
end

-- Formatting Keymaps
function M.formatting_keymaps()
  wk.register {
    ['<leader>'] = {
      F = {
        name = 'Format',
        f = {
          function()
            conform.format {
              lsp_fallback = true,
              async = false,
              timeout_ms = 1000,
            }
          end,
          'Format File',
        },
      },
    },
  }
end

function M.setup()
  M.general_keymaps()
  M.telescope_keymaps()
end

return M
