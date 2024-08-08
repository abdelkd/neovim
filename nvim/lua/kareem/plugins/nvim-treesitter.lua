if vim.g.did_load_nvim_treesitter_plugin then
  return
end
vim.g.did_load_nvim_treesitter_plugin = true

-- import nvim-treesitter plugin
local treesitter = require('nvim-treesitter.configs')

vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile' }, {
  callback = function()
    -- configure treesitter
    treesitter.setup {
      -- enable syntax highlighting
      highlight = {
        enable = true,
      },
      -- enable indentation
      indent = { enable = true },
      -- enable autotagging (w/ nvim-ts-autotag plugin)
      autotag = {
        enable = true,
      },
      auto_install = false,
      -- -- ensure these language parsers are installed
      -- ensure_installed = {
      --   'json',
      --   'javascript',
      --   'typescript',
      --   'tsx',
      --   'yaml',
      --   'html',
      --   'css',
      --   'prisma',
      --   'markdown',
      --   'markdown_inline',
      --   'svelte',
      --   'graphql',
      --   'bash',
      --   'lua',
      --   'vim',
      --   'dockerfile',
      --   'gitignore',
      --   'query',
      --   'vimdoc',
      --   'c',
      -- },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = '<C-space>',
          node_incremental = '<C-space>',
          scope_incremental = false,
          node_decremental = '<bs>',
        },
      },
    }
  end,
})
