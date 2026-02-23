return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate", -- Command to run after installation/update
    lazy = false, -- Treesitter does not support lazy loading
    config = function()
      require("nvim-treesitter.config").setup({
        highlight = {
          enable = true, -- Enable Nvim's treesitter-based highlight
          additional_vim_regex_highlighting = false,
        },
        indent = { enable = true }, -- Enable treesitter-based indentation
        textobjects = { enable = true, },
        ensure_installed = {
          "bash",
          "css",
          "html",
          "javascript",
          "json",
          "lua",
          "markdown",
          "python",
          "typescript",
          "vim",
          "yaml",
          "markdown",
          "markdown_inline",
        }, -- Automatically install these language parsers
        auto_install = true, -- Automatically install missing parsers
      })
    end,
  },
  -- Optional: Add treesitter-textobjects for enhanced text manipulation
  { "nvim-treesitter/nvim-treesitter-textobjects", after = "nvim-treesitter" },
}
