" 文件类型缩进
augroup tscuite_filetypes
  autocmd!
  autocmd FileType go setlocal noexpandtab tabstop=4 shiftwidth=4 softtabstop=0
  autocmd FileType python setlocal expandtab tabstop=4 shiftwidth=4 softtabstop=4 colorcolumn=88
  autocmd FileType java,rust,dockerfile setlocal expandtab tabstop=4 shiftwidth=4 softtabstop=4
  autocmd FileType javascript,typescript,vue setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2
  autocmd FileType markdown setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2 wrap linebreak
augroup END
