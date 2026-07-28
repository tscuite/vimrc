function! s:Warn(message) abort
  echohl WarningMsg
  echom a:message
  echohl None
endfunction

let s:java_debug_pending = 0
let s:java_debug_attempts = 0
let s:java_debug_timer = -1
let s:java_debug_max_attempts = 120

function! s:CancelJavaDebugWait() abort
  if s:java_debug_timer != -1
    call timer_stop(s:java_debug_timer)
  endif
  let s:java_debug_pending = 0
  let s:java_debug_attempts = 0
  let s:java_debug_timer = -1
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
  if a:action ==# 'stop' && s:java_debug_pending
    call s:CancelJavaDebugWait()
    echom 'Cancelled pending Java debugger launch'
  endif

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

function! s:ScheduleJavaDebugRetry() abort
  let s:java_debug_timer = timer_start(
        \ 5000,
        \ function('<SID>TryJavaDebug'))
endfunction

function! s:JavaDebugResult(error, result) abort
  if !s:java_debug_pending
    return
  endif

  if empty(a:error)
    call s:CancelJavaDebugWait()
    return
  endif

  if a:error =~? 'Plugin not ready'
        \ && s:java_debug_attempts < s:java_debug_max_attempts
    if s:java_debug_attempts == 1 || s:java_debug_attempts % 6 == 0
      echom 'Waiting for coc-java to finish importing the project... (\ds cancels)'
    endif
    call s:ScheduleJavaDebugRetry()
    return
  endif

  call s:CancelJavaDebugWait()
  call s:Warn('Unable to start Java debugger: ' . a:error)
endfunction

function! s:TryJavaDebug(timer) abort
  let s:java_debug_timer = -1
  if !s:java_debug_pending
    return
  endif

  let s:java_debug_attempts += 1
  if s:java_debug_attempts > s:java_debug_max_attempts
    call s:CancelJavaDebugWait()
    call s:Warn(
          \ 'coc-java did not become ready within 10 minutes. '
          \ . 'Check :CocInfo and :CocOpenLog')
    return
  endif

  if !exists('*CocActionAsync') || !exists('*coc#rpc#ready')
        \ || !coc#rpc#ready()
    if s:java_debug_attempts == 1 || s:java_debug_attempts % 6 == 0
      echom 'Waiting for CoC to start... (\ds cancels)'
    endif
    call s:ScheduleJavaDebugRetry()
    return
  endif

  try
    call CocActionAsync(
          \ 'runCommand',
          \ 'java.debug.vimspector.start',
          \ json_encode({'configuration': 'launch', 'args': ''}),
          \ function('<SID>JavaDebugResult'))
  catch
    call s:CancelJavaDebugWait()
    call s:Warn('Unable to request Java debugger: ' . v:exception)
  endtry
endfunction

function! vimconfig#debug#java() abort
  if s:java_debug_pending
    echom 'Java debugger is already waiting for coc-java (\ds cancels)'
    return
  endif

  if !vimconfig#debug#ensure_vimspector()
    return
  endif

  let s:java_debug_pending = 1
  let s:java_debug_attempts = 0
  echom 'Starting Java debugger with coc-java...'
  call s:TryJavaDebug(0)
endfunction
