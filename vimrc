" 总开关：0 为轻量模式，1 为 CoC + Copilot。
let g:enable_ide = get(g:, 'enable_ide', 0)
let mapleader = '\'
set nocompatible
let g:vim_config_root = fnamemodify(resolve(expand('<sfile>:p')), ':h')
execute 'set runtimepath^=' . fnameescape(g:vim_config_root)

" 插件 -------------------------------------------------------------------------
" 旧镜像仅保留备用，默认使用官方 GitHub。
" let g:plug_url_format = 'https://bgithub.xyz/%s'

if filereadable(g:vim_config_root . '/autoload/plug.vim')
  execute 'source ' . fnameescape(g:vim_config_root . '/autoload/plug.vim')
  call plug#begin(g:vim_config_root . '/plugged')
  if g:enable_ide
    " CoC：补全、诊断、格式化和代码跳转。
    Plug 'neoclide/coc.nvim', {'branch': 'release'}
    " Copilot：AI 代码建议。
    Plug 'github/copilot.vim'
  endif
  " fzf：模糊搜索引擎。
  Plug 'junegunn/fzf', {'do': { -> fzf#install() }}
  " fzf.vim：文件、文本、缓冲区和历史搜索界面。
  Plug 'junegunn/fzf.vim'
  " NERDTree：文件树。
  Plug 'preservim/nerdtree', {'on': 'NERDTreeToggle'}
  " Fugitive：在 Vim 中使用 Git。
  Plug 'tpope/vim-fugitive'
  " GitGutter：在左侧显示 Git 修改标记。
  Plug 'airblade/vim-gitgutter'
  " Lightline：简洁状态栏。
  Plug 'itchyny/lightline.vim'
  " Surround：快速修改括号、引号和标签。
  Plug 'tpope/vim-surround'
  " Repeat：让插件操作支持点号重复。
  Plug 'tpope/vim-repeat'
  " Commentary：快速注释和取消注释。
  Plug 'tpope/vim-commentary'
  " Sleuth：自动识别项目缩进风格。
  Plug 'tpope/vim-sleuth'
  " Templates：新建文件时插入模板。
  Plug 'tibabit/vim-templates'
  call plug#end()
else
  echom '缺少 Vim-Plug，请运行 ~/.vim/scripts/bootstrap.sh'
endif

" 基础设置 ---------------------------------------------------------------------
set encoding=utf-8
set fileencodings=utf-8,gb18030,gbk,gb2312,ucs-bom,latin1
set number hidden autoread showcmd ruler laststatus=2
set noswapfile nobackup nowritebackup
set tabstop=2 shiftwidth=2 softtabstop=2 expandtab
set autoindent smartindent backspace=indent,eol,start
set ignorecase smartcase incsearch hlsearch nowrap
set splitbelow splitright wildmenu wildignorecase
set scrolloff=5 sidescrolloff=5 signcolumn=yes
set updatetime=300 timeoutlen=500 ttimeoutlen=10
set completeopt=menuone,noinsert,noselect shortmess+=c
if has('macunix') && has('clipboard')
  set clipboard=unnamedplus
endif
if !isdirectory(g:vim_config_root . '/undo')
  call mkdir(g:vim_config_root . '/undo', 'p')
endif
execute 'set undodir=' . fnameescape(g:vim_config_root . '/undo//')
set undofile

let g:java_ignore_markdown = 1
let g:NERDTreeShowHidden = 1
let g:gitgutter_map_keys = 0
let g:tmpl_search_paths = [g:vim_config_root . '/templates']
let g:fzf_layout = {'down': '40%'}
filetype plugin indent on
syntax enable

" 保留原来的终端配色和背景。
if exists('+termguicolors')
  set notermguicolors
endif
set background=light
silent! colorscheme default
highlight SignColumn ctermbg=NONE guibg=NONE
highlight FoldColumn ctermbg=NONE guibg=NONE

" 文件、Git 和缓冲区 -----------------------------------------------------------
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

" IDE：仅在 g:enable_ide = 1 时加载 --------------------------------------------
if g:enable_ide
  let g:copilot_no_tab_map = 1
  let g:coc_global_extensions = [
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

  let g:vim_java_home = exists('$VIM_JAVA_HOME') && !empty($VIM_JAVA_HOME)
        \ ? expand($VIM_JAVA_HOME)
        \ : '/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home'
  let g:vim_java_tooling_home =
        \ exists('$VIM_JAVA_TOOLING_HOME') && !empty($VIM_JAVA_TOOLING_HOME)
        \ ? expand($VIM_JAVA_TOOLING_HOME)
        \ : '/Library/Java/JavaVirtualMachines/zulu-21.jdk/Contents/Home'
  let g:coc_user_config = {
        \ 'suggest.noselect': v:true,
        \ 'diagnostic.virtualText': v:false,
        \ 'python.analysis.typeCheckingMode': 'basic',
        \ 'rust-analyzer.server.path':
        \   g:vim_config_root . '/scripts/rust-analyzer-wrapper.sh',
        \ 'java.jdt.ls.java.home': g:vim_java_tooling_home,
        \ 'java.import.gradle.java.home': g:vim_java_home,
        \ 'java.configuration.runtimes': [
        \   {'name': 'JavaSE-17', 'path': g:vim_java_home, 'default': v:true},
        \   {'name': 'JavaSE-21', 'path': g:vim_java_tooling_home},
        \ ],
        \ }

  function! s:CheckBackspace() abort
    let l:column = col('.') - 1
    return !l:column || getline('.')[l:column - 1] =~# '\s'
  endfunction
  inoremap <silent><expr> <Tab>
        \ coc#pum#visible() ? coc#pum#next(1) :
        \ <SID>CheckBackspace() ? "\<Tab>" : coc#refresh()
  inoremap <silent><expr> <S-Tab>
        \ coc#pum#visible() ? coc#pum#prev(1) : "\<C-D>"
  inoremap <silent><expr> <CR>
        \ coc#pum#visible() ? coc#pum#confirm() : "\<C-G>u\<CR>"
  inoremap <silent><expr> <C-K> coc#refresh()
  inoremap <silent><script><expr> <C-J> copilot#Accept("\<CR>")

  nnoremap <silent> gd :call CocActionAsync('jumpDefinition')<CR>
  nnoremap <silent> gr :call CocActionAsync('jumpReferences')<CR>
  nnoremap <silent> gi :call CocActionAsync('jumpImplementation')<CR>
  nnoremap <silent> K :call CocActionAsync('doHover')<CR>
  nmap <silent> [g <Plug>(coc-diagnostic-prev)
  nmap <silent> ]g <Plug>(coc-diagnostic-next)
  nmap <silent> <leader>a <Plug>(coc-codeaction-cursor)
  xmap <silent> <leader>a <Plug>(coc-codeaction-selected)
  nnoremap <silent> <leader>r :call CocActionAsync('rename')<CR>
  nnoremap <silent> <leader>= :call CocActionAsync('format')<CR>
  xmap <silent> <leader>= <Plug>(coc-format-selected)
  nnoremap <silent> <leader>l :CocList diagnostics<CR>
  nnoremap <silent> <leader>o :CocList outline<CR>
endif

" 文件类型和常用行为 -----------------------------------------------------------
augroup tscuite_vim
  autocmd!
  autocmd FileType go setlocal noexpandtab tabstop=4 shiftwidth=4 softtabstop=0
  autocmd FileType python setlocal expandtab tabstop=4 shiftwidth=4 softtabstop=4 colorcolumn=88
  autocmd FileType java,rust,dockerfile setlocal expandtab tabstop=4 shiftwidth=4 softtabstop=4
  autocmd FileType javascript,typescript,vue setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2
  autocmd FileType markdown setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2 wrap linebreak
  autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line('$') | execute 'normal! g`"' | endif
  autocmd FocusGained,BufEnter * silent! checktime
  if g:enable_ide
    autocmd CursorHold * silent! call CocActionAsync('highlight')
  endif
augroup END
