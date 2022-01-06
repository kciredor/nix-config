-- lualine
require('lualine').setup()

-- bufferline
require('bufferline').setup {
  options = {
    show_close_icon = false,
  }
}

-- treesitter
require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
  },
}
