set nomore

call assert_equal('\', get(g:, 'mapleader', ''), 'Leader must be backslash')
call assert_true(&number, 'Line numbers must be enabled')
call assert_equal(300, &updatetime, 'CoC requires a short updatetime')
call assert_equal(500, &timeoutlen, 'Leader mappings need a predictable timeout')
call assert_true(&hidden, 'Hidden buffers must be enabled')
call assert_true(&signcolumn ==# 'yes', 'Sign column must not move the text')
call assert_false(&termguicolors, 'Keep the original terminal-controlled colors')
call assert_equal('light', &background, 'Keep the original background mode')
call assert_equal(
      \ 'default',
      \ get(g:, 'colors_name', 'default'),
      \ 'Keep the original Vim color scheme')

for s:key in ['\p', '\f', '\b', '\h', '\e', '\c',
      \ '\gs', '\gd', '\gb', '\gp',
      \ '\w', '\q', '\x',
      \ '\dd', '\db', '\dn', '\di', '\do', '\ds',
      \ 'gd', 'gr', 'gi', 'K', '[g', ']g',
      \ '\a', '\r', '\=', '\l', '\o',
      \ '[b', ']b']
  call assert_false(empty(maparg(s:key, 'n')), 'Missing normal mapping: ' . s:key)
endfor

for s:key in ['<Tab>', '<S-Tab>', '<CR>', '<C-K>', '<C-J>']
  call assert_false(
        \ empty(maparg(s:key, 'i')),
        \ 'Missing insert mapping: ' . s:key)
endfor

for s:key in ["\<F2>", "\<F5>", "\<F9>", "\<F10>", "\<F11>", "\<F12>",
      \ "\<C-M>", "\<C-S>", "\<C-Q>"]
  call assert_true(empty(maparg(s:key, 'n')), 'Unexpected custom mapping: ' . keytrans(s:key))
endfor

call assert_true(exists('g:coc_global_extensions'), 'CoC extensions must be declared')
if exists('g:coc_global_extensions')
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
endif
call assert_false(exists('g:plug_url_format'), 'Plugin mirror must remain disabled')

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
setlocal filetype=
setfiletype markdown
call assert_equal(2, &l:shiftwidth, 'markdown shiftwidth')
call assert_true(&l:wrap, 'Markdown must wrap')
call assert_true(&l:linebreak, 'Markdown must wrap at word boundaries')
bwipeout!

call writefile(v:errors, $VIM_TEST_ERRORS)
if !empty(v:errors)
  cquit
endif
qa!
