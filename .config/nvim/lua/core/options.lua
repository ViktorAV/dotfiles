-- Application
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true
vim.opt.updatetime = 100
vim.opt.shell = '/bin/zsh'
-- vim.g.did_load_filetypes = 1
vim.opt.fo= 't'
vim.opt.signcolumn = 'yes'
-- vim.opt.virtualedit = 'block'
vim.opt.incsearch = true
vim.opt.inccommand = 'split'
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.termguicolors = true
vim.opt.background = 'dark'
vim.opt.backspace = {'start', 'eol', 'indent'}
-- vim.opt.isfname:append('@-@')
-- vim.opt.colorcolumn = '80'
vim.opt.hlsearch = true
-- vim.g.editorconfig = true
-- vim.o.autowriteall = true
vim.opt.textwidth = 75

-- GUI
vim.o.foldcolumn = '9'

-- Grammar checking
-- vim.g.spellfile_URL = 'https://ftp.nluug.nl/vim/runtime/spell/'
-- ^ Отсюда можно скачать файл ru.utf-8.spl
-- И поместить его в: .local/share/nvim/site/spell 
-- vim.opt.spelllang = 'ru_ru,en_us'
-- vim.g.loaded_netrw = 1
-- vim.g.loaded_netrwPlugin = 1

-- Cursor
vim.opt.guicursor = 'n-v-c-i:block' -- block, hor20, ver25, ''
vim.opt.cursorline = true
vim.opt.scrolloff = 12

-- Status line
vim.opt.laststatus = 0
vim.opt.ruler = false
vim.opt.showcmd = false
vim.opt.showmode = false
vim.o.cmdheight = 0

-- Line Numbers
vim.opt.number = false
vim.opt.relativenumber = false

-- Splits
-- vim.opt.splitbelow = true
-- vim.opt.splitright = true

-- Mouse
-- vim.opt.mouse = 'a'
-- vim.opt.mousefocus = false

-- Clipboard
vim.opt.clipboard:append('unnamedplus')

-- Shorter messages
-- vim.opt.shortmess:append('c')

-- Indent Settings
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.wo.linebreak = true

-- Fillchars
vim.opt.fillchars = {
    vert = '|',
    fold = ' ',
    eob = ' ', -- suppress ~ at EndOfBuffer
    msgsep = '-',
    foldopen = '+',
    foldsep = '|',
    foldclose = 'X',
}

vim.ui.open = (function(overridden)
  return function(uri, opt)
    if uri:find('rutube.ru') then
      vim.fn.jobstart({'mpv', uri})
      return
    elseif vim.endswith(uri, ".pdf") then
      opt = { cmd = { "zathura" } } -- override open app
    end
    return overridden(uri, opt)
  end
end)(vim.ui.open)
