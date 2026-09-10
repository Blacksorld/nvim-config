return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "stevearc/conform.nvim",
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/nvim-cmp",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        "j-hui/fidget.nvim",
    },

    config = function()
        require("conform").setup({
            formatters_by_ft = {}
        })
        require("fidget").setup({})

        local cmp = require('cmp')
        local cmp_lsp = require("cmp_nvim_lsp")
        local capabilities = vim.tbl_deep_extend(
            "force",
            {},
            vim.lsp.protocol.make_client_capabilities(),
            cmp_lsp.default_capabilities())

        -- Keymaps via LspAttach autocmd (replaces on_attach)
        vim.api.nvim_create_autocmd('LspAttach', {
            callback = function(ev)
                local opts = { buffer = ev.buf }
                vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
                vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
                vim.keymap.set("n", "<leader>ws", vim.lsp.buf.workspace_symbol, opts)
                vim.keymap.set("n", "<leader>ds", vim.diagnostic.open_float, opts)
                vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
                vim.keymap.set("n", "<leader>rr", vim.lsp.buf.references, opts)
                vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
                vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)
            end,
        })

        -- Shared config for all servers
        vim.lsp.config('*', {
            capabilities = capabilities,
        })

        -- Per-server configs
        vim.lsp.config('lua_ls', {
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
                        defaultConfig = {
                            indent_style = "space",
                            indent_size = "4",
                        },
                    },
                },
            },
        })

        vim.lsp.config('pylsp', {
            root_markers = { '.git' },
        })

        -- Enable servers
        vim.lsp.enable({ "lua_ls", "gopls", "pylsp", "dockerls", "clangd" })

        -- Mason
        require("mason").setup()
        require("mason-lspconfig").setup({
            ensure_installed = { "lua_ls", "gopls", "pylsp", "dockerls", "clangd" },
        })

        -- Completion
        local cmp_select = { behavior = cmp.SelectBehavior.Select }
        cmp.setup({
            snippet = {
                expand = function(args)
                    require('luasnip').lsp_expand(args.body)
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
                { name = 'luasnip' },
                { name = 'path' },
            }, {
                { name = 'buffer' },
            })
        })

        vim.diagnostic.config({
            float = {
                focusable = false,
                style = "minimal",
                border = "rounded",
                source = true,
            },
        })
    end
}
