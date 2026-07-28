setlocal expandtab
setlocal tabstop=2
setlocal shiftwidth=2
setlocal softtabstop=2

let b:undo_ftplugin = get(b:, 'undo_ftplugin', '')
      \ . ' | setlocal expandtab< tabstop< shiftwidth< softtabstop<'
