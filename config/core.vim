" 插件
" let g:plug_url_format = 'https://bgithub.xyz/%s' " 备用镜像
if filereadable(g:vim_config_root . '/autoload/plug.vim')
  execute 'source ' . fnameescape(g:vim_config_root . '/autoload/plug.vim')
  call plug#begin(g:vim_config_root . '/plugged')
  Plug 'neoclide/coc.nvim', {'branch': 'release'}           | " IDE
  Plug 'github/copilot.vim', {'on': []}                      | " AI 建议
  Plug 'junegunn/fzf', {'do': { -> fzf#install() }}         | " 模糊搜索
  Plug 'junegunn/fzf.vim'                                   | " 搜索界面
  Plug 'preservim/nerdtree', {'on': 'NERDTreeToggle'}       | " 文件树
  Plug 'tpope/vim-fugitive'                                 | " Git
  Plug 'airblade/vim-gitgutter'                             | " Git 标记
  Plug 'itchyny/lightline.vim'                              | " 状态栏
  Plug 'tpope/vim-surround'                                 | " 括号引号
  Plug 'tpope/vim-repeat'                                   | " 点号重复
  Plug 'tpope/vim-commentary'                               | " 快速注释
  Plug 'tibabit/vim-templates'                              | " 文件模板
  call plug#end()
else
  echom '缺少 Vim-Plug，请运行 ~/.vim/scripts/bootstrap.sh'
endif

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
set scrolloff=5 signcolumn=yes
set updatetime=300 timeoutlen=500 ttimeoutlen=10
if has('macunix') && has('clipboard')
  set clipboard=unnamedplus
endif

if !isdirectory(g:vim_config_root . '/undo')
  call mkdir(g:vim_config_root . '/undo', 'p')
endif
execute 'set undodir=' . fnameescape(g:vim_config_root . '/undo//')
set undofile

let g:NERDTreeShowHidden = 1
let g:gitgutter_map_keys = 0
let g:tmpl_search_paths = [g:vim_config_root . '/templates']
let g:fzf_layout = {'down': '40%'}
filetype plugin indent on
syntax enable

" 配色沿用终端
highlight SignColumn ctermbg=NONE guibg=NONE
highlight FoldColumn ctermbg=NONE guibg=NONE

" 快捷键
nnoremap <silent> <leader>p :Files<CR>
nnoremap <silent> <leader>f :Rg<CR>
nnoremap <silent> <leader>b :Buffers<CR>
nnoremap <silent> <leader>h :History<CR>
nnoremap <silent> <leader>e :NERDTreeToggle<CR>
nnoremap <silent> <leader>c :Commands<CR>
nnoremap <silent> <leader>gs :Git<CR>
nnoremap <silent> <leader>gd :Gdiffsplit<CR>
nnoremap <silent> <leader>gb :Git blame<CR>
nnoremap <silent> <leader>gp :GitGutterPreviewHunk<CR>
nnoremap <silent> <leader>w :write<CR>
nnoremap <silent> <leader>q :quit<CR>
nnoremap <silent> <leader>x :xit<CR>
nnoremap <silent> [b :bprevious<CR>
nnoremap <silent> ]b :bnext<CR>

" 自动命令
augroup tscuite_core
  autocmd!
  autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line('$') | execute 'normal! g`"' | endif
  autocmd FocusGained,BufEnter,CursorHold,CursorHoldI * silent! checktime
augroup END
