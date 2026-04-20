# https://github.com/nix-community/srvos/blob/01d98209264c78cb323b636d7ab3fe8e7a8b60c7/nixos/common/sudo.nix
{
  config,
  lib,
  pkgs,
  ...
}:

{

  security.sudo = {
    execWheelOnly = true;
    extraConfig = ''
      Defaults lecture = never
    '';
  };
  assertions =
    let
      validUsers = users: users == [ ] || users == [ "root" ];
      validGroups = groups: groups == [ ] || groups == [ "wheel" ];
      validUserGroups = builtins.all (
        r: validUsers (r.users or [ ]) && validGroups (r.groups or [ ])
      ) config.security.sudo.extraRules;
    in
    [
      {
        assertion = config.security.sudo.execWheelOnly -> validUserGroups;
        message = "Some definitions in `security.sudo.extraRules` refer to users other than 'root' or groups other than 'wheel'. Disable `config.security.sudo.execWheelOnly`, or adjust the rules.";
      }
    ];
}
