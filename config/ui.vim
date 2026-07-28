if exists('+termguicolors')
  set notermguicolors
endif

set background=light
silent! colorscheme default
highlight SignColumn ctermbg=NONE guibg=NONE
highlight FoldColumn ctermbg=NONE guibg=NONE

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
