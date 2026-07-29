set nomore
let s:ide = get(g:, 'enable_ide', -1)

call assert_true(index([0, 1], s:ide) >= 0, 'IDE switch must be 0 or 1')
call assert_equal('\', get(g:, 'mapleader', ''), 'Leader must be backslash')
call assert_true(&number, 'Line numbers must be enabled')
call assert_true(&hidden, 'Hidden buffers must be enabled')
call assert_equal(300, &updatetime, 'updatetime')
call assert_equal(500, &timeoutlen, 'timeoutlen')
call assert_equal('yes', &signcolumn, 'signcolumn')
call assert_false(&termguicolors, 'Keep terminal-controlled colors')
call assert_equal('light', &background, 'Keep the original background')
call assert_equal('default', get(g:, 'colors_name', 'default'), 'colorscheme')
call assert_equal('', synIDattr(hlID('SignColumn'), 'bg', 'cterm'))
call assert_equal('', synIDattr(hlID('SignColumn'), 'bg', 'gui'))
call assert_equal(1, get(g:, 'java_ignore_markdown', 0))

for s:key in [
      \ '\p', '\f', '\b', '\h', '\e', '\c',
      \ '\gs', '\gd', '\gb', '\gp',
      \ '\w', '\q', '\x', '[b', ']b',
      \ ]
  call assert_false(empty(maparg(s:key, 'n')), 'Missing mapping: ' . s:key)
endfor

let s:ide_keys = ['gd', 'gr', 'gi', 'K', '[g', ']g',
      \ '\a', '\r', '\=', '\l', '\o']
if s:ide
  call assert_true(exists('g:coc_global_extensions'), 'CoC extensions missing')
  for s:extension in [
        \ 'coc-go',
        \ 'coc-pyright',
        \ 'coc-tsserver',
        \ '@yaegassy/coc-volar',
        \ 'coc-java',
        \ 'coc-rust-analyzer',
        \ 'coc-json',
        \ 'coc-eslint',
        \ 'coc-prettier',
        \ '@yaegassy/coc-ruff',
        \ ]
    call assert_true(
          \ index(g:coc_global_extensions, s:extension) >= 0,
          \ 'Missing CoC extension: ' . s:extension)
  endfor
  for s:key in s:ide_keys
    call assert_false(empty(maparg(s:key, 'n')), 'Missing IDE mapping: ' . s:key)
  endfor
  for s:key in ['<Tab>', '<S-Tab>', '<CR>', '<C-K>', '<C-J>']
    call assert_false(empty(maparg(s:key, 'i')), 'Missing insert mapping: ' . s:key)
  endfor
  call assert_equal(
        \ g:vim_config_root . '/scripts/rust-analyzer-wrapper.sh',
        \ get(g:coc_user_config, 'rust-analyzer.server.path', ''))

  let s:zulu_17 = '/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home'
  let s:zulu_21 = '/Library/Java/JavaVirtualMachines/zulu-21.jdk/Contents/Home'
  if executable(s:zulu_17 . '/bin/javac')
    call assert_equal(s:zulu_17, g:vim_java_home)
    call assert_equal(
          \ s:zulu_17,
          \ get(g:coc_user_config, 'java.import.gradle.java.home', ''))
  endif
  if executable(s:zulu_21 . '/bin/javac')
    call assert_equal(s:zulu_21, g:vim_java_tooling_home)
    call assert_equal(
          \ s:zulu_21,
          \ get(g:coc_user_config, 'java.jdt.ls.java.home', ''))
  endif
else
  call assert_false(exists('g:coc_global_extensions'))
  call assert_false(exists('g:coc_user_config'))
  call assert_true(empty(maparg('gd', 'n')), 'IDE mappings must stay unloaded')
endif

call assert_false(exists('g:plug_url_format'), 'Plugin mirror must be disabled')
for s:key in ['\dd', '\db', '\dn', '\di', '\do', '\ds']
  call assert_true(empty(maparg(s:key, 'n')), 'Unexpected debug mapping: ' . s:key)
endfor
for s:key in ["\<F2>", "\<F5>", "\<F9>", "\<F10>", "\<F11>", "\<F12>"]
  call assert_true(empty(maparg(s:key, 'n')), 'Unexpected function-key mapping')
endfor

function! s:AssertIndent(filetype, width, uses_spaces) abort
  enew!
  setlocal filetype=
  execute 'setfiletype ' . a:filetype
  call assert_equal(a:width, &l:shiftwidth, a:filetype . ' shiftwidth')
  call assert_equal(a:width, &l:tabstop, a:filetype . ' tabstop')
  call assert_equal(a:uses_spaces, &l:expandtab, a:filetype . ' expandtab')
  bwipeout!
endfunction

call s:AssertIndent('go', 4, 0)
call s:AssertIndent('python', 4, 1)
call s:AssertIndent('javascript', 2, 1)
call s:AssertIndent('typescript', 2, 1)
call s:AssertIndent('vue', 2, 1)
call s:AssertIndent('java', 4, 1)
call s:AssertIndent('rust', 4, 1)
call s:AssertIndent('dockerfile', 4, 1)

enew!
setfiletype markdown
call assert_equal(2, &l:shiftwidth, 'markdown shiftwidth')
call assert_true(&l:wrap, 'Markdown must wrap')
call assert_true(&l:linebreak, 'Markdown must use linebreak')
bwipeout!

call writefile(v:errors, $VIM_TEST_ERRORS)
if !empty(v:errors)
  cquit
endif
qa!
