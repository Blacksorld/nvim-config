return {
    "theprimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim"},
    config = function()
        local harpoon = require("harpoon")

        harpoon:setup()

        -- basic telescope configuration
        local conf = require("telescope.config").values
        local function toggle_telescope(harpoon_files)
            local make_finder = function()
                local paths = {}
                for _, item in ipairs(harpoon_files.items) do
                    table.insert(paths, item.value)
                end

                return require("telescope.finders").new_table(
                    {
                        results = paths
                    }
                )
            end

            require("telescope.pickers").new({}, {
                prompt_title = "Harpoon",
                finder = make_finder(),
                previewer = conf.file_previewer({}),
                sorter = conf.generic_sorter({}),
                attach_mappings = function(prompt_buffer_number, map)
                    map(
                        {"i", "n"},
                        "<C-d>",
                        function()
                            local state = require("telescope.actions.state")
                            local selected_entry = state.get_selected_entry()
                            local current_picker = state.get_current_picker(prompt_buffer_number)

                            table.remove(harpoon_files.items, selected_entry.index)
                            current_picker:refresh(make_finder())
                        end
                    )
                    return true
                end
            }):find()
        end

        vim.keymap.set("n", "<C-e>", function() toggle_telescope(harpoon:list()) end,
        { desc = "Open harpoon window" })

        vim.keymap.set("n", "<leader>A", function()
            harpoon:list():prepend()
        end)
        vim.keymap.set("n", "<leader>a", function()
            harpoon:list():add()
        end)

        vim.keymap.set("n", "<C-1>", function()
            harpoon:list():select(1)
        end)
        vim.keymap.set("n", "<C-2>", function()
            harpoon:list():select(2)
        end)
        vim.keymap.set("n", "<C-3>", function()
            harpoon:list():select(3)
        end)
        vim.keymap.set("n", "<C-4>", function()
            harpoon:list():select(4)
        end)
    end,
}
