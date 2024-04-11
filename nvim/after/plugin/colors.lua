function colorMyPencils(color)
    color = color or "onedark"
    vim.cmd.colorscheme(color)

      vim.cmd('highlight Cursor guifg=#00fc5f')
      vim.api.nvim_set_hl(0, "Normal", {bg = "#0e0e0e", fg = "#dab98f"})
      vim.api.nvim_set_hl(0, "CursorLine", {bg = "#2c33ff"})
      vim.api.nvim_set_hl(0, "NormalFloat", {bg = "#101010"})
end

colorMyPencils()
