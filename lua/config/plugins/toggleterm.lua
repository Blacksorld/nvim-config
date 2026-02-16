return {
    'akinsho/toggleterm.nvim',
    version = '*',
    config = function()
        local toggleterm_opts = {
            size = 15,
            hide_numbers = true,
            shade_terminals = false,
            shading_factor = 0,
            persist_size = true,
            close_on_exit = true,
            terminal_mappings = true,
        }
        -- Ensure toggleterm is installed
        require("toggleterm").setup(vim.tbl_extend("force", {
            open_mapping = nil,
            direction = "horizontal", -- default direction
        }, toggleterm_opts))

        -- Create persistent terminal instances
        local Terminal  = require('toggleterm.terminal').Terminal

        -- Horizontal terminal inherits base config
        local hterm = Terminal:new(vim.tbl_extend("force", {
            direction = "horizontal",
            hidden = true,
        }, toggleterm_opts))

        -- Toggle functions
        function _HTerm_toggle()
            hterm:toggle()
        end

        -- Terminal mode toggle function (works inside terminal)
        function _HTerm_toggle_from_term()
            -- If in terminal mode, switch to normal first then toggle
            if vim.fn.mode() == "t" then
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true), "n", false)
            end
            hterm:toggle()
        end

        -- Keymaps
        vim.api.nvim_set_keymap("n", "<A-h>", "<cmd>lua _HTerm_toggle()<CR>", {noremap = true, silent = true})
        vim.api.nvim_set_keymap("t", "<A-h>", "<cmd>lua _HTerm_toggle_from_term()<CR>", {noremap = true, silent = true})
    end
}
