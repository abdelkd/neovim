# This overlay, when applied to nixpkgs, adds the final neovim derivation to nixpkgs.
{ inputs }:
final: prev:
with final.pkgs.lib;
let
  pkgs = final;

  # Use this to create a plugin from a flake input
  mkNvimPlugin = src: pname:
    pkgs.vimUtils.buildVimPlugin {
      inherit pname src;
      version = src.lastModifiedDate;
    };

  # Make sure we use the pinned nixpkgs instance for wrapNeovimUnstable,
  # otherwise it could have an incompatible signature when applying this overlay.
  pkgs-wrapNeovim = inputs.nixpkgs.legacyPackages.${pkgs.system};

  # This is the helper function that builds the Neovim derivation.
  mkNeovim = pkgs.callPackage ./mkNeovim.nix { inherit pkgs-wrapNeovim; };

  # A plugin can either be a package or an attrset, such as
  # { plugin = <plugin>; # the package, e.g. pkgs.vimPlugins.nvim-cmp
  #   config = <config>; # String; a config that will be loaded with the plugin
  #   # Boolean; Whether to automatically load the plugin as a 'start' plugin,
  #   # or as an 'opt' plugin, that can be loaded with `:packadd!`
  #   optional = <true|false>; # Default: false
  #   ...
  # }
  all-plugins = with pkgs.vimPlugins; [
    nvim-treesitter.withAllGrammars
    plenary-nvim # lua functions that many plugins use
    vim-tmux-navigator # tmux & split window navigation
    (mkNvimPlugin inputs.tokyo-night "tokyonight") # Colorscheme
    (mkNvimPlugin inputs.nvim-tree "nvim-tree") # Nvim Tree
    (mkNvimPlugin inputs.nvim-web-devicons
      "nvim-web-devicons") # Nvim Web Devicons
    (mkNvimPlugin inputs.which-key "which-key") # Which key
    (mkNvimPlugin inputs.alpha-nvim "alpha.nvim") # Greeter
    (mkNvimPlugin inputs.auto-session-nvim
      "auto-session.nvim") # Automatic session management
    (mkNvimPlugin inputs.bufferline-nvim "bufferline.nvim") # Bufferline
    (mkNvimPlugin inputs.lualine-nvim "lualine.nvim") # Status Line
    (mkNvimPlugin inputs.lsp-status-nvim "lsp-status.nvim") # Diagnostic status and messages from LSP servers in lualine
    (mkNvimPlugin inputs.dressing-nvim
      "dressing.nvim") # Improve vim.ui.select vim.ui.input
    (mkNvimPlugin inputs.vim-maximizer "vim-maximizer")
    (mkNvimPlugin inputs.nvim-treesitter "nvim-tresitter")
    (mkNvimPlugin inputs.nvim-ts-autotag "nvim-ts-autotag")
    (mkNvimPlugin inputs.indent-blankline-nvim "indent")
    (mkNvimPlugin inputs.autopairs-nvim "nvim-autopairs")
    (mkNvimPlugin inputs.comment-nvim "comment.nvim")
    (mkNvimPlugin inputs.nvim-ts-context-commentstring
      "nvim-ts-context-commentstring")
    (mkNvimPlugin inputs.todo-comments-nvim "todo-comments-nvim")
    (mkNvimPlugin inputs.substitute-nvim "substitute.nvim")
    (mkNvimPlugin inputs.surround-nvim "surround.nvim")
    (mkNvimPlugin inputs.nvim-lspconfig "lspconfig") # For configuring LSP
    (mkNvimPlugin inputs.go-nvim "go.nvim") # Golang LSP, ...etc
    (mkNvimPlugin inputs.trouble-nvim "trouble.nvim") # interacting with the lsp and some other things like todo comments.
    (mkNvimPlugin inputs.conform-nvim "conform.nvim") # Formatter
    (mkNvimPlugin inputs.nvim-lint "nvim-lint") # Linting
    (mkNvimPlugin inputs.gitsigns-nvim "gitsigns.nvim") # Gitsigns

    # Completion
    (mkNvimPlugin inputs.nvim-cmp "nvim-cmp")
    (mkNvimPlugin inputs.cmp-buffer "cmp-buffer")
    (mkNvimPlugin inputs.cmp-path "cmp-path")
    (mkNvimPlugin inputs.cmp-luasnip "cmp_luasnip")
    (mkNvimPlugin inputs.friendly-snippets "friendly-snippets")
    (mkNvimPlugin inputs.lspkind-nvim "lspkind.nvim")
    (mkNvimPlugin inputs.cmp-nvim-lsp "cmp-nvim-lsp")
    (mkNvimPlugin inputs.nvim-lsp-file-operations "nvim-lsp-file-operations")
    (mkNvimPlugin inputs.neodev "neodev")
    luasnip

    # Telescope
    (mkNvimPlugin inputs.telescope-nvim "telescope.nvim")
    telescope-fzf-native-nvim
  ];

  extraPackages = with pkgs; [
    # language servers, etc.
    lua-language-server # lua lsp
    nil # nix LSP
    emmet-ls # Emmet language server
    svelte-language-server # Svelte
    tailwindcss-language-server # Tailwindcss
    htmx-lsp # HTMX
    nodePackages."@astrojs/language-server" # Astro
    nodePackages.bash-language-server # Bash
    nodePackages.typescript-language-server # Typescript
    clang-tools# Clang
    jdt-language-server # jdtls
    templ # Templ
    rust-analyzer # Rust LSP

    # Extra packages
    ripgrep
    lazygit

    # Formatters
    prettierd # js/ts ...etc
    stylua # lua
    isort black # python

    # Linters
    eslint_d # js/ts ...etc
    pylint # python
  ];
in {
  # This is the neovim derivation
  # returned by the overlay
  nvim-pkg = mkNeovim {
    plugins = all-plugins;
    inherit extraPackages;
  };

  # This can be symlinked in the devShell's shellHook
  nvim-luarc-json = final.mk-luarc-json { plugins = all-plugins; };

  # You can add as many derivations as you like.
  # Use `ignoreConfigRegexes` to filter out config
  # files you would not like to include.
  #
  # For example:
  #
  # nvim-pkg-no-telescope = mkNeovim {
  #   plugins = [];
  #   ignoreConfigRegexes = [
  #     "^plugin/telescope.lua"
  #     "^ftplugin/.*.lua"
  #   ];
  #   inherit extraPackages;
  # };
}
