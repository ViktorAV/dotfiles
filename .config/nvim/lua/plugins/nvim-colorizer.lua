return {
    'roobert/tailwindcss-colorizer-cmp.nvim',
    {
        'NvChad/nvim-colorizer.lua',
        dependencies = { 'nvim-treesitter/nvim-treesitter' },
        config = function()
            local nvchadcolorizer = require('colorizer')
            local tailwindcolorizer = require('tailwindcss-colorizer-cmp')

            nvchadcolorizer.setup({
                user_default_options = {
                    tailwind = true,
                },
                filetypes = { 'lua', 'html', 'css', 'javascript', 'typescript', 'jsx', 'tsx', 'vue', 'python' },
            })

            tailwindcolorizer.setup({
                color_square_width = 2,
            })
            vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufNewFile' }, {
                callback = function()
                    vim.cmd('ColorizerAttachToBuffer')
                end,
            })
        end,
    }
}
