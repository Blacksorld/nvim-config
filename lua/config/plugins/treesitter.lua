return {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter').install({
          "vimdoc", "python", "c", "cpp",
          "lua", "javascript",
          "markdown", "markdown_inline", "go",
      })
    end,
}
