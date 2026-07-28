function! s:RestoreCursor() abort
  let l:last_position = line("'\"")
  if l:last_position > 1 && l:last_position <= line('$')
    execute 'normal! g`"'
  endif
endfunction

function! s:CocHighlight() abort
  if exists('*CocActionAsync')
    silent! call CocActionAsync('highlight')
  endif
endfunction

augroup tscuite_general
  autocmd!
  autocmd BufReadPost * call <SID>RestoreCursor()
  autocmd FocusGained,BufEnter * silent! checktime
augroup END

augroup tscuite_coc
  autocmd!
  autocmd CursorHold * call <SID>CocHighlight()
augroup END
