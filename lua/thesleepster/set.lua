vim.opt.guicursor = "n-v-c-sm-i-ci-ve-r-cr-o:block,i:block"
vim.opt.guicursor = blinkon0

vim.opt.nu = false
vim.opt.relativenumber = false

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true
vim.opt.cursorline = true;

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = "../~"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "no"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 144
--vim.opt.colorcolumn = "80"

--shows a menu while using tab completion
vim.cmd("set wildmenu")
