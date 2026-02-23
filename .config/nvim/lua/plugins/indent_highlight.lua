return {
    "nvim-mini/mini.indentscope",
    version = false,
    config = function()
        require('mini.indentscope').setup({
            draw = {
                delay = 200,
            },
            -- options = {
            --     border = 'both', -- both, top, bottom, none
            --     indent_at_cursot = true,
            --     n_lines = 10000,
            --     try_as_border = false,
            -- },
            symbol = '│', -- ╎
        })
    end
}
