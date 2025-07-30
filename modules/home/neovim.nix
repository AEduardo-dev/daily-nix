# Neovim Configuration with LazyVim setup
{ config, lib, pkgs, inputs, ... }:

{
  programs.nixvim = {
    enable = true;
    
    # Use the latest neovim
    package = pkgs.neovim-unwrapped;
    
    # Enable Lua support
    luaLoader.enable = true;
    
    # Basic Neovim options
    opts = {
      number = true;
      relativenumber = true;
      shiftwidth = 2;
      tabstop = 2;
      expandtab = true;
      smartindent = true;
      wrap = false;
      swapfile = false;
      backup = false;
      undofile = true;
      hlsearch = false;
      incsearch = true;
      termguicolors = true;
      scrolloff = 8;
      signcolumn = "yes";
      updatetime = 50;
      colorcolumn = "80";
      cursorline = true;
      splitbelow = true;
      splitright = true;
      ignorecase = true;
      smartcase = true;
      mouse = "a";
      clipboard = "unnamedplus";
    };

    # Global variables
    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };

    # Color scheme - similar to LazyVim default
    colorschemes.catppuccin = {
      enable = true;
      settings = {
        flavour = "mocha";
        transparent_background = false;
        show_end_of_buffer = false;
        term_colors = true;
        dim_inactive = {
          enabled = false;
          shade = "dark";
          percentage = 0.15;
        };
        integrations = {
          cmp = true;
          gitsigns = true;
          nvimtree = true;
          telescope = true;
          notify = false;
          mini = false;
          treesitter = true;
        };
      };
    };

    # Key mappings
    keymaps = [
      # Better up/down navigation
      {
        mode = [ "n" "x" ];
        key = "j";
        action = "v:count == 0 ? 'gj' : 'j'";
        options = {
          expr = true;
          silent = true;
        };
      }
      {
        mode = [ "n" "x" ];
        key = "k";
        action = "v:count == 0 ? 'gk' : 'k'";
        options = {
          expr = true;
          silent = true;
        };
      }

      # Move to window using the <ctrl> hjkl keys
      {
        mode = "n";
        key = "<C-h>";
        action = "<C-w>h";
        options.desc = "Go to left window";
      }
      {
        mode = "n";
        key = "<C-j>";
        action = "<C-w>j";
        options.desc = "Go to lower window";
      }
      {
        mode = "n";
        key = "<C-k>";
        action = "<C-w>k";
        options.desc = "Go to upper window";
      }
      {
        mode = "n";
        key = "<C-l>";
        action = "<C-w>l";
        options.desc = "Go to right window";
      }

      # Resize window using <ctrl> arrow keys
      {
        mode = "n";
        key = "<C-Up>";
        action = "<cmd>resize +2<cr>";
        options.desc = "Increase window height";
      }
      {
        mode = "n";
        key = "<C-Down>";
        action = "<cmd>resize -2<cr>";
        options.desc = "Decrease window height";
      }
      {
        mode = "n";
        key = "<C-Left>";
        action = "<cmd>vertical resize -2<cr>";
        options.desc = "Decrease window width";
      }
      {
        mode = "n";
        key = "<C-Right>";
        action = "<cmd>vertical resize +2<cr>";
        options.desc = "Increase window width";
      }

      # Buffer management
      {
        mode = "n";
        key = "<S-h>";
        action = "<cmd>bprevious<cr>";
        options.desc = "Prev buffer";
      }
      {
        mode = "n";
        key = "<S-l>";
        action = "<cmd>bnext<cr>";
        options.desc = "Next buffer";
      }
      {
        mode = "n";
        key = "[b";
        action = "<cmd>bprevious<cr>";
        options.desc = "Prev buffer";
      }
      {
        mode = "n";
        key = "]b";
        action = "<cmd>bnext<cr>";
        options.desc = "Next buffer";
      }

      # Clear search with <esc>
      {
        mode = [ "i" "n" ];
        key = "<esc>";
        action = "<cmd>noh<cr><esc>";
        options.desc = "Escape and clear hlsearch";
      }

      # Better indenting
      {
        mode = "v";
        key = "<";
        action = "<gv";
      }
      {
        mode = "v";
        key = ">";
        action = ">gv";
      }

      # Lazy
      {
        mode = "n";
        key = "<leader>l";
        action = "<cmd>Lazy<cr>";
        options.desc = "Lazy";
      }

      # New file
      {
        mode = "n";
        key = "<leader>fn";
        action = "<cmd>enew<cr>";
        options.desc = "New File";
      }

      # Quit
      {
        mode = "n";
        key = "<leader>qq";
        action = "<cmd>qa<cr>";
        options.desc = "Quit all";
      }
    ];

    # Plugins
    plugins = {
      # File explorer
      neo-tree = {
        enable = true;
        closeIfLastWindow = true;
        popupBorderStyle = "rounded";
        enableGitStatus = true;
        enableModifiedMarkers = true;
        enableRefreshOnWrite = true;
        createInDir = "current";
        buffers = {
          bindToCwd = false;
          followCurrentFile = {
            enabled = true;
          };
        };
        window = {
          position = "left";
          width = 30;
          mappings = {
            "<space>" = "none";
          };
        };
      };

      # Fuzzy finder
      telescope = {
        enable = true;
        keymaps = {
          # Find files
          "<leader>ff" = {
            action = "find_files";
            options.desc = "Find Files";
          };
          "<leader>fr" = {
            action = "oldfiles";
            options.desc = "Recent Files";
          };
          "<leader>fb" = {
            action = "buffers";
            options.desc = "Buffers";
          };
          "<leader>fg" = {
            action = "live_grep";
            options.desc = "Live Grep";
          };
          "<leader>fw" = {
            action = "grep_string";
            options.desc = "Grep Word";
          };
        };
      };

      # Syntax highlighting
      treesitter = {
        enable = true;
        settings = {
          highlight.enable = true;
          indent.enable = true;
          folding.enable = true;
          ensure_installed = [
            "bash"
            "c"
            "cpp"
            "css"
            "dockerfile"
            "gitignore"
            "go"
            "html"
            "java"
            "javascript"
            "json"
            "lua"
            "markdown"
            "nix"
            "python"
            "rust"
            "typescript"
            "vim"
            "yaml"
          ];
        };
      };

      # Git integration
      gitsigns = {
        enable = true;
        settings = {
          signs = {
            add.text = "▎";
            change.text = "▎";
            delete.text = "";
            topdelete.text = "";
            changedelete.text = "▎";
            untracked.text = "▎";
          };
          on_attach = ''
            function(buffer)
              local gs = package.loaded.gitsigns

              local function map(mode, l, r, desc)
                vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
              end

              -- stylua: ignore start
              map("n", "]h", gs.next_hunk, "Next Hunk")
              map("n", "[h", gs.prev_hunk, "Prev Hunk")
              map({ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
              map({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
              map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
              map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
              map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
              map("n", "<leader>ghp", gs.preview_hunk, "Preview Hunk")
              map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, "Blame Line")
              map("n", "<leader>gd", gs.diffthis, "Diff This")
              map("n", "<leader>gD", function() gs.diffthis("~") end, "Diff This ~")
              map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
            end
          '';
        };
      };

      # Autocompletion
      cmp = {
        enable = true;
        autoEnableSources = true;
        settings = {
          mapping = {
            "<C-b>" = "cmp.mapping.scroll_docs(-4)";
            "<C-f>" = "cmp.mapping.scroll_docs(4)";
            "<C-Space>" = "cmp.mapping.complete()";
            "<C-e>" = "cmp.mapping.abort()";
            "<CR>" = "cmp.mapping.confirm({ select = true })";
            "<S-CR>" = "cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true })";
            "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
            "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
          };
          sources = [
            { name = "nvim_lsp"; }
            { name = "buffer"; }
            { name = "path"; }
            { name = "luasnip"; }
          ];
          snippet = {
            expand = "function(args) require('luasnip').lsp_expand(args.body) end";
          };
        };
      };

      # Snippets
      luasnip.enable = true;

      # LSP
      lsp = {
        enable = true;
        servers = {
          # Nix
          nil_ls.enable = true;
          
          # Lua
          lua-ls.enable = true;
          
          # Python
          pyright.enable = true;
          
          # Rust
          rust-analyzer = {
            enable = true;
            installCargo = true;
            installRustc = true;
          };
          
          # Go
          gopls.enable = true;
          
          # TypeScript/JavaScript
          tsserver.enable = true;
          
          # HTML/CSS
          html.enable = true;
          cssls.enable = true;
          
          # JSON
          jsonls.enable = true;
          
          # YAML
          yamlls.enable = true;
          
          # Dockerfile
          dockerls.enable = true;
          
          # Bash
          bashls.enable = true;
        };
        
        keymaps = {
          lspBuf = {
            "gd" = "definition";
            "gD" = "declaration";
            "gI" = "implementation";
            "gr" = "references";
            "gt" = "type_definition";
            "K" = "hover";
            "<leader>ca" = "code_action";
            "<leader>cr" = "rename";
            "<leader>cf" = "format";
          };
          diagnostic = {
            "<leader>cd" = "open_float";
            "[d" = "goto_prev";
            "]d" = "goto_next";
          };
        };
      };

      # Formatting
      conform-nvim = {
        enable = true;
        formattersByFt = {
          lua = [ "stylua" ];
          python = [ "black" ];
          rust = [ "rustfmt" ];
          nix = [ "alejandra" ];
          javascript = [ "prettier" ];
          typescript = [ "prettier" ];
          html = [ "prettier" ];
          css = [ "prettier" ];
          json = [ "prettier" ];
          yaml = [ "prettier" ];
          markdown = [ "prettier" ];
        };
      };

      # Status line
      lualine = {
        enable = true;
        iconsEnabled = true;
        theme = "catppuccin";
        componentSeparators = {
          left = "";
          right = "";
        };
        sectionSeparators = {
          left = "";
          right = "";
        };
        sections = {
          lualine_a = [ "mode" ];
          lualine_b = [ "branch" "diff" "diagnostics" ];
          lualine_c = [ "filename" ];
          lualine_x = [ "encoding" "fileformat" "filetype" ];
          lualine_y = [ "progress" ];
          lualine_z = [ "location" ];
        };
      };

      # Indentation guides
      indent-blankline = {
        enable = true;
        settings = {
          indent = {
            char = "│";
            tab_char = "│";
          };
          scope = {
            enabled = false;
          };
          exclude = {
            filetypes = [
              "help"
              "alpha"
              "dashboard"
              "neo-tree"
              "Trouble"
              "lazy"
              "mason"
              "notify"
              "toggleterm"
              "lazyterm"
            ];
          };
        };
      };

      # Auto pairs
      nvim-autopairs.enable = true;

      # Comments
      comment.enable = true;

      # Surround
      nvim-surround.enable = true;

      # Which key
      which-key = {
        enable = true;
        registrations = {
          "<leader>b" = { name = "+buffer"; };
          "<leader>c" = { name = "+code"; };
          "<leader>f" = { name = "+file/find"; };
          "<leader>g" = { name = "+git"; };
          "<leader>gh" = { name = "+hunks"; };
          "<leader>q" = { name = "+quit/session"; };
          "<leader>s" = { name = "+search"; };
          "<leader>u" = { name = "+ui"; };
          "<leader>w" = { name = "+windows"; };
          "<leader>x" = { name = "+diagnostics/quickfix"; };
        };
      };

      # Notifications
      notify = {
        enable = true;
        backgroundColour = "#000000";
      };

      # Dashboard
      alpha = {
        enable = true;
        theme = "dashboard";
      };

      # Toggle terminal
      toggleterm = {
        enable = true;
        settings = {
          direction = "float";
          float_opts = {
            border = "curved";
          };
        };
      };
    };

    # Additional key mappings for neo-tree
    keymaps = [
      {
        mode = "n";
        key = "<leader>e";
        action = "<cmd>Neotree toggle<cr>";
        options.desc = "Explorer NeoTree (root dir)";
      }
      {
        mode = "n";
        key = "<leader>E";
        action = "<cmd>Neotree toggle float<cr>";
        options.desc = "Explorer NeoTree (float)";
      }
    ];

    # Extra Lua configuration
    extraConfigLua = ''
      -- Additional LazyVim-style configurations
      
      -- Better diagnostics
      vim.diagnostic.config({
        virtual_text = {
          spacing = 4,
          source = "if_many",
          prefix = "●",
        },
        severity_sort = true,
        float = {
          source = "always",
          border = "rounded",
        },
      })
      
      -- Auto create dir when saving a file, in case some intermediate directory does not exist
      vim.api.nvim_create_autocmd({ "BufWritePre" }, {
        group = vim.api.nvim_create_augroup("auto_create_dir", { clear = true }),
        callback = function(event)
          if event.match:match("^%w%w+://") then
            return
          end
          local file = vim.loop.fs_realpath(event.match) or event.match
          vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
        end,
      })
    '';
  };

  # Additional packages for development
  home.packages = with pkgs; [
    # Language servers and tools that nixvim might need
    stylua
    black
    prettier
    alejandra
    rustfmt
    
    # Additional development tools
    ripgrep
    fd
    
    # Terminal multiplexer
    tmux
  ];
}