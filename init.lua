vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
vim.cmd("set number")
vim.o.scrolloff = 15
vim.o.sidescrolloff = 15

vim.g.mapleader = " " -- Make sure to set `mapleader` before lazy so your mappings are correct

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"


if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)


local opts = {}

local plugins = {
  -- Treesitter
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
  -- Colorcheme Kanagawa
  {
    "rebelot/kanagawa.nvim",
  },
  -- Telescope
  { 'nvim-telescope/telescope.nvim',   tag = '0.1.5',      dependencies = { 'nvim-lua/plenary.nvim' } },
  -- NeoTree
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
    }
  },
  -- Lualine
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' }
  },
  -- Mason
  {
    "williamboman/mason.nvim"
  },
  {
    "williamboman/mason-lspconfig.nvim",
  },
  {
    "neovim/nvim-lspconfig",
  },
  -- Linting, Formatting (none-ls built over null-ls)
  {
    "nvimtools/none-ls.nvim",
  },
  -- Autocompletion window
  {
    "hrsh7th/nvim-cmp",
  },
  -- Luasnip, Completion Luasnip
  {
    'L3MON4D3/LuaSnip',
    dependencies = {
      'saadparwaiz1/cmp_luasnip',
    }
  },
  -- Friendly snippets (from VSCode)
  {
    'rafamadriz/friendly-snippets',
  },
  -- Main LSP Completion
  {
    'hrsh7th/cmp-nvim-lsp',
  },
  -- Actions with brackets
  {
    'm4xshen/autoclose.nvim',
  },
  --Highlight non-printable characters
  {
    { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },
  },
}

require("lazy").setup(plugins, opts)

-- Treesitter
local tsConfig = require("nvim-treesitter.configs")

tsConfig.setup({
  ensure_installed = { "lua", "javascript", "html", "typescript", "css" },
  sync_install = false,
  highlight = { enable = true },
  indent = { enable = true },
})

-- Colorscheme Kanagawa
require("kanagawa").setup({
  compile = false,  -- enable compiling the colorscheme
  undercurl = true, -- enable undercurls
  commentStyle = { italic = false },
  functionStyle = {},
  keywordStyle = { italic = false },
  statementStyle = { bold = true },
  typeStyle = {},
  transparent = true,   -- do not set background color
  dimInactive = false,   -- dim inactive window `:h hl-NormalNC`
  terminalColors = true, -- define vim.g.terminal_color_{0,17}
  colors = {             -- add/modify theme and palette colors
    palette = {},
    theme = { wave = {}, lotus = {}, dragon = {}, all = {} },
  },
  overrides = function(colors) -- add/modify highlights
    return {}
  end,
  theme = "wave",  -- Load "wave" theme when 'background' option is not set
  background = {   -- map the value of 'background' option to a theme
    dark = "wave", -- try "dragon" !
    light = "lotus"
  },

})
vim.cmd.colorscheme "kanagawa"
-- Telescope bindings
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

-- NeoTree bindings
vim.keymap.set('n', '<leader>n', ':Neotree filesystem reveal float toggle<CR>')

-- LuaLine setup
require('lualine').setup()

-- Mason setup
require('mason').setup()

-- Mason LSPConfig
require("mason-lspconfig").setup({
  ensure_installed = { "lua_ls", "tsserver", "html", "jsonls", "cssls", "emmet_ls", "marksman", },
  automatic_installation = true,
})

-- NVIM LSPConfig
local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

lspconfig.lua_ls.setup({
  capabilities
})
lspconfig.tsserver.setup({
  capabilities = capabilities
})
lspconfig.html.setup({
  capabilities = capabilities
})
lspconfig.jsonls.setup({
  capabilities = capabilities
})
lspconfig.cssls.setup({
  capabilities = capabilities
})
lspconfig.emmet_ls.setup({
  capabilities = capabilities
})
lspconfig.marksman.setup({
  capabilities = capabilities
})

-- "K" (английская) в нормал моде покажет документацию по функции на которой расположен курсор в даннй момент
vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})

-- Go to definition
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})

-- Code actions
vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, {})

-- None-ls - Null-ls
local null_ls = require("null-ls")
null_ls.setup({
  sources = {
    null_ls.builtins.formatting.prettier,
    null_ls.builtins.diagnostics.eslint_d,
    null_ls.builtins.completion.spell,
  }
  --null_ls.builtins.formatting.prettier,
  --null_ls.builtins.completion.spell,
})

-- Format files by pressing " "gf
vim.keymap.set('n', '<leader>gf', vim.lsp.buf.format, {})

-- Autocompletion window setup
local cmp = require('cmp')

cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  window = {
    --completion = cmp.config.window.bordered(),
    --documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    -- Строку ниже хочу заменить на Tab (уже заменил)
    ['<Tab>'] = cmp.mapping.confirm({ select = true }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp', priority = 1 },
    { name = 'luasnip', priority = 2},
  }, {
    { name = 'buffer' }
  }),
})

--Actions with brackets setup
require("autoclose").setup()

--Highlight non-printable characters
local myHighlight = {
  "Whitespace",
  "NonText",
}
require("ibl").setup({
  indent = { char = "▏" },
  whitespace = { highlight = myHighlight },
  scope = { enabled = false },
})

require('luasnip.loaders.from_vscode').lazy_load()
