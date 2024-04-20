{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    hyperfine
    # Misc language servers
    yaml-language-server
    sqls
    lua-language-server
    vscode-langservers-extracted
  ];
}
