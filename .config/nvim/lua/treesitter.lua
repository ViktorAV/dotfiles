return {
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    build = ':TSUpdate',
    opts = {
        auto_install = false,
        highlight = {
            enable = true,
        },
        indent = {
            enable = true,
        },
        ensure_installed = {
            'json',
            -- 'javascript',
            'yaml',
            'html',
            'css',
            'python',
            -- 'http',
            'markdown',
            'markdown_inline',
            'bash',
            'lua',
            'vim',
            -- 'dockerfile',
            -- 'gitignore',
            -- 'query',
            -- 'c',
        },
    },
    config = function(_, opts)
        require('nvim-treesitter.config').setup(opts)
    end,
}
