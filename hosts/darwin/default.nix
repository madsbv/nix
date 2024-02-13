{ agenix, config, pkgs, ... }:

let user = "mvilladsen";

in {
  # TODO: Consider which parts of this to move to modules/darwin/default.nix
  imports = [
    ../../modules/darwin
    ../../modules/shared
    ../../modules/shared/cachix
    agenix.darwinModules.default
  ];

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  # Setup user, packages, programs
  nix = {
    package = pkgs.nixUnstable;
    settings.trusted-users = [ "@admin" "${user}" ];

    gc = {
      user = "root";
      automatic = true;
      interval = {
        Weekday = 0;
        Hour = 2;
        Minute = 0;
      };
      options = "--delete-older-than 30d";
    };

    # Turn this on to make command line easier
    extraOptions = ''
      experimental-features = nix-command flakes repl-flake
    '';
  };

  # Turn off NIX_PATH warnings now that we're using flakes
  system.checks.verifyNixPath = false;

  # Load packages that are shared across systems
  environment.systemPackages = with pkgs;
    [ agenix.packages."${pkgs.system}".default ]
    ++ (import ../../modules/shared/packages.nix { inherit pkgs; });

  # Enable fonts dir
  fonts.fontDir.enable = true;

  system = {
    stateVersion = 4;
    # TODO: Go through all of these settings and set as desired.
    # defaults = {
    #   NSGlobalDomain = {
    #     AppleShowAllExtensions = true;
    #     ApplePressAndHoldEnabled = false;

    #     # 120, 90, 60, 30, 12, 6, 2
    #     KeyRepeat = 2;

    #     # 120, 94, 68, 35, 25, 15
    #     InitialKeyRepeat = 15;

    #     "com.apple.mouse.tapBehavior" = 1;
    #     "com.apple.sound.beep.volume" = 0.0;
    #     "com.apple.sound.beep.feedback" = 0;
    #   };

    #   dock = {
    #     autohide = false;
    #     show-recents = false;
    #     launchanim = true;
    #     orientation = "bottom";
    #     tilesize = 48;
    #   };

    #   finder = { _FXShowPosixPathInTitle = false; };

    #   trackpad = {
    #     Clicking = true;
    #     TrackpadThreeFingerDrag = true;
    #   };
    # };

    # keyboard = {
    #   enableKeyMapping = true;
    #   remapCapsLockToControl = true;
    # };
  };
  services.yabai = {
    enable = true;
    enableScriptingAddition = true;
    extraConfig = (builtins.readFile ./config/yabai/yabairc);
  };
  services.skhd = {
    enable = true;
    skhdConfig = (builtins.readFile ./config/skhd/skhdrc);
  };
  # Note: The config files for these services are in the users home directory. They are set in modules/darwin/home-manager as xdg.configFile's.
  # It would be better to be able to set the configs as part of the service definitions, but that is not supported.
  services.karabiner-elements.enable = true;
  services.sketchybar = {
    enable = true;
    # Empty config string means nix won't manage the config.
    config = "";
    # Dependencies of config
    extraPackages = [ pkgs.jq ];
  };
  # TODO: Set up restic/autorestic backups on the system level. See e.g. https://www.arthurkoziel.com/restic-backups-b2-nixos/
  # See also https://nixos.wiki/wiki/Restic for a way to run restic as a separate user.
}
