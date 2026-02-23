local set = vim.opt_local

-- set.tabstop = 4
-- set.shiftwidth = 4
-- set.softtabstop = 4
vim.api.nvim_create_user_command('FTermPython', function()
    require('FTerm').run({'clear && ipython ', vim.api.nvim_buf_get_name(0)})
end, { bang = true })
vim.keymap.set('n', '<CR>', ':w<CR>:FTermPython<CR>')
