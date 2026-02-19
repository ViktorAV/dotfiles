return {
    'Mr-LLLLL/cool-chunk.nvim',
    event = { 'CursorHold', 'CursorHoldI' },
    dependencies = {
        'nvim-treesitter/nvim-treesitter',
    },
    config = function()
        require('cool-chunk').setup({})
    end
    -- 'nvimdev/indentmini.nvim',
    -- config = function()
    --     require('indentmini').setup() 
    --     -- There is no default value.
    --     vim.cmd.highlight('IndentLine guifg=#123456')
    --     -- Current indent line highlight
    --     vim.cmd.highlight('IndentLineCurrent guifg=#123456')
    -- end
}
