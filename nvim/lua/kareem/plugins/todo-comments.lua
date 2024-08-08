if vim.g.did_load_todo_comments_plugin then
  return
end
vim.g.did_load_todo_comments_plugin = true

vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile' }, {
  callback = function()
    local todo_comments = require('todo-comments')

    -- set keymaps
    local keymap = vim.keymap -- for conciseness

    keymap.set('n', ']t', function()
      todo_comments.jump_next()
    end, { desc = 'Next todo comment' })

    keymap.set('n', '[t', function()
      todo_comments.jump_prev()
    end, { desc = 'Previous todo comment' })

    todo_comments.setup()
  end,
})
