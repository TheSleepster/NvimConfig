require("thesleepster.remap")
require("thesleepster.set")
require("thesleepster.lazy")

vim.g.netrw_browse_split = 0
vim.g.netrw_winsize = 25

vim.cmd[[
augroup cursorline
  autocmd!
  autocmd WinEnter,BufEnter * lua vim.wo.cursorline = true
  autocmd WinLeave,BufLeave * lua vim.wo.cursorline = false
augroup END
]]

colorMyPencils()
