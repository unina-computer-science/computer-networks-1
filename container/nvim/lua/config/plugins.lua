-- CN1: the bootstrap below clones nothing inside the container: lazy.nvim
-- and every plugin were downloaded at build time.
-- Bootstrap lazy.nvim.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({

    -- Theme.
    {
        "rebelot/kanagawa.nvim",
        priority = 1000,
        config = function()
            vim.cmd("colorscheme kanagawa")
        end,
    },

    -- Icons for which-key and other plugins.
    { "nvim-tree/nvim-web-devicons", lazy = true },

    -- Syntax highlighting.
    -- CN1: four languages instead of sixteen, and parsers built at image
    -- time by the Dockerfile: nothing is installed here, because in class the
    -- network may not be there. The version is pinned: since January 2026 the
    -- main branch wants tree-sitter-cli 0.26.1 and then Neovim 0.12, while
    -- Ubuntu 26.04 has tree-sitter-cli 0.25.9 and Neovim 0.11.6. Unpin it
    -- when the image carries newer versions.
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        commit = "99dfc5acefd7728cec4ad0d0a6a9720f2c2896ff",
        lazy = false,
        config = function()
            local ts = require("nvim-treesitter")
            ts.setup({})
            vim.api.nvim_create_autocmd("FileType", {
                pattern = { "c", "sh", "bash", "make", "lua" },
                callback = function()
                    vim.treesitter.start()
                    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end,
            })
        end,
    },

    -- Fuzzy finder.
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        keys = {
            { "<leader>f", "<cmd>Telescope find_files<CR>", desc = "Find files" },
            { "<leader>g", "<cmd>Telescope live_grep<CR>", desc = "Live grep" },
            { "<leader>b", "<cmd>Telescope buffers<CR>", desc = "Buffers" },
            { "<leader>h", "<cmd>Telescope help_tags<CR>", desc = "Help" },
        },
    },

    -- LSP.
    {
        "neovim/nvim-lspconfig",
        config = function()
            local on_attach = function(_, bufnr)
                local map = function(keys, func, desc)
                    vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
                end
                map("gd", vim.lsp.buf.definition, "Go to definition")
                map("K", vim.lsp.buf.hover, "Hover documentation")
                map("<leader>e", vim.diagnostic.open_float, "Show error")
                map("[d", vim.diagnostic.goto_prev, "Previous diagnostic")
                map("]d", vim.diagnostic.goto_next, "Next diagnostic")
            end
            -- CN1: clangd only. The other five would error out at startup:
            -- their binaries are not in the container.
            local servers = { "clangd" }
            for _, server in ipairs(servers) do
                vim.lsp.config[server] = {
                    on_attach = on_attach,
                }
                vim.lsp.enable(server)
            end
        end,
    },

    -- Autocompletion.
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            { "L3MON4D3/LuaSnip", build = "make install_jsregexp" },
            "saadparwaiz1/cmp_luasnip",
        },
        config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")
            cmp.setup({
                completion = {
                    autocomplete = false,
                },
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                    { name = "buffer" },
                    { name = "path" },
                }),
            })
        end,
    },

    -- File explorer.
    {
        "stevearc/oil.nvim",
        keys = {
            { "-", "<cmd>Oil<CR>", desc = "Open file explorer" },
        },
        config = function()
            require("oil").setup()
        end,
    },

    -- Git signs in gutter.
    {
        "lewis6991/gitsigns.nvim",
        config = function()
            require("gitsigns").setup()
        end,
    },

    -- Keybinding helper.
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        config = function()
            require("which-key").setup()
        end,
    },

    -- CN1: vimtex removed. LaTeX is not built in the container.

}, {
    rocks = { enabled = false },
})
