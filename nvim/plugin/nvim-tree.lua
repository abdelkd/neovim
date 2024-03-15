if vim.g.did_load_nvim_tree_plugin then
  return
end
vim.g.did_load_nvim_tree_plugin = true

local nvim_tree = require('nvim-tree')

nvim_tree.setup({
  view = {
    width = 30,
  },
  filesystem_watchers = {
    enable = true,
  },
})
