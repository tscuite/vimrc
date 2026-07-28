setlocal expandtab
setlocal tabstop=4
setlocal shiftwidth=4
setlocal softtabstop=4
setlocal colorcolumn=88

let b:undo_ftplugin = get(b:, 'undo_ftplugin', '')
      \ . ' | setlocal expandtab< tabstop< shiftwidth< softtabstop< colorcolumn<'
