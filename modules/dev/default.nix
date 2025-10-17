{
  pkgs,
  lib,
  config,
  ...
}:

{
  # Import all directories in this folder
  imports =
    with builtins;
    filter (p: readFileType p == "directory") (map (p: ./. + "/${p}") (attrNames (readDir ./.)));

  home-manager.sharedModules = lib.mkIf config.local.hm.enable [
    (_: {
      programs.awscli = {
        # Test failures prevent build on 251013: https://github.com/NixOS/nixpkgs/issues/450617
        enable = false;
        settings = {
          "default" = {
            region = "us-east-2";
          };
        };
        # TODO: Figure out how to add credentials
      };
    })
  ];
  environment.systemPackages =
    with pkgs;
    [
      tree-sitter
      # Good to just have generally available
      gcc
      clang
      llvm
    ]
    ++ (with tree-sitter-grammars; [
      # Unclear that this works...
      # See: https://github.com/nix-community/emacs-overlay/issues/341#issuecomment-1605290875
      tree-sitter-bash
      tree-sitter-bibtex
      tree-sitter-c
      tree-sitter-cmake
      tree-sitter-comment
      tree-sitter-commonlisp
      tree-sitter-css
      tree-sitter-embedded-template
      tree-sitter-go
      tree-sitter-gomod
      tree-sitter-gowork
      tree-sitter-haskell
      tree-sitter-hjson
      tree-sitter-html
      tree-sitter-http
      tree-sitter-java
      tree-sitter-javascript
      tree-sitter-jsdoc
      tree-sitter-json
      tree-sitter-json5
      tree-sitter-latex
      tree-sitter-ledger
      tree-sitter-lua
      tree-sitter-make
      tree-sitter-markdown
      tree-sitter-nix
      tree-sitter-perl
      tree-sitter-proto
      tree-sitter-python
      tree-sitter-query
      tree-sitter-regex
      tree-sitter-rust
      tree-sitter-sql
      tree-sitter-toml
      tree-sitter-typescript
      tree-sitter-vim
      tree-sitter-yaml
      tree-sitter-zig
    ]);
}
