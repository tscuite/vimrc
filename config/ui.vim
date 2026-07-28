if exists('+termguicolors')
  set termguicolors
endif

set background=dark
try
  colorscheme monokai_pro
catch /^Vim\%((\a\+)\)\=:E185/
  silent! colorscheme habamax
endtry

function! VimConfigCocStatus() abort
  try
    return coc#status()
  catch /^Vim\%((\a\+)\)\=:E117/
    return ''
  endtry
endfunction

let g:lightline = {
      \ 'colorscheme': 'wombat',
      \ 'active': {
      \   'left': [
      \     ['mode', 'paste'],
      \     ['readonly', 'filename', 'modified'],
      \   ],
      \   'right': [
      \     ['lineinfo'],
      \     ['percent'],
      \     ['cocstatus', 'fileformat', 'fileencoding', 'filetype'],
      \   ],
      \ },
      \ 'component_function': {
      \   'cocstatus': 'VimConfigCocStatus',
      \ },
      \ }

highlight default link CocErrorSign Error
highlight default link CocWarningSign Todo
highlight default link CocInfoSign Identifier
highlight default link CocHintSign Comment
