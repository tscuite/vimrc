let g:coc_global_extensions = [
      \ 'coc-go',
      \ 'coc-pyright',
      \ 'coc-tsserver',
      \ '@yaegassy/coc-volar',
      \ 'coc-java',
      \ 'coc-java-debug',
      \ 'coc-rust-analyzer',
      \ 'coc-json',
      \ 'coc-eslint',
      \ 'coc-prettier',
      \ '@yaegassy/coc-ruff',
      \ ]

" Prefer the user's existing Java 17. VIM_JAVA_HOME keeps this portable,
" while the explicit Zulu path matches the primary macOS workstation.
function! s:IsJava17Home(java_home) abort
  if !executable(a:java_home . '/bin/java')
        \ || !executable(a:java_home . '/bin/javac')
        \ || !filereadable(a:java_home . '/release')
    return 0
  endif

  return match(
        \ readfile(a:java_home . '/release', '', 10),
        \ '^JAVA_VERSION="17\.') >= 0
endfunction

function! s:FindJava17Home() abort
  let l:candidates = []
  if exists('$VIM_JAVA_HOME') && !empty($VIM_JAVA_HOME)
    call add(l:candidates, expand($VIM_JAVA_HOME))
  endif
  if has('macunix')
    call add(
          \ l:candidates,
          \ '/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home')
  endif
  if exists('$JAVA_HOME') && !empty($JAVA_HOME)
    call add(l:candidates, expand($JAVA_HOME))
  endif

  for l:java_home in l:candidates
    if s:IsJava17Home(l:java_home)
      return resolve(l:java_home)
    endif
  endfor

  if has('macunix') && executable('/usr/libexec/java_home')
    let l:java_home = trim(system('/usr/libexec/java_home -v 17 2>/dev/null'))
    if !v:shell_error && s:IsJava17Home(l:java_home)
      return resolve(l:java_home)
    endif
  endif

  return ''
endfunction

let g:vim_java_home = s:FindJava17Home()
if !empty(g:vim_java_home)
  let g:coc_user_config = get(g:, 'coc_user_config', {})
  let g:coc_user_config['java.jdt.ls.java.home'] = g:vim_java_home
  let g:coc_user_config['java.import.gradle.java.home'] = g:vim_java_home
  let g:coc_user_config['java.configuration.runtimes'] = [
        \ {
        \   'name': 'JavaSE-17',
        \   'path': g:vim_java_home,
        \   'default': v:true,
        \ },
        \ ]
endif

function! s:CheckBackspace() abort
  let l:column = col('.') - 1
  return !l:column || getline('.')[l:column - 1] =~# '\s'
endfunction

function! s:CocTab() abort
  try
    if coc#pum#visible()
      return coc#pum#next(1)
    endif
    return s:CheckBackspace() ? "\<Tab>" : coc#refresh()
  catch /^Vim\%((\a\+)\)\=:E117/
    return "\<Tab>"
  endtry
endfunction

function! s:CocShiftTab() abort
  try
    if coc#pum#visible()
      return coc#pum#prev(1)
    endif
  catch /^Vim\%((\a\+)\)\=:E117/
  endtry
  return "\<C-D>"
endfunction

function! s:CocEnter() abort
  try
    if coc#pum#visible()
      return coc#pum#confirm()
    endif
  catch /^Vim\%((\a\+)\)\=:E117/
  endtry
  return "\<C-G>u\<CR>"
endfunction

function! s:CocRefresh() abort
  try
    return coc#refresh()
  catch /^Vim\%((\a\+)\)\=:E117/
    return "\<C-K>"
  endtry
endfunction

function! s:CopilotAccept() abort
  try
    return copilot#Accept("\<CR>")
  catch /^Vim\%((\a\+)\)\=:E117/
    return "\<CR>"
  endtry
endfunction

inoremap <silent><expr> <Tab> <SID>CocTab()
inoremap <silent><expr> <S-Tab> <SID>CocShiftTab()
inoremap <silent><expr> <CR> <SID>CocEnter()
inoremap <silent><expr> <C-K> <SID>CocRefresh()
inoremap <silent><expr> <C-J> <SID>CopilotAccept()

function! s:WarnCocUnavailable() abort
  echohl WarningMsg
  echom 'CoC is unavailable. Run ~/.vim/scripts/bootstrap.sh'
  echohl None
endfunction

function! s:CocActionAsync(action) abort
  if exists('*CocActionAsync')
    call CocActionAsync(a:action)
  else
    call s:WarnCocUnavailable()
  endif
endfunction

function! s:ShowDocumentation() abort
  if index(['vim', 'help'], &filetype) >= 0
    try
      execute 'help ' . expand('<cword>')
      return
    catch /^Vim\%((\a\+)\)\=:E149/
    endtry
  endif

  if exists('*CocActionAsync')
    call CocActionAsync('doHover')
  else
    normal! K
  endif
endfunction

function! s:CocList(source) abort
  if exists(':CocList') == 2
    execute 'CocList ' . a:source
  else
    call s:WarnCocUnavailable()
  endif
endfunction

nnoremap <silent> gd :call <SID>CocActionAsync('jumpDefinition')<CR>
nnoremap <silent> gr :call <SID>CocActionAsync('jumpReferences')<CR>
nnoremap <silent> gi :call <SID>CocActionAsync('jumpImplementation')<CR>
nnoremap <silent> K :call <SID>ShowDocumentation()<CR>

nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

nmap <silent> <leader>a <Plug>(coc-codeaction-cursor)
xmap <silent> <leader>a <Plug>(coc-codeaction-selected)
nnoremap <silent> <leader>r :call <SID>CocActionAsync('rename')<CR>
nnoremap <silent> <leader>= :call <SID>CocActionAsync('format')<CR>
xmap <silent> <leader>= <Plug>(coc-format-selected)
nnoremap <silent> <leader>l :call <SID>CocList('diagnostics')<CR>
nnoremap <silent> <leader>o :call <SID>CocList('outline')<CR>
