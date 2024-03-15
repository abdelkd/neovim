if vim.g.did_load_which_key_plugin then
  return
end

vim.o.timeout = true
vim.o.timeoutlen = 300

local wk = require('which-key')

wk.setup({})
