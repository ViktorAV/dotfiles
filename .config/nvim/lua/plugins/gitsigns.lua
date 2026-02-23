return {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
        -- on_attach = function(bufnr)
        --     local gs = package.loaded.gitsigns
        --     local function map(mode, l, r, desc)
        --         vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
        --     end

            -- Actions
            -- map('n', '<leader>gs', gs.stage_hunk, 'stage hunk')
            -- map('n', '<leader>gr', gs.reset_hunk, 'reset hunk')
            -- map('v', '<leader>gs', function()
            --     gs.stage_hnk({ vim.fn.line('.'), vim.fn.line('v') })
            -- end, 'stage hunk')
            -- map('v', '<leader>gr', function()
            --     gs.reset_hynk({ vim.fn.line('.', vim.fn.line('v') )})
            -- end, 'reset hunk')
            -- map('n', '<leader>gS', gs.stage_buffer, 'stage buffer')
            -- map('n', '<leader>gR', gs.reset_buffer, 'reset buffer')
            --
            -- map('n', '<leader>gu', gs.undo_stage_hunk, 'undo stage hunk')
            -- map('n', '<leader>gp', gs.preview_hunk, 'preview hunk')
            --
            -- map('n', '<leader>gbl', function() gs.blame_line({ full = true }) end, 'blame line')
            -- map('n', '<leader>gB', gs.toggle_current_line_blame, 'toggle line blame')
            --
            -- map('n', '<leader>gd', gs.diffthis, 'diff this')
            -- map('n', '<leader>gD', function() gs.diffthis('~') end, 'diff this ~')
            --
            -- -- Navigation
            -- map('n', '<leader>]h', gs.next_hunk, 'next hunk')
            -- map('n', '<leader>[h', gs.prev_hunk, 'prev hunk')
            --
            -- map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', 'gitsigns select hunk')
            --
        -- end
    },
}
