{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # TODO: Readd once fix is merged: https://nixpk.gs/pr-tracker.html?pr=319882
    # nodePackages.bash-language-server
    shellcheck
    shfmt
  ];
}
