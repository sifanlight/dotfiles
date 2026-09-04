return {
    "inhesrom/remote-ssh.nvim",
    branch = "master",
    dependencies = {
        "inhesrom/telescope-remote-buffer", --See https://github.com/inhesrom/telescope-remote-buffer for features
        "nvim-telescope/telescope.nvim",
        "nvim-lua/plenary.nvim",
        "neovim/nvim-lspconfig",
        -- nvim-notify is recommended, but not necessarily required into order to get notifcations during operations - https://github.com/rcarriga/nvim-notify
        "rcarriga/nvim-notify",
    },
    config = function ()
        require('telescope-remote-buffer').setup(
            -- Default keymaps to open telescope and search open buffers including "remote" open buffers
            --fzf = "<leader>fz",
            --match = "<leader>gb",
            --oldfiles = "<leader>rb"
        )

        -- setup lsp_config here or import from part of neovim config that sets up LSP
        local lsp_config = {
            on_attach = function(client, bufnr)
                -- Keybindings are handled by the LspAttach autocmd in lua/config/lsp.lua
            end,
            capabilities = vim.lsp.protocol.make_client_capabilities(),
            filetype_to_server = {
                lua = "lua_ls",
                python = "pyright",
                cpp = "clangd",
                c = "clangd",
            }
        }

        -- Integrate with cmp-nvim-lsp if available
        local has_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
        if has_cmp then
            lsp_config.capabilities = cmp_lsp.default_capabilities()
        end

        require('remote-ssh').setup({
            on_attach = lsp_config.on_attach,
            capabilities = lsp_config.capabilities,
            filetype_to_server = lsp_config.filetype_to_server
        })
    end
}
