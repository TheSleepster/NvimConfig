 -- Lua
require('onedark').setup  {
    -- Main options --
    style = 'darker', -- Default theme style. Choose between 'dark', 'darker', 'cool', 'deep', 'warm', 'warmer' and 'light'
    transparent = true,  -- Show/hide background
    term_colors = true, -- Change terminal color as per the selected theme style
    ending_tildes = false, -- Show the end-of-buffer tildes. By default they are hidden
    cmp_itemkind_reverse = false, -- reverse item kind highlights in cmp menu

    -- toggle theme style ---
    toggle_style_key = nil, -- keybind to toggle theme style. Leave it nil to disable it, or set it to a string, for example "<leader>ts"
    toggle_style_list = {'dark', 'darker', 'cool', 'deep', 'warm', 'warmer', 'light'}, -- List of styles to toggle between

    -- Change code style ---
    -- Options are italic, bold, underline, none
    -- You can configure multiple style with comma separated, For e.g., keywords = 'italic,bold'
    code_style = {
        comments = 'none',
        keywords = 'none',
        functions = 'none',
        strings = 'none',
        variables = 'none'
    },

    -- Lualine options --
    lualine = {
        transparent = true, -- lualine center bar transparency
    },

    -- Custom Highlights --
    
    colors = {
        yellow = '#dab98f',
        purple = '#CD950C',
        cyan = '#dab98f',
        blue = '#dab98f',
        orange = '#cd950c',
        red = "#dab98f",
        pink = "#dap98f",
        light_blue = "#ffa006",
        weird_green = "#ffa006",
        fg =        "#dab98f",
        grey =      "#5c6370",
        light_grey= "#dap98f",
        dark_cyan = "#dab98f",
        dark_red =  "#dab98f",
        dark_yellow="#dab98f",
        dark_purple="#dab98f",
    }, -- Override default colors
    highlights = {
    }, -- Override highlight groups

    -- Plugins Config --
    diagnostics = {
        darker = true, -- darker colors for diagnostic
        undercurl = true,   -- use undercurl instead of underline for diagnostics
        background = true,    -- use background color for virtual text

        error = "$red",
        hint = "$weird_green",
        info = "$light_blue",
        note = "$green",
        todo = "$light_blue",
        warn = "$yellow",
    },
}
