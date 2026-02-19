return {
    'echasnovski/mini.comment',
    version = false,
    dependencies = {
        "JoosepAlviste/nvim-ts-context-commentstring",
    },
    config = function()
        -- disable the autocommand from ts-context-commentstring
        require('ts_context_commentstring').setup {
            enable_autocmd = false,
        }

        require("mini.comment").setup {
            -- tsx, jsx, html , svelte comment support
            options = {
                custom_commentstring = function()
                    return require('ts_context_commentstring.internal').calculate_commentstring({ key =
                        'commentstring' })
                        or vim.bo.commentstring
                end,
            },
            mappings = {
                -- Toggle comment (like `gcip` - comment inner paragraph) for both
                -- Normal and Visual modes
                comment = 'gc',

                -- Toggle comment on current line
                comment_line = 'gcc',

                -- Toggle comment on visual selection
                comment_visual = '/',

                -- Define 'comment' textobject (like `dgc` - delete whole comment block)
                -- Works also in Visual mode if mapping differs from `comment_visual`
                -- textobject = 'gc',
              },
        }
    end
}
