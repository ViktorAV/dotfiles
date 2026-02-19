return {
    'stevearc/oil.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    lazy = false,
    config = function()
        require('oil').setup({
            default_file_explorer = true, -- start up nvim with oil instead of netrw,
            columns = {
                'icon',
            },
            keymaps = {
                ['<C-h>'] = false,
                ['<C-c>'] = false, -- prevents ctrl c from closing out of oil
                ['<M-h>'] = 'actions.select_split',
                ['<C-[>'] = 'actions.close',
            },
            delete_to_trash = true,
            view_options = {
                show_hidden = true,
            },
            float = {
                -- padding = 2,
                -- maxWidth = 0, -- 0 means no limit
                -- maxHeight = 0,
                border = 'single', -- single, double, shadow, rounded
            },
            skip_confirm_for_simple_edits = true,
        })

        -- vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'open parent directory over current window' })
        vim.keymap.set('n', '-', require('oil').toggle_float, { desc = 'toggle float oil over cur window' })

        -- selection highlight
        vim.api.nvim_create_autocmd('FileType', {
            pattern = 'oil',
            callback = function()
                vim.opt_local.cursorline = true
            end,
        })

    end,
}
