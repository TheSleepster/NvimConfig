function ColorMyPencils(color)
    color = color or "handmade_theme" 
    vim.cmd.colorscheme(color)


    vim.cmd('highlight Cursor guifg=#FFFFFF')
--    vim.api.nvim_set_hl(0, "CursorLine", {bg = "#000cff"})

--    vim.api.nvim_set_hl(0, "Normal", {bg = "#161616", fg = "#dab98f"})
--    vim.api.nvim_set_hl(0, "NormalFloat", {bg = "#161616"})
--    vim.api.nvim_set_hl(0, "Normal", {fg = "#dab98f"})
--    vim.api.nvim_set_hl(0, "NormalFloat", {bg = ""})

--    color = color or "github_dark_high_contrast"
end

ColorMyPencils()
