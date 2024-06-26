local slow_format_filetypes = {}
require('conform').setup {
  format_on_save = function(bufnr)
    if slow_format_filetypes[vim.bo[bufnr].filetype] then
      return
    end
    local function on_format(err)
      if err and err:match('timeout$') then
        slow_format_filetypes[vim.bo[bufnr].filetype] = true
      end
    end

    return { timeout_ms = 100, lsp_fallback = true }, on_format
  end,
  -- format_after_save = function(bufnr)
  --   if slow_format_filetypes[vim.bo[bufnr].filetype] then
  --     return
  --   end
  --   return { lsp_fallback = true }
  -- end,
  formatters_by_ft = {
    lua = { 'stylua' },
    python = { 'isort', 'black' },
    go = { 'goimports', 'gofmt' },
    javascript = { 'prettierd' },
    javascriptreact = { { 'prettierd', 'prettier' } },
    typescript = { { 'prettierd', 'prettier' } },
    typescriptreact = { { 'prettierd', 'prettier' } },
  },
}
