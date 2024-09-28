require("thesleepster.remap")
require("thesleepster.set")
require("thesleepster.lazy")

vim.g.netrw_browse_split = 0
vim.g.netrw_winsize = 25

vim.cmd[[
    syntax match TodoKeyword "\s*\zs\(TODO\|NOTE\|HACK\|WARN\|WARNING\|FIX\)" contained
    highlight link TodoKeyword DiagnosticWarn

    syntax match AuthorKeyword "Sleepster"
    highlight link AuthorKeyword DiagnosticWarn

    augroup cursorline
        autocmd!
        autocmd WinEnter,BufEnter * lua vim.wo.cursorline = true
        autocmd WinLeave,BufLeave * lua vim.wo.cursorline = false
    augroup END
]]

-- GLSL STUFF
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
    pattern = {"*.vs", "*.fs", "*.vert", "*.frag"},
    callback = function()
        vim.bo.filetype = "glsl"
    end,
})

vim.api.nvim_create_user_command('SourceInit', function()
    vim.cmd(':so C:\\users\\ibjal\\AppData\\local\\nvim\\lua\\thesleepster\\init.lua')
end, {})

ColorMyPencils()

