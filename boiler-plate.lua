-- ===========================================================================
-- Basic Neovim Settings
-- These are general options that enhance the Neovim experience.
-- ===========================================================================

-- This version is compatible with neovim v0.7.2
-- Set leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Global options (opt) and window-local options (wo)
vim.opt.encoding = "utf-8"          -- Set encoding to UTF-8
vim.opt.fileencoding = "utf-8"      -- Set file encoding to UTF-8
vim.opt.termguicolors = true        -- Enable true colors in the terminal

vim.opt.nu = true                   -- Show line numbers
vim.opt.relativenumber = false       -- Show relative line numbers
vim.opt.title = true                -- Set terminal title
vim.opt.autoindent = true           -- Enable auto indentation
vim.opt.smartindent = true          -- Smarter auto indentation
vim.opt.hlsearch = true             -- Highlight search results
vim.opt.incsearch = true            -- Incremental search
vim.opt.mouse = "a"                 -- Enable mouse support in all modes

vim.opt.clipboard = "unnamedplus"   -- Sync with system clipboard

-- Tab settings
vim.opt.tabstop = 4                 -- Number of spaces for a tab
vim.opt.shiftwidth = 4              -- Number of spaces to indent
vim.opt.expandtab = true            -- Use spaces instead of tabs

-- Folding
vim.opt.foldmethod = "syntax"       -- Fold based on syntax
vim.opt.foldlevelstart = 99         -- Don't fold by default

-- Other common options
vim.opt.scrolloff = 8               -- Lines of context around cursor
vim.opt.signcolumn = "yes"          -- Always show the sign column
vim.opt.isfname:append("@-@")       -- Allow dashes in filenames
vim.opt.updatetime = 300            -- Faster completion popups
vim.opt.cmdheight = 1               -- Command line height
vim.opt.conceallevel = 0            -- Don't conceal anything (e.g., Markdown italics)
vim.opt.undofile = true             -- Persistent undo
vim.opt.swapfile = false            -- Disable swap files (Neovim handles crashes better)
vim.cmd [[
  augroup metta_lisp
    autocmd!
    autocmd BufRead,BufNewFile *.metta set filetype=lisp
  augroup END
]]

-- ===========================================================================
-- Packer.nvim setup (Plugin Manager)
-- This section bootstraps Packer and defines your plugins.
-- ===========================================================================

local fn = vim.fn

-- Auto-install Packer if it's not found
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
  vim.cmd [[packadd packer.nvim]]
end

-- Require Packer and configure it
return require('packer').startup(function(use)
  -- Packer itself
  use 'wbthomason/packer.nvim'

  -- ===========================================================================
  -- Essential Plugins
  -- Add your desired plugins here.
  -- ===========================================================================

  -- Icons for file trees, status lines, etc. (Requires a Nerd Font)
  use 'nvim-tree/nvim-web-devicons'

  -- File Explorer
  use {
    'nvim-tree/nvim-tree.lua',
    requires = {
      'nvim-tree/nvim-web-devicons', -- optional, for file icons
    },
    config = function()
      require("nvim-tree").setup {
        -- Your nvim-tree configuration options here
        sort_by = "case_sensitive",
        view = {
          width = 30,
        },
        renderer = {
          group_empty = true,
        },
        filters = {
          dotfiles = true,
        },
      }
    end
  }

  -- Fuzzy Finder (files, buffers, help, etc.)
  use {
    'nvim-telescope/telescope.nvim', tag = '0.1.x', -- v0.1.x is compatible with Neovim 0.7
    requires = { {'nvim-lua/plenary.nvim'} }
  }

  -- Colorscheme (example: gruvbox)
  use {
    'ellisonleao/gruvbox.nvim',
    config = function()
      vim.cmd.colorscheme "gruvbox"
    end
  }

  -- Status Line
  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'nvim-tree/nvim-web-devicons', opt = true },
    config = function()
      require('lualine').setup {
        options = {
          icons_enabled = true,
          theme = 'auto', -- or 'gruvbox' to match theme
          component_separators = { '▍', '▍'},
          section_separators = { '', ''},
          disabled_filetypes = {
            statusline = {},
            winbar = {},
          },
          always_last_status = 0,
          globalstatus = false,
          refresh = {
            statusline = 1000,
            tabline = 1000,
            winbar = 1000,
          }
        },
        sections = {
          lualine_a = {'mode'},
          lualine_b = {'branch', 'diff', 'diagnostics'},
          lualine_c = {'filename'},
          lualine_x = {'encoding', 'fileformat', 'filetype'},
          lualine_y = {'progress'},
          lualine_z = {'location'}
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = {'filename'},
          lualine_x = {'location'},
          lualine_y = {},
          lualine_z = {}
        },
        tabline = {},
        winbar = {},
        extensions = {'nvim-tree'} -- integrates with nvim-tree
      }
    end
  }
  
  use {
    'p00f/nvim-ts-rainbow',
    requires = 'nvim-treesitter/nvim-treesitter'
  }
  
 

  -- Nvim-cmp (Autocompletion)
  -- This set is crucial for a modern IDE-like experience.
  use 'hrsh7th/nvim-cmp'             -- The completion plugin
  use 'hrsh7th/cmp-buffer'           -- Source for text in current buffer
  use 'hrsh7th/cmp-path'             -- Source for file system paths
  use 'hrsh7th/cmp-nvim-lsp'         -- Source for Neovim's built-in LSP
  use 'hrsh7th/cmp-nvim-snippet'     -- Source for nvim-cmp to use with snippets
  use 'saadparwaiz1/cmp_luasnip'     -- Snippet source for nvim-cmp
  use 'L3MON4D3/LuaSnip'             -- Snippet engine

  -- Nvim-LSPConfig (Built-in LSP client configurations)
  use {
    'neovim/nvim-lspconfig',
    config = function()
      -- Example LSP setup for Lua and Python. You'll add more as needed.
      local lspconfig = require('lspconfig')

      -- Lua LSP (lua_ls)
      lspconfig.lua_ls.setup {
        settings = {
          Lua = {
            diagnostics = {
              globals = {'vim'},
            },
            workspace = {
              library = vim.api.nvim_get_runtime_and_data_paths(),
            },
          },
        },
      }

      -- Python LSP (pyright)
      lspconfig.pyright.setup {
        -- Additional pyright settings if needed
      }

      -- Set up a common on_attach function for LSP clients
      -- This function defines keymaps and autocommands when an LSP client attaches
      local on_attach = function(client, bufnr)
        -- Enable completion for the current buffer
        vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

        -- Mappings.
        -- See `:help vim.lsp.*` for documentation on these functions
        local bufopts = { noremap=true, silent=true, buffer=bufnr }
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
        vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, bufopts)
        vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
        vim.keymap.set('n', '<leader>wl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, bufopts)
        vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, bufopts)
        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
        vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
        vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format { async = true } end, bufopts)

        -- Autoformat on save
        if client.server_capabilities.documentFormattingProvider then
          vim.api.nvim_create_autocmd("BufWritePre", {
            group = vim.api.nvim_create_augroup("LspFormatting", { clear = true }),
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format { async = false }
            end,
          })
        end
      end

      -- Attach on_attach to all LSP servers
      lspconfig.util.default_config = vim.tbl_deep_extend(
          'force',
          lspconfig.util.default_config,
          {
              on_attach = on_attach,
          }
      )
    end
  }

  -- Nvim-Treesitter (Syntax Highlighting)
   use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = {
          "c", "lua", "vim", "vimdoc", "query", "python",
          "javascript", "typescript", "html", "css", "json", "lisp"  
        },
        highlight = {
          enable = true,
        },
        indent = {
          enable = true
        },
        rainbow = {
          enable = true,
          extended_mode = true,
          max_file_lines = nil,
        }
      }
    end
  }

  -- ===========================================================================
  -- Nvim-cmp (Autocompletion) configuration
  -- ===========================================================================
  use {
    'hrsh7th/nvim-cmp',
    config = function()
      local cmp = require('cmp')
      local luasnip = require('luasnip')

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body) -- For `luasnip` users.
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' }, -- LSP source
          { name = 'luasnip' },  -- Snippet source
          { name = 'buffer' },   -- Current buffer
          { name = 'path' },     -- File system paths
        }),
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
      })
    end
  }

  -- ===========================================================================
  -- Keymaps (General, not plugin-specific unless marked)
  -- ===========================================================================

  -- Remap for Nvim-Tree
  vim.keymap.set('n', '<leader>n', ':NvimTreeToggle<CR>', { desc = 'Toggle NvimTree' })

  -- Remap for Telescope
  vim.keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<cr>', { desc = 'Find files' })
  vim.keymap.set('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', { desc = 'Live Grep' })
  vim.keymap.set('n', '<leader>fb', '<cmd>Telescope buffers<cr>', { desc = 'Find buffers' })
  vim.keymap.set('n', '<leader>fh', '<cmd>Telescope help_tags<cr>', { desc = 'Help' })

  -- Other useful keymaps
  vim.keymap.set('n', '<leader>w', '<cmd>w<cr>', { desc = 'Save File' })
  vim.keymap.set('n', '<leader>q', '<cmd>wq<cr>', { desc = 'Save and Quit' })
  vim.keymap.set('n', '<leader>Q', '<cmd>q!<cr>', { desc = 'Force Quit' })


  -- Automatically install plugins on startup if they aren't already
  -- packer.nvim will run `:PackerSync` on first launch after this.
  if packer_plugins then
    require('packer').sync()
  end

end)

-- You can put additional Vimscript commands or global Lua setup here
-- after the packer.startup block if needed.
-- Example:
--vim.cmd [[ filetype plugin indent on ]]
