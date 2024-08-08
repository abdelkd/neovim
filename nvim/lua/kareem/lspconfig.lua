local lsp = require('kareem.lsp')
local lspconfig = require('lspconfig')

vim.api.nvim_create_autocmd({}, {
  callback = function() end,
})

lspconfig.bashls.setup {}
