set nocompatible
let mapleader = '\'
let g:vim_config_root = fnamemodify(resolve(expand('<sfile>:p')), ':h')
execute 'set runtimepath^=' . fnameescape(g:vim_config_root)
execute 'source ' . fnameescape(g:vim_config_root . '/config/ide.vim')
execute 'source ' . fnameescape(g:vim_config_root . '/config/plugins.vim')
execute 'source ' . fnameescape(g:vim_config_root . '/config/settings.vim')
execute 'source ' . fnameescape(g:vim_config_root . '/config/mappings.vim')
execute 'source ' . fnameescape(g:vim_config_root . '/config/filetypes.vim')
execute 'source ' . fnameescape(g:vim_config_root . '/config/autocmds.vim')
