{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    python3
    isort
    black
    python311Packages.pyflakes
    python311Packages.pytest
    basedpyright
    uv
    ruff
  ];
}
