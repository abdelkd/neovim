if vim.g.did_load_completion_plugin then
  return
end
vim.g.did_load_completion_plugin = true

vim.api.nvim_create_autocmd('InsertEnter', {
  pattern = '*',
  callback = function()
    local cmp = require('cmp')
    local luasnip = require('luasnip')
    local lspkind = require('lspkind')

    -- lspkind.init {
    --   -- Enable text-based completion icons
    --   with_text = true,
    --   -- Define symbols (e.g., for function, variable, etc.)
    --   symbol_map = {
    --     Text = '', -- Text symbol
    --     Method = '', -- Method symbol
    --     Function = '', -- Function symbol
    --     Constructor = '', -- Constructor symbol
    --     Field = '', -- Field symbol
    --     Variable = '', -- Variable symbol
    --     Class = 'ﴯ', -- Class symbol
    --     Interface = '了', -- Interface symbol
    --     Module = '', -- Module symbol
    --     Property = '', -- Property symbol
    --     Unit = '', -- Unit symbol
    --     Value = '', -- Value symbol
    --     Enum = '', -- Enum symbol
    --     Keyword = '', -- Keyword symbol
    --     Snippet = '', -- Snippet symbol
    --     Color = '', -- Color symbol
    --     File = '', -- File symbol
    --     Reference = '', -- Reference symbol
    --     Folder = '', -- Folder symbol
    --     EnumMember = '', -- Enum member symbol
    --     Constant = '', -- Constant symbol
    --     Struct = '', -- Struct symbol
    --     Event = '', -- Event symbol
    --     Operator = '', -- Operator symbol
    --     TypeParameter = '', -- Type parameter symbol
    --   },
    -- }

    -- loads vscode style snippets from installed plugins (e.g. friendly-snippets)
    require('luasnip.loaders.from_vscode').lazy_load()

    cmp.setup {
      window = {
        completion = {
          border = { '╭', '─', '╮', '│', '╯', '─', '╰', '│' },
          winhighlight = 'Normal:Pmenu,NormalNC:PmenuSel,Search:None',
          col_offset = -3,
          side_padding = 1,
        },
        documentation = {
          border = { '╭', '─', '╮', '│', '╯', '─', '╰', '│' },
          winhighlight = 'Normal:Pmenu,NormalNC:PmenuSel,Search:None',
        },
      },
      completion = {
        completeopt = 'menu,menuone,preview,noselect',
      },
      snippet = { -- configure how nvim-cmp interacts with snippet engine
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert {
        ['<C-k>'] = cmp.mapping.select_prev_item(), -- previous suggestion
        ['<C-j>'] = cmp.mapping.select_next_item(), -- next suggestion
        ['<C-d>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(), -- show completion suggestions
        ['<C-e>'] = cmp.mapping.abort(), -- close completion window
        ['<CR>'] = cmp.mapping.confirm { select = false },
      },
      -- sources for autocompletion
      sources = cmp.config.sources {
        { name = 'nvim_lsp' }, -- LSP
        { name = 'luasnip' }, -- snippets
        { name = 'buffer' }, -- text within current buffer
        { name = 'path' }, -- file system paths
      },

      -- configure lspkind for vs-code like pictograms in completion menu
      formatting = {
        format = lspkind.cmp_format {
          mode = 'symbol_text',
          maxwidth = 50,
          ellipsis_char = '...',
          menu = {
            buffer = '[Buffer]',
            nvim_lsp = '[LSP]',
            luasnip = '[Snippet]',
            path = '[Path]',
          },
        },
      },
    }
  end,
})
