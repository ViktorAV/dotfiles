return {
    'numToStr/FTerm.nvim',
    config = function()
        require('FTerm').setup({

        })
        -- nnoremap <leader>c :w <bar> :FloatermSend clear && python3 %<CR>:FloatermToggle<CR>
        vim.keymap.set('n', '<C-\\>', '<C-\\><C-n><CMD>lua require("FTerm").toggle()<CR>')
        vim.keymap.set('t', '<C-\\>', '<C-\\><C-n><CMD>lua require("FTerm").toggle()<CR>')
        vim.keymap.set('t', '<C-[>', '<C-\\><C-n><CMD>lua require("FTerm").close()<CR>')
    end
}
