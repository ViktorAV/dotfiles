return {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
        'saghen/blink.cmp',
        { 'antosha417/nvim-lsp-file-operations', config = true },
    },

    config = function()
        -- Setup servers
        -- require('neodev').setup()
        local capabilities = require('blink.cmp').get_lsp_capabilities()

        local signs = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN]  = " ",
            [vim.diagnostic.severity.HINT]  = "󰠠 ",
            [vim.diagnostic.severity.INFO]  = " ",
        }

        -- Set the diagnostic config with all icons
        vim.diagnostic.config({
            signs = {
                text = signs -- Enable signs in the gutter
            },
            virtual_text = {
                spacing = 2,
                prefix = "●",
            },
            underline = true,     -- Specify Underline diagnostics
            -- update_in_insert = false,  -- Keep diagnostics active in insert mode
            -- float = {
            --     focusable = false,
            --     border = "rounded",
            -- },
        })

        vim.lsp.config('basedpyright', {
            capabilities = capabilities,
            settings = {
                basedpyright = {
                    typeCheckingMode = 'standard', -- off, standard
                    -- disableOrganizeImports = true,
                    -- ignore = { '*' },
                    -- diagnosticMode = 'off',
                },
            },

        })
        vim.lsp.enable('basedpyright')

        -- vim.lsp.config('marksman', {
        --     capabilities = capabilities,
        -- })
        -- vim.lsp.enable('marksman')
    end
}
