return {
    'prichrd/netrw.nvim',
    version = '*',
    dependencies = {
        { 'nvim-tree/nvim-web-devicons', version = '*' }, 
    },
    config = function()
        require('netrw').setup({
            use_devicons = true,
        })
    end
}
