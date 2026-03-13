local set = vim.opt_local

-- set.tabstop = 4
-- set.shiftwidth = 4
-- set.softtabstop = 4
-- vim.api.nvim_create_user_command('FTermPython', function()
--     require('FTerm').run({'clear && ipython ', vim.api.nvim_buf_get_name(0)})
-- end, { bang = true })

-- vim.keymap.set('n', '<CR>', ':w<CR>:FTermPython<CR>')

-- vim.keymap.set('n', '<A-Enter>', ':Signal<CR>', { noremap = true, silent = true })

vim.keymap.set('n', '<Enter>', function()
    vim.cmd('w')
    local current_file = vim.api.nvim_buf_get_name(0)
    local command = 'silent !kitty --hold --title=float sh -c "python ' .. current_file .. '" 2>/dev/null'
    vim.cmd(command)
end, { noremap = true, silent = true })
