set encoding=utf-8
set fileencodings=utf-8,gb18030,gbk,gb2312,ucs-bom,latin1

" MacVim's Java syntax expects the built-in markdown groups, while
" vim-markdown defines a different set. Keep regular Javadoc highlighting.
let g:java_ignore_markdown = 1

set number
set hidden
set autoread
set history=1000
set showcmd
set ruler
set laststatus=2

set noswapfile
set nobackup
set nowritebackup

if isdirectory(g:vim_config_root . '/undo')
  execute 'set undodir=' . fnameescape(g:vim_config_root . '/undo//')
  set undofile
endif

set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab
set autoindent
set smartindent
set backspace=indent,eol,start

set ignorecase
set smartcase
set incsearch
set hlsearch
set nowrap

set splitbelow
set splitright
set wildmenu
set wildignorecase
set scrolloff=5
set sidescrolloff=5
set signcolumn=yes
set updatetime=300
set timeoutlen=500
set ttimeoutlen=10
set completeopt=menuone,noinsert,noselect
set shortmess+=c

if has('macunix') && has('clipboard')
  set clipboard=unnamedplus
endif

filetype plugin indent on
syntax enable
