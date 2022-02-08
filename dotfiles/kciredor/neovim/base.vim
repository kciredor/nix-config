" Expanding on Neovim's sane defaults.
set guioptions=M           " disables gui (speed).
set shortmess+=I           " disable opening screen.
set number                 " show line numbers.
set hidden                 " switch buffers without saving.
set scrolloff=3            " edge scroll.
set ignorecase             " search without case.
set smartcase              " even smarter search.
set gdefault               " global matching.
set sw=4 ts=4              " shift width, tab stop.
set expandtab              " tabs are spaces..
set list listchars=tab:>-  " ..unless they are not.
set nomodeline             " bad idea

" Keys.
let g:mapleader = ","

nmap <Left>  <C-w>h
nmap <Down>  <C-w>j
nmap <Up>    <C-w>k
nmap <Right> <C-w>l

nnoremap Q <Nop>
nnoremap <F3>  :set hlsearch!<CR>
nnoremap <F10> :set paste!<CR>

xmap < <gv
xmap > >gv

cmap w!! w !sudo tee % > /dev/null

" File specifics.
autocmd Filetype python      let &colorcolumn = "80,".join(range(101,999),",")
autocmd Filetype yaml        setlocal sw=2 ts=2
autocmd Filetype html        setlocal expandtab!
autocmd Filetype htmldjango  setlocal expandtab!
autocmd Filetype css         setlocal sw=2 ts=2
autocmd Filetype javascript  setlocal sw=2 ts=2

" Theme.
colorscheme tokyonight
