if exists('g:loaded_tscuite_vimrc')
  finish
endif
let g:loaded_tscuite_vimrc = 1

set nocompatible

let mapleader = '\'
let maplocalleader = '\'

let s:vimrc_path = resolve(expand('<sfile>:p'))
let g:vim_config_root = fnamemodify(s:vimrc_path, ':h')
execute 'set runtimepath^=' . fnameescape(g:vim_config_root)
let s:after_path = g:vim_config_root . '/after'
if index(split(&runtimepath, ','), s:after_path) < 0
  execute 'set runtimepath+=' . fnameescape(s:after_path)
endif

let s:modules = ['options', 'plugins', 'coc', 'ui', 'mappings', 'autocmds']
for s:module in s:modules
  let s:path = g:vim_config_root . '/config/' . s:module . '.vim'
  if filereadable(s:path)
    execute 'source ' . fnameescape(s:path)
  else
    echohl WarningMsg
    echom 'Vim config module not found: ' . s:path
    echohl None
  endif
endfor

unlet s:path
unlet s:module
unlet s:modules
unlet s:after_path
unlet s:vimrc_path
