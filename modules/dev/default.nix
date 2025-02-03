{ pkgs, ... }:

{
  # Import all directories in this folder
  imports =
    with builtins;
    filter (p: readFileType p == "directory") (map (p: ./. + "/${p}") (attrNames (readDir ./.)));

  environment.systemPackages = with pkgs; [
    tree-sitter
    # Good to just have generally available
    gcc
    clang
    llvm
  ];
}
