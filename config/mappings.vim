function! s:Warn(message) abort
  echohl WarningMsg
  echom a:message
  echohl None
endfunction

function! s:RunCommand(command) abort
  let l:name = matchstr(a:command, '^\S\+')
  if exists(':' . l:name) != 2
    call s:Warn('Command unavailable: ' . l:name)
    return
  endif
  execute a:command
endfunction

nnoremap <silent> <leader>p :<C-U>call <SID>RunCommand('Files')<CR>
nnoremap <silent> <leader>f :<C-U>call <SID>RunCommand('Rg')<CR>
nnoremap <silent> <leader>b :<C-U>call <SID>RunCommand('Buffers')<CR>
nnoremap <silent> <leader>h :<C-U>call <SID>RunCommand('History')<CR>
nnoremap <silent> <leader>e :<C-U>call <SID>RunCommand('NERDTreeToggle')<CR>
nnoremap <silent> <leader>c :<C-U>call <SID>RunCommand('Commands')<CR>

nnoremap <silent> <leader>gs :<C-U>call <SID>RunCommand('Git')<CR>
nnoremap <silent> <leader>gd :<C-U>call <SID>RunCommand('Gdiffsplit')<CR>
nnoremap <silent> <leader>gb :<C-U>call <SID>RunCommand('Git blame')<CR>
nnoremap <silent> <leader>gp :<C-U>call <SID>RunCommand('GitGutterPreviewHunk')<CR>

nnoremap <silent> <leader>w :write<CR>
nnoremap <silent> <leader>q :quit<CR>
nnoremap <silent> <leader>x :xit<CR>

nnoremap <silent> [b :bprevious<CR>
nnoremap <silent> ]b :bnext<CR>

nnoremap <silent> <leader>dd :call vimconfig#debug#run('continue')<CR>
nnoremap <silent> <leader>db :call vimconfig#debug#run('breakpoint')<CR>
nnoremap <silent> <leader>dn :call vimconfig#debug#run('step-over')<CR>
nnoremap <silent> <leader>di :call vimconfig#debug#run('step-in')<CR>
nnoremap <silent> <leader>do :call vimconfig#debug#run('step-out')<CR>
nnoremap <silent> <leader>ds :call vimconfig#debug#run('stop')<CR>
