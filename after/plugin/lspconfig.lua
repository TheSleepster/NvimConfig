require('mason').setup({})
require('mason-lspconfig').setup({
    ensure_installed = {
        "ols",
        "glsl_analyzer",
        "clangd",
        "omnisharp",
    }
})

local opts = {noremap=true}

local on_attach = function(client, bufnr)
    -- Key mappings
    local opts = { buffer = bufnr }
    vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
    vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
    vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
    vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
    vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
    vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
    vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
    vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
    vim.keymap.set("i", "<C-K>", function() vim.lsp.buf.hover() end, opts)
    vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)

    vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(
        vim.lsp.handlers['signature_help'], {
            border = 'single',
            close_events = {"BufHidden", "CursorMoved"},
        })

    if client.name == "clangd" then
        vim.diagnostic.config({virtual_text=false})
        vim.diagnostic.config({underline=false})
        client.server_capabilities.semanticTokensProvider = nil
    end
end

require("lspconfig").clangd.setup {
    on_attach = on_attach,
    cmd = {
        "C:/Program Files/LLVM/bin/clangd",
        "--background-index",
        "--pch-storage=memory",
        "--all-scopes-completion",
        "--pretty",
        "--header-insertion=never",
        "-j=4",
        "--inlay-hints",
        "--header-insertion-decorators=0",
        "--function-arg-placeholders",
        "--completion-style=detailed",
    },
}

require("lspconfig").omnisharp.setup {
    on_attach = on_attach
}

require("lspconfig").ols.setup {
    on_attach = on_attach
}

require("lspconfig").glsl_analyzer.setup {
    on_attach = on_attach,
    filetypes = {"glsl", "vert", "frag", "vs", "fs"},
}

require("lspconfig").lua_ls.setup {
    on_attach = on_attach,
}

-- define kind_icons array like above
local cmp_kinds = {
  Text = "",
  Method = "󰆧",
  Function = "",
  Constructor = "",
  Field = "󰇽",
  Variable = "󰂡",
  Class = "󰠱",
  Interface = "",
  Module = "",
  Property = "󰜢",
  Unit = "",
  Value = "󰎠",
  Enum = "",
  Keyword = "󰌋",
  Snippet = "",
  Color = "󰏘",
  File = "󰈙",
  Reference = "",
  Folder = "󰉋",
  EnumMember = "",
  Constant = "󰏿",
  Struct = "",
  Event = "",
  Operator = "󰆕",
  TypeParameter = "󰅲",
}

local cmp = require('cmp')
  cmp.setup({
    sources = {
        {name = 'nvim_lsp', keyword_length = 5, max_item_count = 10},
        {name = 'path'},
    },

    snippet = {
        expand = function(args)
        vim.snippet.expand(args.body)
      end,
    },

    window = {
    completion = cmp.config.window.bordered({
            border = 'rounded',
            winhighlight = "Normal:Normal,FloatBorder:Normal,Search:None",
            col_offset = -2,
            side_padding = 1,
        }),
    },

    formatting = {
        format = function(entry, vim_item)
        local kind = vim_item.kind
        vim_item.kind = cmp_kinds[vim_item.kind] or "?"

        vim_item.menu = ({
            buffer = "[Buffer]",
            nvim_lsp = "[LSP]",
            nvim_lua = "[Lua]",
            latex_symbols = "[LaTeX]",
        })[entry.source.name]

        return vim_item
        end,
    },

  mapping = cmp.mapping.preset.insert({}),
})