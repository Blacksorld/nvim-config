return {
    'akinsho/bufferline.nvim',
    version = "*",
    dependencies = {'nvim-tree/nvim-web-devicons', version = '*'},
    config = function()
        require('bufferline').setup({})
    end
}
