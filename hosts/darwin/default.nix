{ user, agenix, config, pkgs, lib, ... }:

{
  imports = [
    ../../modules/darwin
    ../../modules/shared
    ../../modules/shared/cachix
    agenix.darwinModules.default
  ];

  services.nix-daemon.enable = true;

  nix = {
    package = pkgs.nixUnstable;
    settings = {
      trusted-users = [ "@admin" "${user}" ];
      auto-optimise-store = true;
      # sandbox = true has problems on Darwin (see https://github.com/NixOS/nix/issues/4119)
      # If you get trapped by this, manually edit /etc/nix/nix.conf to set sandbox = false, kill nix-daemon, then try again (optionally with `--option sandbox false' added as well).
      # sandbox = "relaxed" eventually also caused problems.
      sandbox = false;
    };

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

  networking = {
    computerName = "mbv-mba";
    hostName = "mbv-mba";
    localHostName = "mbv-mba";
    # dns = [ "1.1.1.1" "1.0.0.1" ];
  };

  # Load packages that are shared across systems
  environment = {
    systemPackages = [ agenix.packages."${pkgs.system}".default ]
      ++ (import ../../modules/shared/packages.nix { inherit pkgs; });
  };

  security = {
    # Enable sudo authentication with Touch ID
    pam.enableSudoTouchIdAuth = true;
  };

  # Enable fonts dir
  fonts.fontDir.enable = true;

  system = {
    stateVersion = 4;
    defaults = {
      NSGlobalDomain = {
        ApplePressAndHoldEnabled = false;
        AppleShowAllExtensions = true;
        AppleEnableMouseSwipeNavigateWithScrolls = true;
        AppleEnableSwipeNavigateWithScrolls = true;
        AppleICUForce24HourTime = true;
        AppleMeasurementUnits = "Centimeters";
        AppleTemperatureUnit = "Celsius";
        AppleMetricUnits = 1;
        AppleInterfaceStyleSwitchesAutomatically = true;

        # 120, 90, 60, 30, 12, 6, 2
        KeyRepeat = 2;

        # 120, 94, 68, 35, 25, 15
        InitialKeyRepeat = 15;

        # Trackpad speed, 0 to 3
        "com.apple.trackpad.scaling" = 1.0;

        "com.apple.mouse.tapBehavior" = 1;
        "com.apple.sound.beep.volume" = 0.0;
        "com.apple.sound.beep.feedback" = 0;

        NSAutomaticSpellingCorrectionEnabled = false;
        NSAutomaticWindowAnimationsEnabled = false;

        # Smooth scrolling
        NSScrollAnimationEnabled = true;

        # Autohide menu bar to make space for sketchybar
        _HIHideMenuBar = true;
      };

      dock = {
        autohide = true;
        autohide-delay = 0.0;
        autohide-time-modifier = 0.0;
        show-recents = true;

        # If true, show only open applications in the dock
        # static-only = true;

        launchanim = false;
        orientation = "bottom";
        tilesize = 48;
        # Whether to arrange spaces based on most recent use
        mru-spaces = false;
      };

      finder = {
        _FXShowPosixPathInTitle = true;
        CreateDesktop = false;
        ShowPathbar = true;
      };

      trackpad = {
        Clicking = true;
        TrackpadThreeFingerDrag = true;
      };
      # Sounds like something I want, but it actually reduces motions related to trackpad movements which I want to keep.
      universalaccess = { reduceMotion = false; };
    };

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
  };

  # TODO: Where to put config files? I'd like to keep them with other configs in home-manager modules, especially since these land in user config
  # NOTE: The config and extraConfig options put the config files in the nix store via [[https://nixos.org/manual/nixpkgs/stable/#trivial-builder-writeText][nixpkgs.writeScript]], and pass that path to the service via command line argument. Hence this differs from putting the file in xdg.configHome/
  services = {
    yabai = {
      enable = true;
      enableScriptingAddition = true;
      # TODO: yabairc (and maybe skhdrc?) refer to sketchybarrc and related files. How should this be organized?
      extraConfig = (builtins.readFile ./config/yabai/yabairc);
    };
    skhd = {
      # When home-manager creates launchd services on Darwin, it tries to use things like $HOME in the PATH set in EnvironmentVariables in the launchd service. However, according to LaunchControl, that field does not support variable expansion. Hence $HOME/.nix-profile/bin does not end up in the PATH for skhd.
      # See https://github.com/LnL7/nix-darwin/issues/406
      # Also, nix-based string replacement does not work when reading from separate file, so we have to do that here.
      enable = true;
      skhdConfig = (builtins.readFile ./config/skhd/skhdrc) + ''

        lctrl + lcmd - return : ${pkgs.kitty}/bin/kitty --single-instance ~'';
    };
    # NOTE: The config files for these services are in the users home directory. They are set in modules/darwin/home-manager as xdg.configFile's.
    # It would be better to be able to set the configs as part of the service definitions, but that is not supported.
    karabiner-elements.enable = true;
    # The sketchybar service module has a config option, but it takes the contents of sketchybarrc as argument. My config is split across multiple arguments.
    sketchybar = {
      enable = true;
      # Empty config string means nix won't manage the config.
      config = "";
      # Dependencies of config
      extraPackages = [ pkgs.jq ];
    };
  };
  # TODO: Set up restic/autorestic backups on the system level. See e.g. https://www.arthurkoziel.com/restic-backups-b2-nixos/
  # See also https://nixos.wiki/wiki/Restic for a way to run restic as a separate user.
}
