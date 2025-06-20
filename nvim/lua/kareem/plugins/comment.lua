if vim.g.did_load_comment_plugin then
  return
end
vim.g.did_load_comment_plugin = true

vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile' }, {
  callback = function()
    -- import comment plugin safely
    local comment = require('Comment')

    local ts_context_commentstring = require('ts_context_commentstring.integrations.comment_nvim')

    -- enable comment
    comment.setup {
      -- for commenting tsx, jsx, svelte, html files
      pre_hook = ts_context_commentstring.create_pre_hook(),
    }
  end,
})
