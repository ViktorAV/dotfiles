return {
    'obsidian-nvim/obsidian.nvim',
    version = '*',
    lazy = true,
    ft = 'markdown',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
        require('obsidian').setup({
            legacy_commands = false,
            statusline = {
                enabled = false,
            },
            frontmatter = {
                enabled = false,
            },
            footer = {
                enabled = false,
            },
            backlinks = {
                parse_headers = false,
            },

            workspaces = {
                {
                    name = 'main',
                    path = '~/yadisk/notes',
                },
            },
            daily_notes = {
                folder = 'dailies',
                date_format = '%Y-%m-%d',
                -- alias_format = '%B %-d, %Y'
                -- default_tags = { 'daily' },
                template = nil,
            },
            completion = {
                blink = true,
                min_chars = 2,
            },
            templates = {
                enabled = true,
                folder = 'templates',
                date_format = 'YYYY-MM-DD',
                time_format = 'HH:mm',
                -- substitutions = {},
            },
            note = {
              template = (function()
                  return '~/yadisk/notes/templates/default.md'
              end)(),
            },

            preferred_link_style = 'markdown',

            -- Имя файла
            note_id_func = function(title)
                local path = title:lower()
                path = path:gsub(' ', '_'):gsub('%(', ''):gsub('%)', '')
                path = path:gsub('-', '_'):gsub('%.', '_'):gsub('/', '_')
                return path
            end,

            -- note_path_func = function(spec)
            --     local path = (spec.dir / tostring(spec.id)):upper()
            --     return path
            --
            --     -- if spec.title == nil then
            --     --     return spec
            --     -- end
            --     -- local path = spec.title:lower()
            --     -- path = path:gsub(' ', '_'):gsub('%(', ''):gsub('%)', '')
            --     -- path = path:gsub('-', '_'):gsub('%.', '_'):gsub('/', '_')
            --     -- return path
            -- end,

            ui = {
                enable = false, -- false to disable all additional syntax features
                -- update_debounce = 200, -- update delay after a text change in ms
                -- max_file_length = 5000, -- disable UI features for that files
                -- checkboxes = {
                --   [" "] = { char = "󰄱", hl_group = "obsidiantodo" },
                --   ["x"] = { char = "", hl_group = "obsidiandone" },
                --   -- ["~"] = { char = "󰰱", hl_group = "obsidiantilde" },
                --   -- ["!"] = { char = "", hl_group = "obsidianimportant" },
                --   -- [">"] = { char = "", hl_group = "obsidianrightarrow" },
                -- },
            }
        })

        vim.keymap.set('n', '<leader>ni', ':Obsidian template<cr>', { desc = "insert template" })
        vim.keymap.set('n', '<leader>na', ':Obsidian new<cr>', { desc = "add note" })
        vim.keymap.set('n', '<leader>nl', ':Obsidian quick_switch<cr>', { desc = "open note" })
        vim.keymap.set('n', '<leader>ns', ':Obsidian search<cr>', { desc = "search note" })
        vim.keymap.set('n', '<leader>nb', ':Obsidian backlinks<cr>', { desc = "obisidian backlinks" })
    end
}
