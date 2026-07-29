" 搜索与文件
nnoremap <silent> <leader>p :Files<CR>
nnoremap <silent> <leader>f :Rg<CR>
nnoremap <silent> <leader>b :Buffers<CR>
nnoremap <silent> <leader>h :History<CR>
nnoremap <silent> <leader>e :NERDTreeToggle<CR>
nnoremap <silent> <leader>c :Commands<CR>

" Git
nnoremap <silent> <leader>gs :Git<CR>
nnoremap <silent> <leader>gd :Gdiffsplit<CR>
nnoremap <silent> <leader>gb :Git blame<CR>
nnoremap <silent> <leader>gp :GitGutterPreviewHunk<CR>

" 保存与缓冲区
nnoremap <silent> <leader>w :write<CR>
nnoremap <silent> <leader>q :quit<CR>
nnoremap <silent> <leader>x :xit<CR>
nnoremap <silent> [b :bprevious<CR>
nnoremap <silent> ]b :bnext<CR>

" IDE
nnoremap <silent> gd :call TscuiteCoc('jumpDefinition', 'gd')<CR>
nnoremap <silent> gr :call TscuiteCoc('jumpReferences')<CR>
nnoremap <silent> gi :call TscuiteCoc('jumpImplementation')<CR>
nnoremap <silent> K :call TscuiteCoc('doHover', 'K')<CR>
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)
nmap <silent> <leader>a <Plug>(coc-codeaction-cursor)
xmap <silent> <leader>a <Plug>(coc-codeaction-selected)
nnoremap <silent> <leader>r :call TscuiteCoc('rename')<CR>
nnoremap <silent> <leader>= :call TscuiteCoc('format')<CR>
xmap <silent> <leader>= <Plug>(coc-format-selected)
nnoremap <silent> <leader>l :CocList diagnostics<CR>
nnoremap <silent> <leader>o :CocList outline<CR>

" 功能开关
nnoremap <silent> <leader>i :call TscuiteToggleIDE()<CR>
nnoremap <silent> <leader><leader> :call TscuiteToggleAI()<CR>
nnoremap <silent> <leader>m :call TscuiteToggleMouse()<CR>

" 补全
inoremap <silent><expr> <Tab> !g:ide_enabled ? "\<Tab>" :
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ TscuiteCheckBackspace() ? "\<Tab>" : coc#refresh()
inoremap <silent><expr> <S-Tab> g:ide_enabled && coc#pum#visible()
      \ ? coc#pum#prev(1) : "\<C-D>"
inoremap <silent><expr> <CR> g:ide_enabled && coc#pum#visible()
      \ ? coc#pum#confirm() : "\<C-G>u\<CR>"
inoremap <silent><expr> <C-K> g:ide_enabled ? coc#refresh() : "\<C-K>"
