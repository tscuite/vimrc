" Legacy mirror retained intentionally; disabled in favor of official GitHub.
" let g:plug_url_format = 'https://bgithub.xyz/%s'

let g:copilot_no_tab_map = 1
let g:vimspector_enable_mappings = ''

let g:go_gopls_enabled = 0
let g:go_code_completion_enabled = 0
let g:go_diagnostics_enabled = 0
let g:go_diagnostics_level = 0
let g:go_fmt_autosave = 0
let g:go_imports_autosave = 0
let g:go_def_mapping_enabled = 0
let g:go_doc_keywordprg_enabled = 0
let g:go_auto_type_info = 0

let g:NERDTreeShowHidden = 1
let g:gitgutter_map_keys = 0
let g:vim_markdown_folding_disabled = 1
let g:vim_markdown_frontmatter = 1
let g:tmpl_search_paths = [g:vim_config_root . '/templates']
let g:fzf_layout = { 'down': '40%' }

let g:vim_plugins_available = 0
let s:plug_path = g:vim_config_root . '/autoload/plug.vim'
if !filereadable(s:plug_path)
  echohl WarningMsg
  echom 'Vim-Plug is not installed. Run ~/.vim/scripts/bootstrap.sh'
  echohl None
  finish
endif

execute 'source ' . fnameescape(s:plug_path)
let g:vim_plugins_available = 1

call plug#begin(g:vim_config_root . '/plugged')

Plug 'neoclide/coc.nvim', { 'branch': 'release' }
Plug 'github/copilot.vim'

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'preservim/nerdtree', { 'on': 'NERDTreeToggle' }

Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

Plug 'itchyny/lightline.vim'
Plug 'phanviet/vim-monokai-pro'

Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-sleuth'

Plug 'preservim/vim-markdown', { 'for': 'markdown' }
Plug 'godlygeek/tabular', { 'for': 'markdown' }
Plug 'tibabit/vim-templates'
Plug 'fatih/vim-go', { 'for': 'go' }

Plug 'puremourning/vimspector', { 'on': [] }

call plug#end()

unlet s:plug_path
