if vim.g.did_load_autocommands_plugin then
  return
end
vim.g.did_load_autocommands_plugin = true

-- TODO: do something about performance
vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile' }, {
  callback = function(args)
    require('lsp-file-operations').setup()

    -- import lspconfig plugin
    local lspconfig = require('lspconfig')

    local lsp_status = require('lsp-status') -- LSP status in statusline
    lsp_status.register_progress()

    -- import cmp-nvim-lsp plugin
    local cmp_nvim_lsp = require('cmp_nvim_lsp')

    local keymap = vim.keymap -- for conciseness

    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('UserLspConfig', {}),
      callback = function(ev)
        -- Buffer local mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local opts = { buffer = ev.buf, silent = true }

        -- set keybinds
        opts.desc = 'Show LSP references'
        keymap.set('n', 'gR', '<cmd>Telescope lsp_references<CR>', opts) -- show definition, references

        opts.desc = 'Go to declaration'
        keymap.set('n', 'gD', vim.lsp.buf.declaration, opts) -- go to declaration

        opts.desc = 'Show LSP definitions'
        keymap.set('n', 'gd', '<cmd>Telescope lsp_definitions<CR>', opts) -- show lsp definitions

        opts.desc = 'Show LSP implementations'
        keymap.set('n', 'gi', '<cmd>Telescope lsp_implementations<CR>', opts) -- show lsp implementations

        opts.desc = 'Show LSP type definitions'
        keymap.set('n', 'gt', '<cmd>Telescope lsp_type_definitions<CR>', opts) -- show lsp type definitions

        opts.desc = 'See available code actions'
        keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

        opts.desc = 'Smart rename'
        keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts) -- smart rename

        opts.desc = 'Show buffer diagnostics'
        keymap.set('n', '<leader>D', '<cmd>Telescope diagnostics bufnr=0<CR>', opts) -- show  diagnostics for file

        opts.desc = 'Show line diagnostics'
        keymap.set('n', '<leader>d', vim.diagnostic.open_float, opts) -- show diagnostics for line

        opts.desc = 'Go to previous diagnostic'
        keymap.set('n', '[d', vim.diagnostic.goto_prev, opts) -- jump to previous diagnostic in buffer

        opts.desc = 'Go to next diagnostic'
        keymap.set('n', ']d', vim.diagnostic.goto_next, opts) -- jump to next diagnostic in buffer

        opts.desc = 'Show documentation for what is under cursor'
        keymap.set('n', 'K', vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

        opts.desc = 'Restart LSP'
        keymap.set('n', '<leader>rs', ':LspRestart<CR>', opts) -- mapping to restart lsp if necessary

        if args.data and args.data.client_id then
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          print(client, args.data)

          if client and client.server_capabilities.codeLensProvider then
            vim.api.nvim_create_autocmd({ 'CursorMoved ' }, {
              callback = function()
                vim.lsp.codelens.refresh()
              end,
            })
            vim.keymap.set('n', 'z!', vim.lsp.codelens.run, { buffer = args.buf, silent = true })
          end
        end
      end,
    })

    -- used to enable autocompletion (assign to every lsp server config)
    local capabilities = require('kareem.lsp').make_client_capabilities()
    capabilities = vim.tbl_deep_extend('force', capabilities, cmp_nvim_lsp.default_capabilities())
    capabilities = vim.tbl_extend('keep', capabilities or {}, lsp_status.capabilities)

    -- Change the Diagnostic symbols in the sign column (gutter)
    -- (not in youtube nvim video)
    local signs = { Error = ' ', Warn = ' ', Hint = '󰠠 ', Info = ' ' }
    for type, icon in pairs(signs) do
      local hl = 'DiagnosticSign' .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = '' })
    end

    local servers = {
      'astro',
      'clangd',
      'emmet_language_server',
      'html',
      'htmx',
      'jdtls',
      'jsonls',
      'nil_ls',
      'templ',
      'tsserver',
      'zls',
    }

    for _, lsp in ipairs(servers) do
      lspconfig[lsp].setup {
        capabilities = capabilities,
      }
    end

    lspconfig.gopls.setup {
      filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
      settings = {
        env = {
          GOEXPERIMENT = 'rangefunc',
        },
        formatting = {
          gofumpt = true,
        },
      },
    }

    lspconfig.graphql.setup {
      capabilities = capabilities,
      filetypes = { 'graphql', 'gql', 'svelte', 'typescriptreact', 'javascriptreact' },
    }

    lspconfig.emmet_ls.setup {
      capabilities = capabilities,
      filetypes = { 'html', 'typescriptreact', 'javascriptreact', 'css', 'sass', 'scss', 'less', 'svelte' },
    }

    lspconfig.svelte.setup {
      capabilities = capabilities,
      on_init = function(client)
        -- Create an autocommand for BufWritePost event
        vim.api.nvim_create_autocmd('BufWritePost', {
          pattern = { '*.js', '*.ts' },
          callback = function(ctx)
            -- Use ctx.match to get the file URI
            client.notify('$/onDidChangeTsOrJsFile', { uri = ctx.match })
          end,
        })
      end,
    }

    lspconfig.tailwindcss.setup {
      capabilities = capabilities,
      settings = {
        includeLanguages = {
          templ = 'html',
        },
      },
    }

    lspconfig.lua_ls.setup {
      capabilities = capabilities,
      on_init = function(client)
        local path = client.workspace_folders[1].name
        if vim.loop.fs_stat(path .. '/.luarc.json') or vim.loop.fs_stat(path .. '/.luarc.jsonc') then
          return
        end

        client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
          completion = {
            callSnippet = 'Replace',
          },
          runtime = {
            version = 'LuaJIT',
          },
          workspace = {
            checkThirdParty = false,
            library = {
              vim.env.VIMRUNTIME,
            },
          },
        })
      end,
      settings = {
        Lua = {},
      },
    }
  end,
})
