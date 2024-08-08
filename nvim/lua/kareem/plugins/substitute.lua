if vim.g.did_load_substitute_plugin then
  return
end
vim.g.did_load_substitute_plugin = true

vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile' }, {
  callback = function()
    local substitute = require('substitute')

    substitute.setup()

    -- set keymaps
    local keymap = vim.keymap -- for conciseness

    vim.keymap.set('n', 's', substitute.operator, { desc = 'Substitute with motion' })
    vim.keymap.set('n', 'ss', substitute.line, { desc = 'Substitute line' })
    vim.keymap.set('n', 'S', substitute.eol, { desc = 'Substitute to end of line' })
    vim.keymap.set('x', 's', substitute.visual, { desc = 'Substitute in visual mode' })
  end,
})
