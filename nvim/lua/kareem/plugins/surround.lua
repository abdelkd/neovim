if vim.g.did_load_surround_plugin then
  return
end
vim.g.did_load_surround_plugin = true

vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile' }, {
  callback = function()
    require('nvim-surround').setup {}
  end,
})
