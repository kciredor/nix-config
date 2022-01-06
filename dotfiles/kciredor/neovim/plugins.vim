" bufferline
set termguicolors
nnoremap <silent><C-l> :BufferLineCycleNext<CR>
nnoremap <silent><C-h> :BufferLineCyclePrev<CR>
nmap <leader>d :bd<cr>

" nerdtree
let g:NERDTreeWinPos = "right"
nmap <silent> <leader>h :NERDTreeToggle<CR>

" fzfWrapper / fzf-vim
nmap <leader>o :Files<cr>
nmap <leader>O :Rg<cr>
nmap <leader>/ :Lines<cr>

" miniyank
let g:miniyank_filename = $HOME."/.config/nvim/miniyank.mpack"
let g:miniyank_maxitems = 100
map p <Plug>(miniyank-autoput)
map P <Plug>(miniyank-autoPut)
map <leader>p <Plug>(miniyank-startput)
map <leader>P <Plug>(miniyank-startPut)
map <leader>y <Plug>(miniyank-cycle)
map <leader>Y <Plug>(miniyank-cycleback)

" tagbar
nmap <silent> <leader>t :TagbarOpen fj<CR>
nmap <silent> <leader>T :TagbarClose<CR>

" vim-go
let g:go_fmt_command = "goimports"

" rust
let g:rustfmt_autosave = 1
