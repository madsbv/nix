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
          nvimConfigDir = "${config.xdg.configHome}/nvim-base";
          userConfigDir = "${config.xdg.configHome}/nvim";
        in
        {

          home.activation.cloneNvimConfig = lib.mkIf cfg.enable (
            lib.hm.dag.entryAfter [ "writeBoundary" ] ''
              if [ ! -d "${nvimConfigDir}" ]; then
                  ${pkgs.git}/bin/git clone ${cfg.nvimConfigRepo} "${nvimConfigDir}"
              fi
              # Create symlink to user config location
              if [ ! -d "${userConfigDir}" ]; then
                  ln -sf "${nvimConfigDir}" "${userConfigDir}"
              fi
            ''
          );
          programs.neovim = {
            enable = true;
            vimAlias = true;
            viAlias = true;
            vimdiffAlias = true;
            defaultEditor = true;
            extraPackages = with pkgs; [
              # nvim occasionally compiles stuff for its plugins, e.g. treesitter modules
              gcc
            ];
            plugins = with pkgs.vimPlugins; [ supermaven-nvim ];
            extraLuaConfig = ''
              -- Load user config from nvimConfigRepo
              local user_config_path = "${nvimConfigDir}"
              if vim.fn.isdirectory(user_config_path) == 1 then
                local user_init = user_config_path .. "/init.lua"
                if vim.fn.filereadable(user_init) == 1 then
                  dofile(user_init)
                end
              end

              -- Supermaven setup
              require('supermaven-nvim').setup({
                keymaps = {
                  accept_suggestion = '<Tab>',
                  clear_suggestion = '<C-]>',
                  accept_suggestion_word = '<C-w>',
                },
                ignore_filetypes = { ' TelescopePrompt', 'NvimTree' },
                color = {
                  suggestion_color = '#ffffff',
                  cterm_color = 255,
                },
              })
            '';
          };
        }
      )
    ];
  };
}
