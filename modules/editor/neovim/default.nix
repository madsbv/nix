{
  config,
  lib,
  ...
}:

let
  cfg = config.local.neovim;
in
{
  options.local.neovim = {
    enable = lib.mkEnableOption "Neovim";
    nvimConfigRepo = lib.mkOption {
      default = "https://github.com/madsbv/nvim-config";
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = lib.mkIf config.local.hm.enable [
      (
        {
          pkgs,
          lib,
          config,
          ...
        }:
        let
          nvimConfigDir = "${config.xdg.configHome}/nvim";
        in
        {
          home.activation.cloneNvimConfig = lib.mkIf cfg.enable (
            lib.hm.dag.entryAfter [ "writeBoundary" ] ''
              if [ ! -d "${nvimConfigDir}" ]; then
                  ${pkgs.git}/bin/git clone ${cfg.nvimConfigRepo} "${nvimConfigDir}"
              fi
            ''
          );
          programs.neovim = {
            enable = true;
            vimAlias = true;
            viAlias = true;
            vimdiffAlias = true;
            defaultEditor = true;
            plugins = with pkgs.vimPlugins; [
              molokai
              # NOTE: Molokai was originally a vim theme modified from Monokai, so just use the native one here.
              # Can we do this programmatically depending on color-scheme? Would be pretty convoluted
              (pkgs.vimPlugins.base16-vim.overrideAttrs (
                _old:
                let
                  schemeFile = config.scheme base16-vim;
                in
                {
                  patchPhase = "cp ${schemeFile} colors/base16-scheme.vim";
                }
              ))
            ];
          };
        }
      )
    ];
  };
}
