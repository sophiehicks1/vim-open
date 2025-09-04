#!/usr/bin/env vim -s

" Test script for vim-open plugin
set runtimepath+=/home/runner/work/vim-open/vim-open
source /home/runner/work/vim-open/vim-open/plugin/vim-open.vim

" Test the functions exist
try
  echo "Testing gopher#add_finder function..."
  call gopher#add_finder(function('len'), function('len'))
  echo "OK: gopher#add_finder works"
catch
  echo "ERROR: gopher#add_finder failed: " . v:exception
endtry

try
  echo "Testing gopher#add_opener function..."
  call gopher#add_opener(function('len'), function('len'))
  echo "OK: gopher#add_opener works"
catch
  echo "ERROR: gopher#add_opener failed: " . v:exception
endtry

" Test context creation by calling gopher#go on README.md
edit README.md
try
  call gopher#go()
  echo "OK: gopher#go function works"
catch
  echo "ERROR: gopher#go failed: " . v:exception
endtry

quit!