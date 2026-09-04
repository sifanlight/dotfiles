return {
    {
        "Mofiqul/vscode.nvim",
        lazy = false,
        priority = 1000,
        opts = {
            style = "dark",
            transparent = false,
            italic_comments = true,
            underline_links = true,
            disable_nvimtree_bg = true,
        },
        config = function(_, opts)
            require("vscode").setup(opts)
            require("vscode").load()
        end
    },
    {
        "folke/tokyonight.nvim",
        lazy = true,
        opts = {
            style = "night",
        },
    },
    {
        "nvim-lualine/lualine.nvim",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        opts = {
            options = {
                theme = "vscode",
            },
        }
    },
}
