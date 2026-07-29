" 插件
" let g:plug_url_format = 'https://bgithub.xyz/%s' " 备用镜像
let g:NERDTreeShowHidden = 1
let g:gitgutter_map_keys = 0
let g:tmpl_search_paths = [g:vim_config_root . '/templates']
let g:fzf_layout = {'down': '40%'}

if filereadable(g:vim_config_root . '/autoload/plug.vim')
  execute 'source ' . fnameescape(g:vim_config_root . '/autoload/plug.vim')
  call plug#begin(g:vim_config_root . '/plugged')
  Plug 'neoclide/coc.nvim', {'branch': 'release'}           | " IDE
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
