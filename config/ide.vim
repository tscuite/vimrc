" IDE、AI 和鼠标默认关闭
let g:ide_enabled = 0
let g:ai_enabled = 0
let g:coc_start_at_startup = 0
let g:copilot_enabled = 0
let g:copilot_no_maps = 1
set completeopt=menuone,noinsert,noselect shortmess+=c
set mouse=

" CoC
let g:java_ignore_markdown = 1
let g:coc_global_extensions = [
      \ 'coc-go', 'coc-pyright', 'coc-tsserver', '@yaegassy/coc-volar',
      \ 'coc-java', 'coc-rust-analyzer', 'coc-json', 'coc-prettier',
      \ ]
let g:vim_java_home = expand(get(environ(), 'VIM_JAVA_HOME',
      \ '/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home'))
let g:vim_java_tooling_home = expand(get(environ(), 'VIM_JAVA_TOOLING_HOME',
      \ '/Library/Java/JavaVirtualMachines/zulu-21.jdk/Contents/Home'))
let g:coc_user_config = {
      \ 'rust-analyzer.server.path':
      \   g:vim_config_root . '/scripts/rust-analyzer-wrapper.sh',
      \ 'java.jdt.ls.java.home': g:vim_java_tooling_home,
      \ 'java.import.gradle.java.home': g:vim_java_home,
      \ 'java.import.gradle.arguments':
      \   '-Dorg.gradle.daemon.idletimeout=1000',
      \ 'java.configuration.runtimes': [
      \   {'name': 'JavaSE-17', 'path': g:vim_java_home, 'default': v:true},
      \ ],
      \ }

function! TscuiteCheckBackspace() abort
  let l:column = col('.') - 1
  return !l:column || getline('.')[l:column - 1] =~# '\s'
endfunction

function! TscuiteCoc(action, ...) abort
  if g:ide_enabled
    call CocActionAsync(a:action)
  elseif a:0
    execute 'normal! ' . a:1
  else
    echom 'IDE 未开启，请按 \i'
  endif
endfunction

function! TscuiteToggleIDE() abort
  if !g:ide_enabled
    if exists(':CocStart') != 2
      echom 'IDE 插件未安装，请运行 bootstrap.sh'
      return
    endif
    let g:ide_enabled = 1
    silent! CocStart
    echom 'IDE 已开启'
    return
  endif

  let g:ide_enabled = 0
  call coc#rpc#stop()
  echom 'IDE 已关闭'
endfunction

function! TscuiteToggleAI() abort
  if !g:ai_enabled
    if !exists('*plug#load')
      echom '请先运行 ~/.vim/scripts/bootstrap.sh'
      return
    endif
    call plug#load('copilot.vim')
    if exists(':Copilot') != 2
      echom 'AI 插件未安装，请运行 bootstrap.sh'
      return
    endif
    let g:ai_enabled = 1
    let g:copilot_enabled = 1
    silent! Copilot enable
    silent! Copilot restart
    echom 'AI 已开启'
    return
  endif

  let g:ai_enabled = 0
  let g:copilot_enabled = 0
  silent! Copilot disable
  try
    let l:copilot = copilot#RunningClient()
    if type(l:copilot) == v:t_dict && has_key(l:copilot, 'Close')
      call l:copilot.Close()
    endif
  catch
  endtry
  echom 'AI 已关闭'
endfunction

function! TscuiteToggleMouse() abort
  let &mouse = empty(&mouse) ? 'a' : ''
  echom '鼠标已' . (empty(&mouse) ? '关闭' : '开启')
endfunction
