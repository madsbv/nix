{
  config,
  lib,
  ...
}:

{
  nix = {
    daemonIOLowPriority = lib.mkDefault true;
    settings.trusted-users = [ "@admin" ];
  };

  homebrew = {
    caskArgs.no_quarantine = lib.mkDefault true;
    onActivation = {
      cleanup = "uninstall";
      upgrade = true;
    };
    enableZshIntegration = lib.mkDefault config.homebrew.enable;
  };

  system.activationScripts = lib.mkIf config.srvos.update-diff.enable {
    preActivation.text = ''
      incoming="''${systemConfig-}"
      ${config.srvos.update-diff.text}
    '';
  };
}
