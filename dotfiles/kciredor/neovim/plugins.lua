-- lualine
require('lualine').setup()

-- bufferline
require('bufferline').setup({
  options = {
    show_close_icon = false,
  }
})

-- nvim-tree
require("nvim-tree").setup({
  sort_by = "case_sensitive",
  view = {
    adaptive_size = true,
    side = "right",
  },
  renderer = {
    add_trailing = true,
    highlight_opened_files = "name",
  },
})

-- treesitter
require'nvim-treesitter.configs'.setup({
  highlight = {
    enable = true,
  },
})
