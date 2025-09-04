" gopher.vim - Core functionality for vim-open plugin
" Maintainer: Sophie Hicks

" Storage for finders and openers
let s:finders = []
let s:openers = []

" Add a finder function
function! gopher#add_finder(match_fn, extract_fn)
  call add(s:finders, {'match': a:match_fn, 'extract': a:extract_fn})
endfunction

" Add an opener function
function! gopher#add_opener(can_handle_fn, handler)
  call add(s:openers, {'can_handle': a:can_handle_fn, 'handler': a:handler})
endfunction

" Create context object for current cursor position
function! s:create_context()
  let context = {}
  let context.filetype = &filetype
  let context.line = getline('.')
  let context.col = col('.')
  let context.lnum = line('.')
  let context.word = expand('<cword>')
  let context.cfile = expand('<cfile>')
  let context.filename = expand('%:p')
  
  " Get the word under cursor with more context
  let line = getline('.')
  let col = col('.') - 1
  
  " Find word boundaries
  let start = col
  let end = col
  
  " Move start back to beginning of word/URL
  while start > 0 && line[start-1] !~ '\s'
    let start -= 1
  endwhile
  
  " Move end forward to end of word/URL
  while end < len(line) && line[end] !~ '\s'
    let end += 1
  endwhile
  
  let context.current_word = strpart(line, start, end - start)
  
  return context
endfunction

" Main function called by gf mapping
function! gopher#go()
  let context = s:create_context()
  
  " Try each finder in order
  for finder in s:finders
    if finder.match(context)
      let resource = finder.extract(context)
      if !empty(resource)
        " Try each opener in order
        for opener in s:openers
          if opener.can_handle(resource)
            call opener.handler(resource)
            return
          endif
        endfor
      endif
    endif
  endfor
  
  " If no finder/opener handled it, fall back to default gf
  normal! gf
endfunction

" Function for opening in new tab (gF)
function! gopher#go_tab()
  let context = s:create_context()
  
  " Try each finder in order
  for finder in s:finders
    if finder.match(context)
      let resource = finder.extract(context)
      if !empty(resource)
        " Try each opener in order, but check if it's a file first
        for opener in s:openers
          if opener.can_handle(resource)
            " If it's a file, open in new tab, otherwise use normal handler
            if resource =~ '^/' || resource =~ '^\~' || resource =~ '^\.'
              execute 'tabnew ' . resource
              return
            else
              call opener.handler(resource)
              return
            endif
          endif
        endfor
      endif
    endif
  endfor
  
  " If no finder/opener handled it, fall back to default gF
  normal! gF
endfunction

" Initialize default finders and openers
function! s:init_defaults()
  " HTTP(S) URL finder
  call gopher#add_finder(
    \ function('s:is_http_url'),
    \ function('s:extract_http_url')
  \ )
  
  " Fallback finder for everything else
  call gopher#add_finder(
    \ function('s:is_fallback'),
    \ function('s:extract_fallback')
  \ )
  
  " Browser opener for HTTP(S) URLs
  call gopher#add_opener(
    \ function('s:can_open_url'),
    \ function('s:open_url')
  \ )
  
  " File opener for local files
  call gopher#add_opener(
    \ function('s:can_open_file'),
    \ function('s:open_file')
  \ )
endfunction

" Default finder functions
function! s:is_http_url(context)
  return a:context.current_word =~? '^https\?://'
endfunction

function! s:extract_http_url(context)
  " Extract the full URL even if cursor is in the middle
  let line = a:context.line
  let col = a:context.col - 1
  
  " Find the start of the URL
  let start = col
  while start > 0 && line[start-1] !~ '\s'
    let start -= 1
  endwhile
  
  " Find the end of the URL  
  let end = col
  while end < len(line) && line[end] !~ '\s'
    let end += 1
  endwhile
  
  let url = strpart(line, start, end - start)
  
  " Clean up common trailing punctuation that's not part of the URL
  let url = substitute(url, '[.,;:!?)\]}>]*$', '', '')
  
  return url
endfunction

function! s:is_fallback(context)
  return 1  " Always matches as fallback
endfunction

function! s:extract_fallback(context)
  return a:context.cfile
endfunction

" Default opener functions
function! s:can_open_url(resource)
  return a:resource =~? '^https\?://'
endfunction

function! s:open_url(resource)
  if has('macunix')
    call system('open ' . shellescape(a:resource))
  elseif has('unix')
    call system('xdg-open ' . shellescape(a:resource))
  elseif has('win32') || has('win64')
    call system('start ' . shellescape(a:resource))
  else
    echo 'Cannot open URL: ' . a:resource
  endif
endfunction

function! s:can_open_file(resource)
  return !empty(a:resource) && a:resource !~? '^https\?://'
endfunction

function! s:open_file(resource)
  try
    " Handle relative paths and expand them properly
    let file_path = fnamemodify(a:resource, ':p')
    if filereadable(a:resource) || filereadable(file_path)
      execute 'edit ' . fnameescape(a:resource)
    else
      " If file doesn't exist, still try to open it (vim will create new file)
      execute 'edit ' . fnameescape(a:resource)
    endif
  catch
    echo 'Cannot open file: ' . a:resource . ' (' . v:exception . ')'
  endtry
endfunction

" Initialize the plugin
call s:init_defaults()