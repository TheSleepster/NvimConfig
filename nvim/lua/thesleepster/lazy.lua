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
    { "rose-pine/neovim", name = "rose-pine" },
    '/navarasu/onedark.nvim',
    'nvim-treesitter/nvim-treesitter',
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig',
    'neovim/nvim-lspconfig',
    'mbbill/undotree',
    'nvim-lualine/lualine.nvim',
    'akinsho/toggleterm.nvim', version = "*",
    'hrsh7th/nvim-cmp',
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-path',
    'ThePrimeagen/vim-be-good',
    {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    config = true,
    -- use opts = {} for passing setup options
    -- this is equalent to setup({}) function
    },

    {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    },

    {
    'nvim-telescope/telescope.nvim', tag = '0.1.5',
-- or                              , branch = '0.1.x',
      dependencies = { 'nvim-lua/plenary.nvim' }
    },
    {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
            signs = true, -- show icons in the signs column
            sign_priority = 8, -- sign priority
            -- keywords recognized as todo comments
            keywords = {
              FIX = {
                icon = " ", -- icon used for the sign, and in search results
                color = "error", -- can be a hex color, or a named color (see below)
                alt = { "FIXME", "BUG", "FIXIT", "ISSUE" }, -- a set of other keywords that all map to this FIX keywords
                -- signs = false, -- configure signs for some keywords individually
              },
              TODO = { icon = " ", color = "info" },
              HACK = { icon = " ", color = "warning" },
              WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
              PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
              NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
              TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
            },
            gui_style = {
              fg = "NONE", -- The gui style to use for the fg highlight group.
              bg = "BOLD", -- The gui style to use for the bg highlight group.
            },
            merge_keywords = true, -- when true, custom keywords will be merged with the defaults
            -- highlighting of the line containing the todo comment
            -- * before: highlights before the keyword (typically comment characters)
            -- * keyword: highlights of the keyword
            -- * after: highlights after the keyword (todo text)
            highlight = {
              multiline = true, -- enable multine todo comments
              multiline_pattern = "^.", -- lua pattern to match the next multiline from the start of the matched keyword
              multiline_context = 10, -- extra lines that will be re-evaluated when changing a line
              before = "", -- "fg" or "bg" or empty
              keyword = "wide", -- "fg", "bg", "wide", "wide_bg", "wide_fg" or empty. (wide and wide_bg is the same as bg, but will also highlight surrounding characters, wide_fg acts accordingly but with fg)
              after = "fg", -- "fg" or "bg" or empty
              pattern = [[.*<(KEYWORDS)\s*:]], -- pattern or table of patterns, used for highlighting (vim regex)
              comments_only = true, -- uses treesitter to match keywords in comments only
              max_line_len = 400, -- ignore lines longer than this
              exclude = {}, -- list of file types to exclude highlighting
            },
            -- list of named colors where we try to extract the guifg from the
            -- list of highlight groups or use the hex color if hl not found as a fallback
            
            -- TODO:
            -- WARNING:
            -- BUG:
            -- INFO:
            -- PERF:
            colors = {
              error = {"#DC2626" },
              warning = {"#FBBF24" },
              info = {"#0dcaff" },
              hint = {"#10B981" },
              default = {"#7C3AED" },
              test = {"#FF00FF" }
            },
            search = {
              command = "rg",
              args = {
                "--color=never",
                "--no-heading",
                "--with-filename",
                "--line-number",
                "--column",
              },
              -- regex that will be used to match keywords.
              -- don't replace the (KEYWORDS) placeholder
              pattern = [[\b(KEYWORDS):]], -- ripgrep regex
              -- pattern = [[\b(KEYWORDS)\b]], -- match without the extra colon. You'll likely get false positives
            },
          }
    }
}


local opts = {}

require("lazy").setup(plugins, opt) 
