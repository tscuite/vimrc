let mapleader = '\'                          " Leader 键
let g:ide_enabled = 0                        " IDE 默认关闭
let g:ai_enabled = 0                         " AI 默认关闭
let g:coc_start_at_startup = 0
let g:copilot_enabled = 0
let g:copilot_no_maps = 1
set nocompatible

let g:vim_config_root = fnamemodify(resolve(expand('<sfile>:p')), ':h')
execute 'set runtimepath^=' . fnameescape(g:vim_config_root)

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
set encoding=utf-8                             " UTF-8 编码
set fileencodings=ucs-bom,utf-8,gb18030,gbk,gb2312,cp936,latin1 " 识别文件编码
set nonu                                       " 不显示行号
set hidden autoread                            " 缓冲区和自动重读
set showcmd laststatus=2                       " 命令和状态栏
set noswapfile nobackup nowritebackup          " 不生成临时备份
set tabstop=2 shiftwidth=2 softtabstop=2 expandtab " 两空格缩进
set autoindent backspace=indent,eol,start       " 缩进和退格
set ignorecase smartcase incsearch hlsearch    " 智能搜索
set nowrap                                     " 不自动换行
set splitbelow splitright                      " 新窗口在下或右
set wildmenu wildignorecase                    " 命令行补全
set scrolloff=5 signcolumn=yes                 " 上下文和标记列
set updatetime=300 timeoutlen=500 ttimeoutlen=10 " 响应时间
set completeopt=menuone,noinsert,noselect shortmess+=c " 补全菜单
set mouse=                                     " 鼠标默认关闭
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

" 配色沿用旧配置和终端
highlight SignColumn ctermbg=NONE guibg=NONE
highlight FoldColumn ctermbg=NONE guibg=NONE

" 快捷键
nnoremap <silent> <leader>i :call <SID>ToggleIDE()<CR>
nnoremap <silent> <leader>ai :call <SID>ToggleAI()<CR>
nnoremap <silent> <leader>m :call <SID>ToggleMouse()<CR>
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

" IDE 配置
let g:coc_global_extensions = [
      \ 'coc-go', 'coc-pyright', 'coc-tsserver', '@yaegassy/coc-volar',
      \ 'coc-java', 'coc-rust-analyzer', 'coc-json', 'coc-prettier',
      \ ]
let g:vim_java_home = expand(get(environ(), 'VIM_JAVA_HOME',
      \ '/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home'))
let g:vim_java_tooling_home = expand(get(environ(), 'VIM_JAVA_TOOLING_HOME',
      \ '/Library/Java/JavaVirtualMachines/zulu-21.jdk/Contents/Home'))
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

function! s:CheckBackspace() abort
  let l:column = col('.') - 1
  return !l:column || getline('.')[l:column - 1] =~# '\s'
endfunction

function! s:Coc(action, ...) abort
  if g:ide_enabled
    call CocActionAsync(a:action)
  elseif a:0
    execute 'normal! ' . a:1
  else
    echom 'IDE 未开启，请按 \i'
  endif
endfunction

inoremap <silent><expr> <Tab> !g:ide_enabled ? "\<Tab>" :
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ <SID>CheckBackspace() ? "\<Tab>" : coc#refresh()
inoremap <silent><expr> <S-Tab> g:ide_enabled && coc#pum#visible()
      \ ? coc#pum#prev(1) : "\<C-D>"
inoremap <silent><expr> <CR> g:ide_enabled && coc#pum#visible()
      \ ? coc#pum#confirm() : "\<C-G>u\<CR>"
inoremap <silent><expr> <C-K> g:ide_enabled ? coc#refresh() : "\<C-K>"
inoremap <silent><script><expr> <C-J> g:ai_enabled
      \ ? copilot#Accept("\<CR>") : "\<C-J>"

nnoremap <silent> gd :call <SID>Coc('jumpDefinition', 'gd')<CR>
nnoremap <silent> gr :call <SID>Coc('jumpReferences')<CR>
nnoremap <silent> gi :call <SID>Coc('jumpImplementation')<CR>
nnoremap <silent> K :call <SID>Coc('doHover', 'K')<CR>
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)
nmap <silent> <leader>a <Plug>(coc-codeaction-cursor)
xmap <silent> <leader>a <Plug>(coc-codeaction-selected)
nnoremap <silent> <leader>r :call <SID>Coc('rename')<CR>
nnoremap <silent> <leader>= :call <SID>Coc('format')<CR>
xmap <silent> <leader>= <Plug>(coc-format-selected)
nnoremap <silent> <leader>l :CocList diagnostics<CR>
nnoremap <silent> <leader>o :CocList outline<CR>

function! s:ToggleIDE() abort
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

function! s:ToggleAI() abort
  if !g:ai_enabled
    if !exists('*plug#load')
      echom '请先运行 ~/.vim/scripts/bootstrap.sh'
      return
    endif
    call plug#load('copilot.vim')
    if exists(':Copilot') != 2
      echom 'AI 插件未安装，请运行 bootstrap.sh'
      return
    endif
    let g:ai_enabled = 1
    let g:copilot_enabled = 1
    silent! Copilot enable
    silent! Copilot restart
    echom 'AI 已开启'
    return
  endif

  let g:ai_enabled = 0
  let g:copilot_enabled = 0
  silent! Copilot disable
  try
    let l:copilot = copilot#RunningClient()
    if type(l:copilot) == v:t_dict && has_key(l:copilot, 'Close')
      call l:copilot.Close()
    endif
  catch
  endtry
  echom 'AI 已关闭'
endfunction

function! s:ToggleMouse() abort
  let &mouse = empty(&mouse) ? 'a' : ''
  echom '鼠标已' . (empty(&mouse) ? '关闭' : '开启')
endfunction

" 文件类型
augroup tscuite_vim
  autocmd!
  autocmd FileType go setlocal noexpandtab tabstop=4 shiftwidth=4 softtabstop=0
  autocmd FileType python setlocal expandtab tabstop=4 shiftwidth=4 softtabstop=4 colorcolumn=88
  autocmd FileType java,rust,dockerfile setlocal expandtab tabstop=4 shiftwidth=4 softtabstop=4
  autocmd FileType javascript,typescript,vue setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2
  autocmd FileType markdown setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2 wrap linebreak
  autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line('$') | execute 'normal! g`"' | endif
  autocmd FocusGained,BufEnter * silent! checktime
  autocmd CursorHold * if g:ide_enabled && exists('*CocActionAsync') | silent! call CocActionAsync('highlight') | endif
augroup END
