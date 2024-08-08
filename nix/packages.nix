{ inputs, pkgs }:
 with pkgs; [
    ripgrep
    # language servers, etc.
    lua-language-server
    nil # nix LSP
 ]
