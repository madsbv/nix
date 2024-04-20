{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    nodePackages.nodejs
    nodePackages.typescript-language-server
    nodePackages.js-beautify
    # For yaml formatting, among other things
    nodePackages.prettier
    nodePackages.eslint
  ];
}
