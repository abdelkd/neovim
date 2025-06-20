require('trouble').setup {
  focus = true,
}

local keymap = vim.keymap

keymap.set('n', '<leader>xw', '<cmd>Trouble diagnostics toggle<CR>', { desc = "Open trouble workspace diagnostics" })
keymap.set('n', "<leader>xd", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>",
  { desc = "Open trouble document diagnostics" })
keymap.set('n', "<leader>xq", "<cmd>Trouble quickfix toggle<CR>", { desc = "Open trouble quickfix list" })
keymap.set('n', "<leader>xl", "<cmd>Trouble loclist toggle<CR>", { desc = "Open trouble location list" })
keymap.set('n', "<leader>xt", "<cmd>Trouble todo toggle<CR>", { desc = "Open todos in trouble" })
