return {
    'nvim-lualine/lualine.nvim',
    branch = 'master',
    dependencies = { 'nvim-tree/nvim-web-devicons', version = '*' },
    config = function ()
        require('lualine').setup({})
    end
}
