set nomore

call assert_equal(0, get(g:, 'ide_enabled', -1), 'IDE must start disabled')
call assert_equal(0, get(g:, 'ai_enabled', -1), 'AI must start disabled')
call assert_equal(0, get(g:, 'coc_start_at_startup', -1))
call assert_equal(0, get(g:, 'copilot_enabled', -1))
call assert_equal('', &mouse, 'Mouse must start disabled')
call assert_equal('\', get(g:, 'mapleader', ''), 'Leader must be backslash')
call assert_false(&number, 'Line numbers must be disabled')
call assert_true(&hidden, 'Hidden buffers must be enabled')
call assert_equal(300, &updatetime, 'updatetime')
call assert_equal(500, &timeoutlen, 'timeoutlen')
call assert_equal('auto', &signcolumn, 'signcolumn')
call assert_equal('', get(g:, 'colors_name', ''), 'Do not force a colorscheme')
for s:encoding in ['ucs-bom', 'utf-8', 'gb18030', 'gbk', 'gb2312', 'cp936', 'latin1']
  call assert_true(index(split(&fileencodings, ','), s:encoding) >= 0,
        \ 'Missing file encoding: ' . s:encoding)
endfor
call assert_equal('', synIDattr(hlID('SignColumn'), 'bg', 'cterm'))
call assert_equal('', synIDattr(hlID('SignColumn'), 'bg', 'gui'))
call assert_equal('', synIDattr(hlID('FoldColumn'), 'bg', 'cterm'))
call assert_equal('', synIDattr(hlID('FoldColumn'), 'bg', 'gui'))
call assert_equal(1, get(g:, 'java_ignore_markdown', 0))

for s:key in [
      \ '\i', '\ai', '\m', '\p', '\f', '\b', '\h', '\e', '\c',
      \ '\gs', '\gd', '\gb', '\gp',
      \ '\w', '\q', '\x', '[b', ']b',
      \ ]
  call assert_false(empty(maparg(s:key, 'n')), 'Missing mapping: ' . s:key)
endfor
for s:key in ['gd', 'gr', 'gi', 'K', '[g', ']g',
      \ '\a', '\r', '\=', '\l', '\o']
  call assert_false(empty(maparg(s:key, 'n')), 'Missing IDE mapping: ' . s:key)
endfor
for s:key in ['<Tab>', '<S-Tab>', '<CR>', '<C-K>', '<C-J>']
  call assert_false(empty(maparg(s:key, 'i')), 'Missing insert mapping: ' . s:key)
endfor
call assert_match('g:ai_enabled', maparg('<C-J>', 'i'),
      \ 'Copilot accept must depend on the AI switch')

call assert_true(exists('g:coc_global_extensions'), 'CoC extensions missing')
for s:extension in [
      \ 'coc-go',
      \ 'coc-pyright',
      \ 'coc-tsserver',
      \ '@yaegassy/coc-volar',
      \ 'coc-java',
      \ 'coc-rust-analyzer',
      \ 'coc-json',
      \ 'coc-prettier',
      \ ]
  call assert_true(
        \ index(g:coc_global_extensions, s:extension) >= 0,
        \ 'Missing CoC extension: ' . s:extension)
endfor
call assert_true(index(g:coc_global_extensions, 'coc-eslint') < 0)
call assert_true(index(g:coc_global_extensions, '@yaegassy/coc-ruff') < 0)
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

call assert_false(exists('g:plug_url_format'), 'Plugin mirror must be disabled')
for s:key in ['\dd', '\db', '\dn', '\di', '\do', '\ds']
  call assert_true(empty(maparg(s:key, 'n')), 'Unexpected debug mapping: ' . s:key)
endfor
for s:key in ["\<F2>", "\<F5>", "\<F9>", "\<F10>", "\<F11>", "\<F12>"]
  call assert_true(empty(maparg(s:key, 'n')), 'Unexpected function-key mapping')
endfor
call assert_true(empty(maparg("\<C-M>", 'n')), 'Ctrl-M must remain Enter')

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

let s:reload_file = tempname()
call writefile(['before'], s:reload_file)
execute 'edit ' . fnameescape(s:reload_file)
setlocal noundofile
sleep 1100m
call writefile(['changed by AI'], s:reload_file)
checktime
call assert_equal('changed by AI', getline(1), 'External change must reload')
bwipeout!
call delete(s:reload_file)

call writefile(v:errors, $VIM_TEST_ERRORS)
if !empty(v:errors)
  cquit
endif
qa!
