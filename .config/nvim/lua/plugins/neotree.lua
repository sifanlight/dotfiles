return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
    "MunifTanjim/nui.nvim",
    -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
  },
  config = function()
    require("neo-tree").setup({
      close_if_last_window = true, -- Close Neo-tree if it is the last window left in the tab
      filesystem = {
        filtered_items = {
            visible = true, -- when true, they will just be displayed differently (e.g. faded out)
            hide_dotfiles = false,
            hide_gitignored = false,
        },
        follow_current_file = {
          enabled = true, -- This will find and focus the file in the active buffer every time
        },
        use_libuv_file_watcher = true, -- This will use the OS level file watchers to detect changes
      },
      window = {
        width = 30,
        mappings = {
          ["<space>"] = "none",
        },
      },
    })

    vim.keymap.set('n', '<leader>e', ':Neotree toggle<CR>', { desc = 'NeoTree toggle' })
  end,
}
