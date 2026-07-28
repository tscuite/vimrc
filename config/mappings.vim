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

function! s:EnsureVimspector() abort
  if !has('python3')
    call s:Warn('Vimspector requires Vim compiled with +python3')
    return 0
  endif
  if !exists('*plug#load')
    call s:Warn('Vimspector is unavailable. Run ~/.vim/scripts/bootstrap.sh')
    return 0
  endif
  if !exists('g:loaded_vimpector')
    try
      call plug#load('vimspector')
    catch
      call s:Warn('Unable to load Vimspector: ' . v:exception)
      return 0
    endtry
  endif
  return 1
endfunction

function! s:Debug(action) abort
  if !s:EnsureVimspector()
    return
  endif

  try
    if a:action ==# 'continue'
      call vimspector#Continue()
    elseif a:action ==# 'breakpoint'
      call vimspector#ToggleBreakpoint()
    elseif a:action ==# 'step-over'
      call vimspector#StepOver()
    elseif a:action ==# 'step-in'
      call vimspector#StepInto()
    elseif a:action ==# 'step-out'
      call vimspector#StepOut()
    elseif a:action ==# 'stop'
      call vimspector#Stop()
    endif
  catch
    call s:Warn('Vimspector error: ' . v:exception)
  endtry
endfunction

nnoremap <silent> <leader>dd :call <SID>Debug('continue')<CR>
nnoremap <silent> <leader>db :call <SID>Debug('breakpoint')<CR>
nnoremap <silent> <leader>dn :call <SID>Debug('step-over')<CR>
nnoremap <silent> <leader>di :call <SID>Debug('step-in')<CR>
nnoremap <silent> <leader>do :call <SID>Debug('step-out')<CR>
nnoremap <silent> <leader>ds :call <SID>Debug('stop')<CR>
