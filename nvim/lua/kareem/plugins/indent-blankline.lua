if vim.g.did_load_indent_blankline_plugin then
  return
end
vim.g.did_load_indent_blankline_plugin = true

vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile' }, {
  callback = function()
    require('ibl').setup {
      indent = { char = '┊' },
    }
  end,
})
