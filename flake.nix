{
  description = "Neovim derivation";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    gen-luarc.url = "github:mrcjkb/nix-gen-luarc-json";

    # Neovim plugins
    # tokyo night colorscheme
    tokyo-night.url = "github:folke/tokyonight.nvim";
    tokyo-night.flake = false;

    nvim-tree.url = "github:nvim-tree/nvim-tree.lua";
    nvim-tree.flake = false;

    nvim-web-devicons.url = "github:nvim-tree/nvim-web-devicons";
    nvim-web-devicons.flake = false;

    which-key.url = "github:folke/which-key.nvim";
    which-key.flake = false;

    telescope-nvim.url = "github:nvim-telescope/telescope.nvim";
    telescope-nvim.flake = false;

    alpha-nvim.url = "github:goolord/alpha-nvim";
    alpha-nvim.flake = false;

    auto-session-nvim.url = "github:rmagatti/auto-session";
    auto-session-nvim.flake = false;

    bufferline-nvim.url = "github:akinsho/bufferline.nvim";
    bufferline-nvim.flake = false;

    lualine-nvim.url = "github:nvim-lualine/lualine.nvim";
    lualine-nvim.flake = false;

    lsp-status-nvim.url = "github:nvim-lua/lsp-status.nvim";
    lsp-status-nvim.flake = false;

    dressing-nvim.url = "github:stevearc/dressing.nvim";
    dressing-nvim.flake = false;

    vim-maximizer.url = "github:szw/vim-maximizer";
    vim-maximizer.flake = false;

    nvim-treesitter.url = "github:nvim-treesitter/nvim-treesitter";
    nvim-treesitter.flake = false;

    nvim-ts-autotag.url = "github:windwp/nvim-ts-autotag";
    nvim-ts-autotag.flake = false;

    indent-blankline-nvim.url = "github:lukas-reineke/indent-blankline.nvim";
    indent-blankline-nvim.flake = false;

    autopairs-nvim.url = "github:windwp/nvim-autopairs";
    autopairs-nvim.flake = false;

    comment-nvim.url = "github:numToStr/Comment.nvim";
    comment-nvim.flake = false;

    nvim-ts-context-commentstring.url = "github:JoosepAlviste/nvim-ts-context-commentstring";
    nvim-ts-context-commentstring.flake = false;

    todo-comments-nvim.url = "github:folke/todo-comments.nvim";
    todo-comments-nvim.flake = false;

    substitute-nvim.url = "github:gbprod/substitute.nvim";
    substitute-nvim.flake = false;

    surround-nvim.url = "github:kylechui/nvim-surround";
    surround-nvim.flake = false;

    nvim-lspconfig.url = "github:neovim/nvim-lspconfig";
    nvim-lspconfig.flake = false;

    go-nvim.url = "github:ray-x/go.nvim";
    go-nvim.flake = false;

    trouble-nvim.url = "github:folke/trouble.nvim";
    trouble-nvim.flake = false;

    conform-nvim.url = "github:stevearc/conform.nvim";
    conform-nvim.flake = false;

    nvim-lint.url = "github:mfussenegger/nvim-lint";
    nvim-lint.flake = false;

    gitsigns-nvim.url = "github:lewis6991/gitsigns.nvim";
    gitsigns-nvim.flake = false;


    # Nvim Completion
    nvim-cmp.url = "github:hrsh7th/nvim-cmp";
    nvim-cmp.flake = false;

    cmp-buffer.url = "github:hrsh7th/cmp-buffer";
    cmp-buffer.flake = false;

    cmp-path.url = "github:hrsh7th/cmp-path";
    cmp-path.flake = false;

    cmp-luasnip.url = "github:saadparwaiz1/cmp_luasnip";
    cmp-luasnip.flake = false;

    friendly-snippets.url = "github:rafamadriz/friendly-snippets";
    friendly-snippets.flake = false;

    lspkind-nvim.url = "github:onsails/lspkind.nvim";
    lspkind-nvim.flake = false;

    cmp-nvim-lsp.url = "github:hrsh7th/cmp-nvim-lsp";
    cmp-nvim-lsp.flake = false;

    nvim-lsp-file-operations.url = "github:antosha417/nvim-lsp-file-operations";
    nvim-lsp-file-operations.flake = false;

    neodev.url = "github:folke/neodev.nvim";
    neodev.flake = false;

    # {
    #   "L3MON4D3/LuaSnip",
    #   -- follow latest release.
    #   version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
    #   -- install jsregexp (optional!).
    #   build = "make install_jsregexp",
    # },

    # Add bleeding-edge plugins here.
    # They can be updated with `nix flake update` (make sure to commit the generated flake.lock)
    # wf-nvim = {
    #   url = "github:Cassin01/wf.nvim";
    #   flake = false;
    # };
  };

  outputs = inputs@{ self, nixpkgs, flake-utils, gen-luarc, ... }:
    let
      supportedSystems =
        [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

      # This is where the Neovim derivation is built.
      neovim-overlay = import ./nix/neovim-overlay.nix { inherit inputs; };
    in flake-utils.lib.eachSystem supportedSystems (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            # Import the overlay, so that the final Neovim derivation(s) can be accessed via pkgs.<nvim-pkg>
            neovim-overlay
            # This adds a function can be used to generate a .luarc.json
            # containing the Neovim API all plugins in the workspace directory.
            # The generated file can be symlinked in the devShell's shellHook.
            gen-luarc.overlays.default
          ];
        };
        shell = pkgs.mkShell {
          name = "nvim-devShell";
          buildInputs = with pkgs; [
            # Tools for Lua and Nix development, useful for editing files in this repo
            lua-language-server
            nil
            stylua
            luajitPackages.luacheck
          ];
          shellHook = ''
            # symlink the .luarc.json generated in the overlay
            ln -fs ${pkgs.nvim-luarc-json} .luarc.json
          '';
        };
      in {
        packages = rec {
          default = nvim;
          nvim = pkgs.nvim-pkg;
        };
        devShells = { default = shell; };
      }) // {
        # You can add this overlay to your NixOS configuration
        overlays.default = neovim-overlay;
      };
}
