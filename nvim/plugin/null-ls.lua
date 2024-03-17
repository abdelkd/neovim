local null_ls = require('null-ls')
local keymap = vim.keymap

keymap.set('n', '<leader>gf', vim.lsp.buf.format, {})

null_ls.setup {
  sources = {
    null_ls.builtins.code_actions.statix,
    null_ls.builtins.formatting.stylua,
    null_ls.builtins.formatting.prettierd,
    null_ls.builtins.formatting.clang_format,
    null_ls.builtins.formatting.gofmt,
    null_ls.builtins.formatting.nixfmt,
    null_ls.builtins.formatting.rustywind,
    null_ls.builtins.formatting.shfmt,
    null_ls.builtins.diagnostics.eslint_d,
    null_ls.builtins.diagnostics.cppcheck,
    null_ls.builtins.diagnostics.markdownlint,
    null_ls.builtins.diagnostics.todo_comments,
    null_ls.builtins.diagnostics.dictionary,
  },
}
