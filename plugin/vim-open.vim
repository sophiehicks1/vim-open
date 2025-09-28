" vim-open plugin - enhances the built-in gf command
" Maintainer: Sophie Hicks
" License: MIT

if exists('g:loaded_vim_open') || &cp
  finish
endif
let g:loaded_vim_open = 1

" Override the default gf mapping with expression mapping
nnoremap <silent> gf :call gopher#go()<CR>

" Optional: also override gF for opening in new tab
nnoremap <silent> gF :call gopher#go_tab()<CR>
