setlocal expandtab
setlocal tabstop=4
setlocal shiftwidth=4
setlocal softtabstop=4

nnoremap <silent><buffer> <leader>dd :call vimconfig#debug#java()<CR>

let b:undo_ftplugin = get(b:, 'undo_ftplugin', '')
      \ . ' | setlocal expandtab< tabstop< shiftwidth< softtabstop<'
      \ . ' | silent! nunmap <buffer> <leader>dd'
