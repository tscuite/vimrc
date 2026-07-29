" 自动恢复位置和刷新外部修改
augroup tscuite_core
  autocmd!
  autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line('$') | execute 'normal! g`"' | endif
  autocmd FocusGained,BufEnter,CursorHold,CursorHoldI * silent! checktime
augroup END

" IDE 光标高亮
augroup tscuite_ide
  autocmd!
  autocmd CursorHold * if g:ide_enabled && exists('*CocActionAsync') | silent! call CocActionAsync('highlight') | endif
augroup END
