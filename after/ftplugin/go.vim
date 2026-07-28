setlocal noexpandtab
setlocal tabstop=4
setlocal shiftwidth=4
setlocal softtabstop=0

let b:undo_ftplugin = get(b:, 'undo_ftplugin', '')
      \ . ' | setlocal expandtab< tabstop< shiftwidth< softtabstop<'
