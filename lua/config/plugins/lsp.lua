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

        -- Spinner for slow user-initiated requests. rust-analyzer reports no progress for
        -- on-demand analysis (e.g. the first gd into a crate with cachePriming off), so
        -- without this a slow lookup looks like nothing happened.
        local slow_methods = {
            ['textDocument/definition'] = 'definition',
            ['textDocument/declaration'] = 'declaration',
            ['textDocument/typeDefinition'] = 'type definition',
            ['textDocument/implementation'] = 'implementation',
            ['textDocument/references'] = 'references',
            ['textDocument/hover'] = 'hover',
            ['textDocument/rename'] = 'rename',
            ['textDocument/codeAction'] = 'code action',
        }
        local pending = {}
        vim.api.nvim_create_autocmd('LspRequest', {
            callback = function(ev)
                local req = ev.data.request
                local title = slow_methods[req.method]
                if not title then
                    return
                end
                local key = ev.data.client_id .. ':' .. ev.data.request_id
                if req.type == 'pending' then
                    local entry = {
                        timer = vim.uv.new_timer(),
                        client_id = ev.data.client_id,
                        request_id = ev.data.request_id,
                    }
                    pending[key] = entry
                    entry.timer:start(500, 0, vim.schedule_wrap(function()
                        if pending[key] ~= entry then
                            return -- answered within 500ms
                        end
                        local client = vim.lsp.get_client_by_id(ev.data.client_id)
                        entry.handle = require('fidget.progress').handle.create({
                            title = title,
                            message = 'waiting for server',
                            lsp_client = { name = client and client.name or 'lsp' },
                        })
                    end))
                    return
                end
                local entry = pending[key]
                if not entry then
                    return
                end
                pending[key] = nil
                entry.timer:stop()
                entry.timer:close()
                if entry.handle then
                    if req.type == 'cancel' then
                        entry.handle:cancel()
                    else
                        entry.handle:finish()
                    end
                end
            end,
        })

        -- Cancel every pending lookup above. The server acknowledges the cancel and Neovim
        -- drops the callback, so the late jump never happens, unless the answer was already
        -- in flight.
        vim.keymap.set("n", "<leader>lc", function()
            local entries = vim.tbl_values(pending)
            for _, entry in ipairs(entries) do
                local client = vim.lsp.get_client_by_id(entry.client_id)
                if client then
                    client:cancel_request(entry.request_id) -- fires LspRequest 'cancel'
                end
            end
            vim.notify(('Cancelled %d pending LSP request(s)'):format(#entries))
        end, { desc = "Cancel pending LSP lookups" })

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

        local ra_wrapper = 'scripts/rust-analyzer-container.sh'
        vim.lsp.config('rust_analyzer', {
            cmd = function(dispatchers, config)
                return vim.lsp.rpc.start({ config.root_dir .. '/' .. ra_wrapper }, dispatchers)
            end,
            root_dir = function(bufnr, on_dir)
                local root = vim.fs.root(bufnr, { '.git' })
                if root and vim.uv.fs_stat(root .. '/' .. ra_wrapper) then
                    on_dir(root)
                end
            end,
            settings = {
                ['rust-analyzer'] = {
                    -- Own target dir (target/rust-analyzer): cargo fingerprints embed
                    -- absolute paths and cargo locks the target dir, so sharing target/
                    -- with `make` builds from /workspace would thrash and block.
                    cargo = { targetDir = true },
                    check = { command = 'clippy' },
                    cachePriming = { enable = false },
                    files = {
                        exclude = { 'target', 'target-v2', '.venv', 'python/.venv' },
                    },
                },
            },
        })

        -- Enable servers
        vim.lsp.enable({ "lua_ls", "gopls", "pylsp", "dockerls", "clangd", "rust_analyzer" })

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
