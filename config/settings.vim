" 基础设置
set encoding=utf-8
set fileencodings=ucs-bom,utf-8,gb18030,gbk,gb2312,cp936,latin1
set nonu hidden autoread
set showcmd laststatus=2
set noswapfile nobackup nowritebackup
set tabstop=2 shiftwidth=2 softtabstop=2 expandtab
set autoindent backspace=indent,eol,start
set ignorecase smartcase incsearch hlsearch
set nowrap splitbelow splitright
set wildmenu wildignorecase
set scrolloff=5 signcolumn=auto
set updatetime=300 timeoutlen=500 ttimeoutlen=10

if has('macunix') && has('clipboard')
  set clipboard=unnamedplus
endif

if !isdirectory(g:vim_config_root . '/undo')
  call mkdir(g:vim_config_root . '/undo', 'p')
endif
execute 'set undodir=' . fnameescape(g:vim_config_root . '/undo//')
set undofile

filetype plugin indent on
syntax enable

" 配色沿用终端
highlight SignColumn ctermbg=NONE guibg=NONE
highlight FoldColumn ctermbg=NONE guibg=NONE
