return {
  "rmagatti/auto-session",
  lazy = false,
  dependencies = {
    "nvim-telescope/telescope.nvim",
  },
  opts = {
    auto_restore = true,
    auto_save = true,
    auto_create = true,
    suppressed_dirs = { "~/", "~/Projects", "~/Downloads", "/", "~/Desktop" },
    session_lens = {
      load_on_setup = true,
      theme_conf = { border = true },
      previewer = false,
    },
  },
  keys = {
    { "<leader>wr", "<cmd>SessionRestore<CR>", desc = "Restore session for current directory" },
    { "<leader>ws", "<cmd>SessionSave<CR>", desc = "Save session for current directory" },
    { "<leader>wd", "<cmd>SessionDelete<CR>", desc = "Delete session for current directory" },
    { "<leader>wf", "<cmd>SessionSearch<CR>", desc = "Search/Find all saved sessions" },
  },
}
