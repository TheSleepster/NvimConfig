function ColorMyPencils(color)
    --color = color or "handmade_theme"
    color = color or "vague"

    vim.cmd.colorscheme(color)
    vim.cmd('highlight Cursor guifg=#FFFFFF')

    vim.api.nvim_set_hl(0, "Error",               {fg = "#FF0000", bold = true})
    vim.api.nvim_set_hl(0, "Todo",                {fg = "#FF0000", bold = true})
    vim.api.nvim_set_hl(0, "Warning",             {fg = "#FFFF00", bold = true})
    vim.api.nvim_set_hl(0, "DiagnosticError",     {fg = "#FF0000", bold = true})
    vim.api.nvim_set_hl(0, "DiagnosticWarn",      {fg = "#FFFF00", bold = true})
    vim.api.nvim_set_hl(0, "DiagnosticInfo",      {fg = "#40FF40"})
    vim.api.nvim_set_hl(0, "DiagnosticHint",      {fg = "#40FF40"})

--    vim.api.nvim_set_hl(0, "CursorLine", {bg = "#000cff"})

--    vim.api.nvim_set_hl(0, "Normal", {bg = "#161616", fg = "#dab98f"})
--    vim.api.nvim_set_hl(0, "NormalFloat", {bg = "#161616"})
--    vim.api.nvim_set_hl(0, "Normal", {fg = "#dab98f"})
--    vim.api.nvim_set_hl(0, "NormalFloat", {bg = ""})

--    color = color or "github_dark_high_contrast"
end

ColorMyPencils()
