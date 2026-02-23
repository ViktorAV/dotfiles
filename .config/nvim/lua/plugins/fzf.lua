return {
    'ibhagwan/fzf-lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
        fzf = require('fzf-lua')
        fzf.setup({
            winopts = {
                -- height = 0.85,
                -- width = 0.80,
                -- row = 0.35, -- window row position (0=top, 1=bottom)
                -- col = 0.50, -- window col position (0=left, 1=right)
                -- border = 'rounded',
                -- split = 'belowright new', -- belowright, aboveleft new/vnew
                fullscreen = true,
                title = false,
                title_flags = false,
                preview = {
                    -- hidden = false,
                    layout = 'vertical', -- horizontal, vertical, flex
                    -- title = true, -- preview border title (file/buf)?
                    -- title_pos = 'center', -- left, center, right
                    -- horizontal = 'right:58%',
                    vertical = 'up:70%',
                    scrollbar = false, -- false or string float, border
                    title = false,
                },
            },
            fzf_opts = {
                ['--layout'] = 'default', -- default = cmd line at bottom
            },
            buffers = {
                ignore_current_buffer = false,
                show_unloaded = true,
                -- show_unloaded = true,
                -- cwd_only = true, -- show all buffers
                -- sort_last_used = true,
            },
            file_ignore_patterns = {
                -- '.git',
                '__pycache__',
            },
            -- files = {
            --     -- rg_opts = '--sort=path --color=never --files --hidden --follow'
            --     -- command = "find . -mindepth 1 -type f -print -o -type l -print"
            -- },
            -- grep = {
            --     rg_opts = '--column --line-number --no-heading --color=always --smart-case -L'
            -- },
        })

        vim.keymap.set('n', '<Tab>', fzf.buffers, { desc = 'List Buffers' })

        vim.keymap.set('n', '<leader>ff', fzf.files, { desc = 'Find Files' })

        vim.keymap.set('n', '<leader>fg', fzf.live_grep, { desc = 'Find in Grep' })

        vim.keymap.set('n', '<leader>fn', function()
            fzf.files({ cwd = '~/yadisk/notes' })
        end, {desc = 'Find notes'})

        vim.keymap.set('n', '<leader>fc', function()
            fzf.files({ cwd = '~/yadisk/dotfiles' })
        end, {desc = 'Find configs'})
    end,



        -- vim.keymap.set('n', '*', builtin.grep_string, { desc = 'Telescope matches' })
        -- -- vim.keymap.set('n', '<leader>ff', '<cmd>Telescope find_files search_dirs={"."}<CR>')
        -- vim.keymap.set('n', '<leader>ft', builtin.live_grep, { desc = 'Telescope live grep' })
        -- vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
        -- vim.keymap.set('n', '<leader>fr', builtin.oldfiles, { desc = 'Fuzzy find recent files' })
        -- vim.keymap.set('n', '<leader>fR', builtin.registers, { desc = 'Telescope find registers'})
        -- vim.keymap.set('n', '<leader>fT', '<cmd>Telescope themes<CR>', { desc = 'Theme switcher' })
        -- -- vim.keymap.set('n', '<leader>fn', ':Telescope find_files search_dirs={"~/yadisk/note"}<CR>')
        -- vim.keymap.set('n', '<leader>fm', builtin.marks, { desc = 'Telescope marks'})
        -- vim.keymap.set('n', '<leader>fj', builtin.jumplist, { desc = 'Telescope jumplist'})
        -- vim.keymap.set('n', '<leader>fk', builtin.keymaps, { desc = 'Telescope keymaps'})
        -- vim.keymap.set('n', '<leader>fs', builtin.spell_suggest, { desc = 'Telescope spell_suggest'})
        -- vim.keymap.set('n', '<leader>fq', builtin.quickfix, { desc = 'Telescope quickfix'})
        -- -- vim.keymap.set('n', '<leader>gb', builtin.git_branches, { desc = 'Telescope Git branches' })
        -- -- vim.keymap.set('n', '<leader>gc', builtin.git_commits, { desc = 'Telescope Git commits' })
        -- -- vim.keymap.set('n', '<leader>gs', builtin.git_status, { desc = 'Telescope Git status' })
        -- -- vim.keymap.set('n', '<leader>ls', builtin.lsp_document_symbols, { desc = 'Telescope document symbols' })
        -- vim.keymap.set('n', '<leader>u', '<cmd>Telescope undo<cr>')
}
