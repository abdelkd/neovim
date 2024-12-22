if vim.g.did_load_autocommands_plugin then
  return
end
vim.g.did_load_autocommands_plugin = true
local keymaps = require('kareem.plugins.keymaps')

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(args)
    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = args.buf, silent = true }
    keymaps.lsp_keymaps(args.buf)

    -- if args then
    --   if args.data and args.data.client_id then
    --     local client = vim.lsp.get_client_by_id(args.data.client_id)
    --
    --     if client and client.server_capabilities.codeLensProvider then
    --       vim.api.nvim_create_autocmd({ 'CursorMoved' }, {
    --         callback = function()
    --           vim.lsp.codelens.refresh()
    --         end,
    --       })
    --       vim.keymap.set('n', 'z!', vim.lsp.codelens.run, { buffer = args.buf, silent = true })
    --     end
    --   end
    -- end
  end,
})

vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile' }, {
  callback = function(args)
    if vim.g.did_load_lsp then
      return
    end
    vim.g.did_load_lsp = true

    require('lsp-file-operations').setup()

    -- import lspconfig plugin
    local lspconfig = require('lspconfig')

    local lsp_status = require('lsp-status') -- LSP status in statusline
    lsp_status.register_progress()

    -- import cmp-nvim-lsp plugin
    local cmp_nvim_lsp = require('cmp_nvim_lsp')

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
      'bashls',
      'clangd',
      'html',
      'jdtls',
      'jsonls',
      'nil_ls',
      'pyright',
      'rust_analyzer',
      'templ',
      'zls',
    }

    for _, lsp in ipairs(servers) do
      lspconfig[lsp].setup {
        capabilities = capabilities,
      }
    end

    local local_tsserver = './node_modules/.bin/tsserver'
    local global_tsserver = vim.fn.system('which tsserver'):gsub('\n', '')

    local function get_tsserver_cmd()
      local tsserver_path = vim.fn.executable(local_tsserver) == 1 and local_tsserver or global_tsserver
      return { tsserver_path, '--stdio' }
    end

    lspconfig.ts_ls.setup {
      enabled = true,
      capabilities = capabilities,
      -- TODO should be generated/fixed in nix
      cmd = {
        'typescript-language-server',
        '--stdio',
      },
    }
    -- lspconfig.vtsls.setup {
    --   -- explicitly add default filetypes, so that we can extend
    --   -- them in related extras
    --   filetypes = {
    --     'javascript',
    --     'javascriptreact',
    --     'javascript.jsx',
    --     'typescript',
    --     'typescriptreact',
    --     'typescript.tsx',
    --   },
    --   settings = {
    --     complete_function_calls = true,
    --     vtsls = {
    --       enableMoveToFileCodeAction = true,
    --       autoUseWorkspaceTsdk = true,
    --       experimental = {
    --         maxInlayHintLength = 30,
    --         completion = {
    --           enableServerSideFuzzyMatch = true,
    --         },
    --       },
    --     },
    --   },
    --   typescript = {
    --     updateImportsOnFileMove = { enabled = 'always' },
    --     suggest = {
    --       completeFunctionCalls = true,
    --     },
    --     inlayHints = {
    --       enumMemberValues = { enabled = true },
    --       functionLikeReturnTypes = { enabled = true },
    --       parameterNames = { enabled = 'literals' },
    --       parameterTypes = { enabled = true },
    --       propertyDeclarationTypes = { enabled = true },
    --       variableTypes = { enabled = false },
    --     },
    --   },
    -- }

    -- lspconfig.ts_ls.setup {
    --   capabilities = capabilities,
    --   flags = {
    --     debounce_text_change = 300,
    --   },
    -- }

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
