return {
    'nvim-telescope/telescope.nvim',
    version = '*',
    dependencies = {
        'nvim-lua/plenary.nvim',
        -- optional but recommended
        { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    },
    config = function()
        local actions = require('telescope.actions')
        require('telescope').setup({})

    -- Get all buffers that are listed (opened) and loaded
    local function get_open_buffers()
        local buffers = {}
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_buf_get_name(buf) ~= "" then
                table.insert(buffers, vim.api.nvim_buf_get_name(buf))
            end
        end
        return buffers
    end

    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local conf = require("telescope.config").values
    local action_state = require("telescope.actions.state")
    -- Custom picker
    local function buffers_in_tabs_picker()
        pickers.new({}, {
            prompt_title = "Open Buffers in Tabs",
            finder = finders.new_table {
                results = get_open_buffers()
            },
            sorter = conf.generic_sorter({}),
            -- attach_mappings = function(prompt_bufnr, map)
            --     actions.select_default:replace(function()
            --         local selection = action_state.get_selected_entry()
            --         actions.close(prompt_bufnr)
            --         vim.cmd("tabnew " .. vim.fn.fnameescape(selection))
            --     end)
            --     return true
            -- end,
        }):find()
    end

    local builtin = require('telescope.builtin')
    vim.keymap.set('n', '<leader>fa', builtin.find_files, {})
    vim.keymap.set("n", "<leader>fb", buffers_in_tabs_picker, { desc = "Find files in open tabs" })
    vim.keymap.set('n', '<C-g>', builtin.git_files, {})
    vim.keymap.set('n', '<leader>fw', function()
        local word = vim.fn.expand("<cword>")
        builtin.grep_string({ search = word })
    end)
    vim.keymap.set('n', '<leader>fW', function()
        local word = vim.fn.expand("<cWORD>")
        builtin.grep_string({ search = word })
    end)
    vim.keymap.set('n', '<leader>fG', function()
        builtin.grep_string({ search = vim.fn.input("Grep > ") })
    end)
    vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
    vim.keymap.set('n', '<leader>vh', builtin.help_tags, {})
end
}
