return {
    'pacha/vem-tabline',
    lazy = false,
    init = function()
        -- Enable index numbers in the tabline
        vim.g.vem_tabline_show_number = 'index'
        -- Optional: show the tabline even if only one tab is open
        vim.opt.showtabline = 2
    end,
    config = function()
        -- Mapping keys to navigate tabs
        -- Note: vem-tabline uses <Plug> maps and requires 'remap = true'
        local map = vim.keymap.set
        
        -- Next/Previous tab (buffer in vem-tabline)
        map('n', '<leader>n', '<Plug>vem_next_buffer-', { silent = true, remap = true, desc = "Next Tab" })
        map('n', '<leader>p', '<Plug>vem_prev_buffer-', { silent = true, remap = true, desc = "Previous Tab" })
        
        -- Close current tab
        map('n', '<leader>x', '<Plug>vem_delete_buffer-', { silent = true, remap = true, desc = "Close Tab" })
        
        -- Select specific tabs (1-9) using the index
        for i = 1, 9 do
            map('n', '<leader>' .. i, function()
                vim.cmd('VemTablineGo ' .. i)
            end, { silent = true, desc = "Go to Tab " .. i })
        end
    end
}
