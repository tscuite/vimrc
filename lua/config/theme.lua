local api = vim.api

-- The old Vim configuration deliberately used no colorscheme.  It relied on
-- Vim's light-background defaults and the terminal's ANSI palette instead.
vim.opt.background = "light"
vim.opt.termguicolors = false

-- Keep Neovim-only highlight links (diagnostics, semantic tokens, floats), then
-- replace the visible colors with Vim's legacy 16-color terminal palette.
vim.cmd.colorscheme("vim")

local ansi = {
  black = 0,
  dark_red = 1,
  dark_green = 2,
  brown = 3,
  dark_blue = 4,
  dark_magenta = 5,
  dark_cyan = 6,
  light_grey = 7,
  dark_grey = 8,
  red = 9,
  green = 10,
  yellow = 11,
  blue = 12,
  magenta = 13,
  cyan = 14,
  white = 15,
}

local function highlight(name, spec)
  -- Do not let GUI attributes implicitly populate terminal attributes.
  spec.cterm = spec.cterm or {}
  api.nvim_set_hl(0, name, spec)
end

local legacy = {
  Normal = {},
  Conceal = { ctermfg = ansi.light_grey, ctermbg = ansi.dark_grey },
  ErrorMsg = { ctermfg = ansi.white, ctermbg = ansi.dark_red },
  IncSearch = { reverse = true, cterm = { reverse = true } },
  ModeMsg = { bold = true, cterm = { bold = true } },
  NonText = { ctermfg = ansi.blue },
  PmenuSbar = { ctermbg = ansi.light_grey },
  StatusLine = { bold = true, reverse = true, cterm = { bold = true, reverse = true } },
  StatusLineNC = { reverse = true, cterm = { reverse = true } },
  TabLineFill = { reverse = true, cterm = { reverse = true } },
  TabLineSel = { bold = true, cterm = { bold = true } },
  WildMenu = { ctermfg = ansi.black, ctermbg = ansi.yellow },
  VertSplit = { reverse = true, cterm = { reverse = true } },
  WinSeparator = { reverse = true, cterm = { reverse = true } },

  ColorColumn = { ctermbg = ansi.red },
  CursorColumn = { ctermbg = ansi.light_grey },
  CursorLine = { cterm = { underline = true } },
  CursorLineNr = { ctermfg = ansi.brown, cterm = { underline = true } },
  DiffAdd = { ctermbg = ansi.blue },
  DiffChange = { ctermbg = ansi.magenta },
  DiffDelete = { ctermfg = ansi.blue, ctermbg = ansi.cyan },
  DiffText = { ctermbg = ansi.red, cterm = { bold = true } },
  Directory = { ctermfg = ansi.dark_blue },
  FoldColumn = { ctermfg = ansi.dark_blue },
  Folded = { ctermfg = ansi.dark_blue, ctermbg = ansi.light_grey },
  LineNr = { ctermfg = ansi.brown },
  MatchParen = { ctermbg = ansi.cyan },
  MoreMsg = { ctermfg = ansi.dark_green },
  Pmenu = { ctermfg = ansi.black, ctermbg = ansi.magenta },
  PmenuSel = { ctermfg = ansi.black, ctermbg = ansi.light_grey },
  PmenuThumb = { ctermbg = ansi.black },
  Question = { ctermfg = ansi.dark_green },
  Search = { ctermbg = ansi.yellow },
  SignColumn = { ctermfg = ansi.dark_blue },
  SpecialKey = { ctermfg = ansi.dark_blue },
  SpellBad = { ctermbg = ansi.red },
  SpellCap = { ctermbg = ansi.blue },
  SpellLocal = { ctermbg = ansi.cyan },
  SpellRare = { ctermbg = ansi.magenta },
  StatusLineTerm = { ctermfg = ansi.white, ctermbg = ansi.dark_green, cterm = { bold = true } },
  StatusLineTermNC = { ctermfg = ansi.white, ctermbg = ansi.dark_green },
  TabLine = { ctermfg = ansi.black, ctermbg = ansi.light_grey, cterm = { underline = true } },
  Title = { ctermfg = ansi.dark_magenta },
  Visual = { reverse = true, cterm = { reverse = true } },
  WarningMsg = { ctermfg = ansi.dark_red },

  Comment = { ctermfg = ansi.dark_blue },
  Constant = { ctermfg = ansi.dark_red },
  Special = { ctermfg = ansi.dark_magenta },
  Identifier = { ctermfg = ansi.dark_cyan },
  Statement = { ctermfg = ansi.brown },
  PreProc = { ctermfg = ansi.dark_magenta },
  Type = { ctermfg = ansi.dark_green },
  Underlined = { ctermfg = ansi.dark_magenta, cterm = { underline = true } },
  Ignore = { ctermfg = ansi.white },
  Added = { ctermfg = ansi.dark_green },
  Changed = { ctermfg = ansi.blue },
  Removed = { ctermfg = ansi.red },
  Error = { ctermfg = ansi.white, ctermbg = ansi.red },
  Todo = { ctermfg = ansi.black, ctermbg = ansi.yellow },

  -- Match CoC's old default severity palette.
  DiagnosticError = { ctermfg = ansi.red },
  DiagnosticWarn = { ctermfg = ansi.brown },
  DiagnosticInfo = { ctermfg = ansi.yellow },
  DiagnosticHint = { ctermfg = ansi.blue },
  DiagnosticOk = { ctermfg = ansi.green },
  LspInlayHint = { ctermfg = ansi.blue },
}

for name, spec in pairs(legacy) do
  highlight(name, spec)
end

local links = {
  CurSearch = "Search",
  FloatBorder = "Pmenu",
  LspReferenceText = "CursorColumn",
  LspReferenceRead = "CursorColumn",
  LspReferenceWrite = "CursorColumn",
}

for name, target in pairs(links) do
  api.nvim_set_hl(0, name, { link = target })
end
