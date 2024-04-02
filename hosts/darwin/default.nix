{ flake-root, user, config, pkgs, homebrew-bundle, homebrew-core, homebrew-cask
, homebrew-services, homebrew-cask-fonts, felixkratz-formulae, pirj-noclamshell
, ... }:

{
  imports = [ "${flake-root}/modules/darwin" "${flake-root}/modules/shared" ];

  # TODO: Set up restic/autorestic backups on the system level. See e.g. https://www.arthurkoziel.com/restic-backups-b2-nixos/
  # See also https://nixos.wiki/wiki/Restic for a way to run restic as a separate user.

  services.nix-daemon.enable = true;

  nix = {
    # Enable linux builder VM.
    linux-builder = {
      enable = true;
      systems = [ "aarch64-linux" ];
      config = { boot.binfmt.emulatedSystems = [ "x86_64-linux" ]; };
    };
    buildMachines = [{
      sshKey = config.age.secrets.ssh-user-mbv-mba.path;
      systems = [ "x86_64-linux" ];
      sshUser = "root";
      hostName = "192.168.0.27";
      protocol = "ssh-ng";
      supportedFeatures = [ "kvm" "big-parallel" "benchmark" ];
      maxJobs = 8;
    }];
    settings.trusted-users = [ "@admin" "${user}" ];
  };

  nix-homebrew = {
    enable = true;
    user = "${user}";
    taps = {
      "homebrew/homebrew-core" = homebrew-core;
      "homebrew/homebrew-cask" = homebrew-cask;
      "homebrew/homebrew-bundle" = homebrew-bundle;
      "homebrew/homebrew-cask-fonts" = homebrew-cask-fonts;
      "homebrew/homebrew-services" = homebrew-services;
      # "koekeishiya/homebrew-formulae" = koekeishiya-formulae;
      "felixkratz/homebrew-formulae" = felixkratz-formulae;
      "pirj/homebrew-noclamshell" = pirj-noclamshell;
    };
    mutableTaps = false;
    autoMigrate = true;
  };

  networking = {
    computerName = "mbv-mba";
    hostName = "mbv-mba";
    localHostName = "mbv-mba";
    knownNetworkServices =
      [ "AX88179A" "Thunderbolt Bridge" "Wi-Fi" "iPhone USB" ];
    dns = [
      # Quad9 primary and secondary, including ipv6
      "9.9.9.9"
      "149.112.112.112"
      "2620:fe::fe"
      "2620:fe::9"
      # Cloudflare 1.1.1.1 malware blocking, primary and secondary, including ipv6
      "1.1.1.2"
      "1.0.0.2"
      "2606:4700:4700::1112"
      "2606:4700:4700::1002"
    ];
  };

  # Reimplementation of the launchd plist installed by tailscaled itself when invoked as `tailscaled install-system-daemonf (see https://github.com/tailscale/tailscale/wiki/Tailscaled-on-macOS)`
  launchd.daemons = {
    tailscaled = {
      command = "${pkgs.tailscale}/bin/tailscaled";
      serviceConfig = {
        RunAtLoad = true;
        Label = "com.tailscale.tailscaled";
      };
    };
  };

  # IMPORTANT: Necessary for nix-darwin to set PATH correctly
  # NOTE: Can use programs.zsh.variables to set environment variables in the global environment.
  programs.zsh.enable = true;

  security = {
    # Enable sudo authentication with Touch ID
    pam.enableSudoTouchIdAuth = true;
  };

  # TODO: Where to put config files? I'd like to keep them with other configs in home-manager modules, especially since these land in user config
  # NOTE: The config and extraConfig options put the config files in the nix store via [[https://nixos.org/manual/nixpkgs/stable/#trivial-builder-writeText][nixpkgs.writeScript]], and pass that path to the service via command line argument. Hence this differs from putting the file in xdg.configHome/
  services = {
    yabai = {
      enable = true;
      enableScriptingAddition = true;
      # TODO: yabairc (and maybe skhdrc?) refer to sketchybarrc and related files. How should this be organized?
      # Could maybe use services.yabai.config to pass reference to skhd config dir?
      extraConfig = builtins.readFile ./config/yabai/yabairc;
    };
    skhd = {
      # When home-manager or nix-darwin creates launchd services on Darwin, it tries to use things like $HOME in the PATH set in EnvironmentVariables in the launchd service. However, according to LaunchControl, that field does not support variable expansion. Hence $HOME/.nix-profile/bin does not end up in the PATH for skhd.
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

  # Note: To correlate settings in System Settings with their names here, you can use `defaults read` to output (I think) all system settings. You can then save that to a file, change something in System Settings, and diff the new output of defaults read against the previous output. E.g.:
  # ```sh
  # defaults read > before
  # # Do change
  # defaults read | diff before -
  # # See which options changed
  # ```
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
}
