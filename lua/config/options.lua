local opt = vim.opt

opt.encoding = "utf-8"
opt.fileencodings = { "ucs-bom", "utf-8", "gb18030", "gbk", "gb2312", "cp936", "latin1" }
opt.number = false
opt.hidden = true
opt.autoread = true
opt.showcmd = true
opt.laststatus = 2
opt.swapfile = false
opt.backup = false
opt.writebackup = false
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
opt.expandtab = true
opt.autoindent = true
opt.backspace = { "indent", "eol", "start" }
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true
opt.wrap = false
opt.splitbelow = true
opt.splitright = true
opt.wildmenu = true
opt.wildignorecase = true
opt.scrolloff = 5
opt.signcolumn = "auto"
opt.updatetime = 300
opt.timeoutlen = 500
opt.ttimeoutlen = 10
opt.completeopt = { "menuone", "noinsert", "noselect", "popup" }
opt.shortmess:append("c")
opt.mouse = ""
opt.grepprg = "rg --vimgrep --smart-case"
opt.grepformat = "%f:%l:%c:%m"

if vim.fn.has("macunix") == 1 and vim.fn.has("clipboard") == 1 then
  opt.clipboard = "unnamedplus"
end

local undo_dir = vim.fn.stdpath("state") .. "/undo"
vim.fn.mkdir(undo_dir, "p")
opt.undodir = undo_dir .. "//"
opt.undofile = true

vim.cmd("filetype plugin indent on")
vim.cmd("syntax enable")
vim.cmd("highlight SignColumn ctermbg=NONE guibg=NONE")
vim.cmd("highlight FoldColumn ctermbg=NONE guibg=NONE")
