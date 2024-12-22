-- require('kareem.plugins.alpha')
-- require('kareem.plugins.auto-session')
require('kareem.plugins.autocommands')
-- require('kareem.plugins.autopairs')
require('kareem.plugins.bufferline')
require('kareem.plugins.comment')
require('kareem.plugins.completion')
require('kareem.plugins.conform')
-- require('kareem.plugins.gitsigns')
require('kareem.plugins.indent-blankline')
require('kareem.plugins.language')
-- require('kareem.plugins.linting')
require('kareem.plugins.lualine')
require('kareem.plugins.nvim-tree')
require('kareem.plugins.nvim-treesitter')
require('kareem.plugins.substitute')
require('kareem.plugins.surround')
require('kareem.plugins.telescope')
require('kareem.plugins.todo-comments')
require('kareem.plugins.trouble')

require('kareem.plugins.keymaps').setup()

require('dressing').setup()
require('mini.icons').setup {
  file = {
    ['.eslintrc.js'] = { glyph = '󰱺', hl = 'MiniIconsYellow' },
    ['.node-version'] = { glyph = '', hl = 'MiniIconsGreen' },
    ['.prettierrc'] = { glyph = '', hl = 'MiniIconsPurple' },
    ['.yarnrc.yml'] = { glyph = '', hl = 'MiniIconsBlue' },
    ['eslint.config.js'] = { glyph = '󰱺', hl = 'MiniIconsYellow' },
    ['package.json'] = { glyph = '', hl = 'MiniIconsGreen' },
    ['tsconfig.json'] = { glyph = '', hl = 'MiniIconsAzure' },
    ['tsconfig.build.json'] = { glyph = '', hl = 'MiniIconsAzure' },
    ['yarn.lock'] = { glyph = '', hl = 'MiniIconsBlue' },
  },
}
