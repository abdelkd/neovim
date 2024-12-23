-- Enhanced hover documentation configuration for Neovim
local function enhanced_hover_setup()
  -- Create custom highlight groups for hover window
  vim.api.nvim_command([[
    highlight HoverNormal guibg=#1a1b26 guifg=#c0caf5
    highlight HoverBorder guifg=#7aa2f7
    highlight HoverHeading guifg=#7dcfff gui=bold
    highlight HoverParam guifg=#9ece6a
    highlight HoverType guifg=#bb9af7
    highlight HoverOperator guifg=#89ddff
  ]])

  -- Configure the floating window styling
  local hover_config = {
    -- Floating window border styling
    border = {
      { '╭', 'HoverBorder' },
      { '─', 'HoverBorder' },
      { '╮', 'HoverBorder' },
      { '│', 'HoverBorder' },
      { '╯', 'HoverBorder' },
      { '─', 'HoverBorder' },
      { '╰', 'HoverBorder' },
      { '│', 'HoverBorder' },
    },

    -- Maximum dimensions
    max_width = 80,
    max_height = 20,

    -- Minimum dimensions
    min_width = 40,
    min_height = 5,
  }

  -- Enhanced hover handler
  local function enhanced_hover()
    -- Store original hover config
    local orig_hover_config = vim.lsp.handlers['textDocument/hover']

    -- Create new hover handler
    vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(function(_, result, ctx, config)
      config = config or {}
      config.border = hover_config.border
      config.max_width = hover_config.max_width
      config.max_height = hover_config.max_height

      -- If no hover result, show message
      if not result or not result.contents then
        vim.notify('No hover information available', vim.log.levels.INFO)
        return
      end

      -- Enhanced markdown rendering
      local markdown_lines = vim.lsp.util.convert_input_to_markdown_lines(result.contents)
      markdown_lines = vim.lsp.util.trim_empty_lines(markdown_lines)

      -- Apply syntax highlighting
      for i, line in ipairs(markdown_lines) do
        -- Highlight headings
        if line:match('^#') then
          markdown_lines[i] = line:gsub('^(#+%s*.+)$', '%%#HoverHeading#%1%%#HoverNormal#')
        end

        -- Highlight parameters
        markdown_lines[i] = line:gsub('(@param%s+)(%w+)', '%%#HoverOperator#%1%%#HoverParam#%2%%#HoverNormal#')

        -- Highlight types
        markdown_lines[i] =
          line:gsub('(%s+[:%->]%s+)([%w%[%]%.%s]+)', '%%#HoverOperator#%1%%#HoverType#%2%%#HoverNormal#')
      end

      -- Calculate window dimensions
      local width = math.min(
        hover_config.max_width,
        math.max(
          hover_config.min_width,
          vim.fn.max(vim.tbl_map(function(line)
            return vim.fn.strdisplaywidth(line)
          end, markdown_lines))
        )
      )

      local height = math.min(hover_config.max_height, math.max(hover_config.min_height, #markdown_lines))

      -- Create the floating window
      local bufnr = vim.api.nvim_create_buf(false, true)
      local winnr = vim.api.nvim_open_win(bufnr, false, {
        relative = 'cursor',
        row = 1,
        col = 0,
        width = width,
        height = height,
        style = 'minimal',
        border = config.border,
      })

      -- Set buffer options
      vim.api.nvim_buf_set_option(bufnr, 'bufhidden', 'wipe')
      vim.api.nvim_buf_set_option(bufnr, 'modifiable', true)
      vim.api.nvim_win_set_option(winnr, 'winhighlight', 'Normal:HoverNormal,FloatBorder:HoverBorder')

      -- Set content
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, markdown_lines)
      vim.api.nvim_buf_set_option(bufnr, 'modifiable', false)

      -- Add keymaps for navigation
      local function map(mode, lhs, rhs)
        vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, {
          noremap = true,
          silent = true,
        })
      end

      map('n', '<Esc>', ':q<CR>')
      map('n', 'q', ':q<CR>')
      map('n', '<C-d>', '<C-d>zz')
      map('n', '<C-u>', '<C-u>zz')

      -- Auto-close on cursor move
      local group = vim.api.nvim_create_augroup('LspHoverClose', { clear = true })
      vim.api.nvim_create_autocmd({ 'CursorMoved', 'BufHidden', 'InsertEnter' }, {
        group = group,
        buffer = vim.api.nvim_get_current_buf(),
        callback = function()
          pcall(vim.api.nvim_win_close, winnr, true)
        end,
      })

      return bufnr, winnr
    end, hover_config)
  end

  -- Set up keymaps
  local function setup_hover_keymaps()
    vim.keymap.set('n', 'K', function()
      vim.lsp.buf.hover()
    end, { desc = 'Show hover documentation' })

    vim.keymap.set('n', '<Leader>k', function()
      vim.lsp.buf.hover()
      -- Add a small delay to ensure the window is created
      vim.defer_fn(function()
        vim.cmd('norm! zt') -- Move window to top of screen
      end, 10)
    end, { desc = 'Show hover documentation at top' })
  end

  -- Initialize everything
  enhanced_hover()
  setup_hover_keymaps()

  -- Return config for modifications
  return hover_config
end

-- Add auto-resizing and better markdown support
local function setup_markdown_enhancements()
  -- Add markdown conceal settings
  vim.opt.conceallevel = 2
  vim.opt.concealcursor = 'nc'

  -- Better markdown highlighting
  vim.g.markdown_fenced_languages = {
    'vim',
    'lua',
    'cpp',
    'c',
    'python',
    'javascript',
    'typescript',
    'bash',
    'sh',
  }
end

-- Set up auto-sizing window
local function setup_auto_resize()
  vim.api.nvim_create_autocmd('VimResized', {
    pattern = '*',
    callback = function()
      local wins = vim.api.nvim_list_wins()
      for _, win in ipairs(wins) do
        local config = vim.api.nvim_win_get_config(win)
        if config.relative ~= '' then -- Is floating window
          -- Recalculate size based on content
          local buf = vim.api.nvim_win_get_buf(win)
          local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
          local width = math.min(
            80,
            math.max(
              40,
              vim.fn.max(vim.tbl_map(function(line)
                return vim.fn.strdisplaywidth(line)
              end, lines))
            )
          )
          local height = math.min(20, #lines)

          -- Update window size
          vim.api.nvim_win_set_config(win, {
            width = width,
            height = height,
          })
        end
      end
    end,
  })
end

-- Initialize everything
local M = {
  setup = function()
    local config = enhanced_hover_setup()
    setup_markdown_enhancements()
    setup_auto_resize()
    return config
  end,
}

return M
