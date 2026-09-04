return {
  "rmagatti/goto-preview",
  dependencies = {
    "rmagatti/logger.nvim",
  },
  event = "BufReadPost",
  config = function()
    local goto_preview = require("goto-preview")

    goto_preview.setup({
      width = 120,
      height = 15,
      border = { "↖", "─", "┐", "│", "┘", "─", "└", "│" },
      default_mappings = false,
      debug = false,
      opacity = nil,
      resizing_mappings = false,
      post_open_hook = nil,
      post_close_hook = nil,
      references = {
        provider = "telescope",
      },
      focus_on_open = true,
      dismiss_on_move = false,
      force_close = true,
      bufhidden = "wipe",
      stack_floating_preview_windows = true,
      preview_window_title = { enable = true, position = "left" },
    })

    -- Keybindings for goto-preview
    vim.keymap.set("n", "gpd", goto_preview.goto_preview_definition, { desc = "Preview definition" })
    vim.keymap.set("n", "gpt", goto_preview.goto_preview_type_definition, { desc = "Preview type definition" })
    vim.keymap.set("n", "gpi", goto_preview.goto_preview_implementation, { desc = "Preview implementation" })
    vim.keymap.set("n", "gpD", goto_preview.goto_preview_declaration, { desc = "Preview declaration" })
    vim.keymap.set("n", "gpr", goto_preview.goto_preview_references, { desc = "Preview references" })
    vim.keymap.set("n", "gP", goto_preview.close_all_win, { desc = "Close all preview windows" })
  end,
}
