" IDE、AI 和鼠标默认关闭
let g:ide_enabled = 0
let g:ai_enabled = 0
let g:coc_start_at_startup = 0
let g:copilot_enabled = 0
set completeopt=menuone,noinsert,noselect shortmess+=c
set mouse=

" CoC
let g:java_ignore_markdown = 1
let g:coc_global_extensions = [
      \ 'coc-go', 'coc-pyright', 'coc-tsserver', '@yaegassy/coc-volar',
      \ 'coc-java', 'coc-rust-analyzer', 'coc-json', 'coc-prettier',
      \ ]
" 项目和 Gradle：优先使用当前终端的 JAVA_HOME
let g:vim_java_home = !empty($JAVA_HOME)
      \ ? $JAVA_HOME
      \ : trim(system('/usr/libexec/java_home -v 17'))

" JDT.LS：自动寻找 Java 21
let g:vim_java_tooling_home =
      \ trim(system('/usr/libexec/java_home -v 21'))
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
    if !isdirectory(g:vim_config_root . '/plugged/copilot.vim')
      echom 'Copilot 插件未安装，请运行 bootstrap.sh'
      return
    endif

    silent! Copilot enable
    call copilot#Client()
    call copilot#OnFileType()
    let g:ai_enabled = 1
    echom 'AI 已开启'
    return
  endif

  let g:ai_enabled = 0
  silent! Copilot disable
  silent! call copilot#Clear()
  let l:client = copilot#RunningClient()
  if l:client isnot v:null
    silent! call l:client.Close()
  endif
  echom 'AI 已关闭'
endfunction

function! TscuiteToggleMouse() abort
  let &mouse = empty(&mouse) ? 'a' : ''
  echom '鼠标已' . (empty(&mouse) ? '关闭' : '开启')
endfunction
