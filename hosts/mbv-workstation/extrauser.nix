{
  lib,
  mod,
  ...
}:
let
  user = "gameruser";
in
{
  specialisation.gameruser = {
    inheritParentConfig = true;
    configuration = {
      users.users.${user} = {
        isNormalUser = true;
        extraGroups = [
          "networkmanager"
          "gamemode"
          "adbusers"
        ];
        # You can get the hash of a given password with `mkpasswd -m SHA-512`
        initialHashedPassword = "$6$qLCSEZb7i07pNwf4$QogfJ3DbSqtwrI29Uoe0jlehHKn.A62w2N3E5ZqQIhWPQvdeUBR8DcMgTv9CUpLKSIisjOZChfbDQo9ycJS9f.";
      };

      environment.persistence."/nix/persist" = {
        users.${user}.directories = [ "." ];
      };
      local.restic.exclude = [ "/nix/persist/home/${user}" ];

      home-manager.users.${user} = {
        imports = [ (mod "home-manager/nixos/client") ];
        local = {
          email.enable = false;
        };
        home = {
          homeDirectory = "/home/${user}";
          preferXdgDirectories = true;
        };
      };
      local.emacs.enable = false;

      services = {
        cinnamon.apps.enable = true;
        xserver = {
          desktopManager.cinnamon.enable = true;
          windowManager.awesome.enable = lib.mkForce false;
        };
      };

      programs = {
        i3lock.enable = lib.mkForce false;
        thunar.enable = lib.mkForce false;
      };
    };
  };

}

# libreoffice
# r-studio
# steam
# signal?
# dropbox
