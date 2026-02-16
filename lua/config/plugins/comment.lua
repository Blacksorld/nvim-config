return {
    "numToStr/Comment.nvim",
    version = '*',
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
        require("Comment").setup({
            mappings = false
        })
        -- Normal mode: toggle current line
        vim.api.nvim_set_keymap(
            "n",
            "<leader>/",
            "<cmd>lua require('Comment.api').toggle.linewise.current()<CR>",
            { noremap = true, silent = true }
        )

        -- Visual mode: toggle selected lines
        vim.api.nvim_set_keymap(
            "v",
            "<leader>/",
            "<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>",
            { noremap = true, silent = true }
        )
    end,
}
