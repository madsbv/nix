{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    nodejs
    typescript-language-server
    js-beautify
    # For yaml formatting, among other things
    prettier
    eslint
  ];
}
