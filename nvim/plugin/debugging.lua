local dap = require('dap')
local dapui = require('dapui')

dap.listeners.before.attach.dapui_config = function()
  dapui.open()
end
dap.listeners.before.launch.dapui_config = function()
  dapui.open()
end
dap.listeners.before.event_terminated.dapui_config = function()
  dapui.close()
end
dap.listeners.before.event_exited.dapui_config = function()
  dapui.close()
end

dapui.setup()
require('dap-go').setup()

vim.keymap.set('n', '<leader>dt', dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
vim.keymap.set('n', '<leader>dc', dap.continue, { desc = "Continue debugging" })
