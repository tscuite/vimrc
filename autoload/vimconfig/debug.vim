function! s:Warn(message) abort
  echohl WarningMsg
  echom a:message
  echohl None
endfunction

function! vimconfig#debug#ensure_vimspector() abort
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

function! vimconfig#debug#run(action) abort
  if !vimconfig#debug#ensure_vimspector()
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
    else
      call s:Warn('Unknown debug action: ' . a:action)
    endif
  catch
    call s:Warn('Vimspector error: ' . v:exception)
  endtry
endfunction

function! vimconfig#debug#java() abort
  if !vimconfig#debug#ensure_vimspector()
    return
  endif

  if !exists('*CocActionAsync') || !exists('*coc#rpc#ready')
        \ || !coc#rpc#ready()
    call s:Warn('CoC is still starting. Wait for coc-java, then retry \dd')
    return
  endif

  echom 'Starting Java debugger with coc-java...'
  try
    call CocActionAsync(
          \ 'runCommand',
          \ 'java.debug.vimspector.start',
          \ json_encode({'configuration': 'launch', 'args': ''}))
  catch
    call s:Warn('Unable to start Java debugger: ' . v:exception)
  endtry
endfunction
