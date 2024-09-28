local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

local plugins = {
    'navarasu/onedark.nvim',
    { "rose-pine/neovim", name = "rose-pine" },
    { "projekt0n/github-nvim-theme"},

    {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    },

    'nvim-telescope/telescope.nvim', tag = '0.1.5',
    'mbbill/undotree',
    'nvim-tree/nvim-web-devicons',

    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig',
    'neovim/nvim-lspconfig',
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-path',
    'hrsh7th/nvim-cmp',

    'onsails/lspkind.nvim',
    'tpope/vim-commentary',

    -- I don't want this because it sucks but oh well
    'nvim-treesitter/nvim-treesitter',
}

local opts = {}

require("lazy").setup(plugins, opt) 
