return {
    "neovim/nvim-lspconfig",
    version = "*",
    dependencies = {
        "stevearc/conform.nvim",
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        -- "hrsh7th/cmp-cmdline",
        "hrsh7th/nvim-cmp",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        "j-hui/fidget.nvim",
    },

    config = function()
        require("conform").setup({
            formatters_by_ft = {}
        })
        local cmp = require('cmp')
        local cmp_lsp = require("cmp_nvim_lsp")
        local capabilities = vim.tbl_deep_extend(
            "force",
            {},
            vim.lsp.protocol.make_client_capabilities(),
            cmp_lsp.default_capabilities())

            local on_attach = function(_, bufnr)
                local opts = { buffer = bufnr }
                vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
                vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
                vim.keymap.set("n", "<leader>ws", function() vim.lsp.buf.workspace_symbol() end, opts)
                vim.keymap.set("n", "<leader>ds", function() vim.diagnostic.open_float() end, opts)
                vim.keymap.set("n", "<leader>ca", function() vim.lsp.buf.code_action() end, opts)
                vim.keymap.set("n", "<leader>rr", function() vim.lsp.buf.references() end, opts)
                vim.keymap.set("n", "<leader>rn", function() vim.lsp.buf.rename() end, opts)
                vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
                -- vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
                -- vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
            end
            require("fidget").setup({})

            local ensure_installed = { "lua_ls", "gopls", "pylsp", "dockerls", "clangd" }
            -- LSP servers setup: loop over ensure_installed
            local lspconfig = require("lspconfig")
            for _, server_name in ipairs(ensure_installed) do
                if server_name == "lua_ls" then
                    lspconfig.lua_ls.setup({
                        capabilities = capabilities,
                        on_attach = on_attach,
                        settings = {
                            Lua = {
                                runtime = { version = "LuaJIT" },
                                diagnostics = { globals = { "vim" } },
                                workspace = {
                                    library = vim.api.nvim_get_runtime_file("", true),
                                    checkThirdParty = false,
                                },
                                format = {
                                    enable = true,
                                    -- Put format options here
                                    -- NOTE: the value should be STRING!!
                                    defaultConfig = {
                                        indent_style = "space",
                                        indent_size = "4",
                                    },
                                },
                            },
                        },
                    })
                else
                    lspconfig[server_name].setup({
                        capabilities = capabilities,
                        on_attach = on_attach,
                    })
                end
            end

            -- require("lspconfig").clangd.setup({
            --     cmd = {
            --         "docker",
            --         "exec",
            --         "-i",
            --         "rocky",
            --         "clangd",
            --         "--background-index",
            --         "--clang-tidy",
            --     },
            --     capabilities = capabilities,
            --     on_attach = on_attach,
            -- })


            require("mason").setup()
            require("mason-lspconfig").setup({
                ensure_installed = ensure_installed,
                -- automatic_enable = true,
            })

            local cmp_select = { behavior = cmp.SelectBehavior.Select }

            cmp.setup({
                snippet = {
                    expand = function(args)
                        require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ['<S-Tab>'] = cmp.mapping.select_prev_item(cmp_select),
                    ['<Tab>'] = cmp.mapping.select_next_item(cmp_select),
                    ['<CR>'] = cmp.mapping.confirm({ select = true }),
                    ["<C-Space>"] = cmp.mapping.complete(),
                }),
                sources = cmp.config.sources({
                    { name = 'nvim_lsp' },
                    { name = 'luasnip' }, -- For luasnip users.
                    { name = 'path' },
                }, {
                    { name = 'buffer' },
                })
            })

            vim.diagnostic.config({
                -- update_in_insert = true,
                float = {
                    focusable = false,
                    style = "minimal",
                    border = "rounded",
                    source = true,
                    -- header = "",
                    -- prefix = "",
                },
            })
        end
    }
