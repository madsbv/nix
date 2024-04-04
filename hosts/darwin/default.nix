{
  hostname,
  flake-root,
  pkgs,
  ...
}:

{
  imports = [
    "${flake-root}/modules/darwin"
    "${flake-root}/modules/shared"
  ];

  # TODO: Set up restic/autorestic backups on the system level. See e.g. https://www.arthurkoziel.com/restic-backups-b2-nixos/
  # See also https://nixos.wiki/wiki/Restic for a way to run restic as a separate user.

  # Enable linux builder VM.
  # This setting relies on having access to a cached version of the builder, since Darwin can't build it itself. The configuration options of the builder *can* be changed, but requires access to a (in this case) aarch64-linux builder to build. Hence on a new machine, or if there's any problems with the existing builder, the build fails.
  # For this reason, avoid changing the configuration options of linux-builder if at all possible.
  nix.linux-builder.enable = true;
  # For some reason the mkMerge/mkIf combo in modules/shared doesn't want to play nice with this option.
  programs = {
    zsh.enableSyntaxHighlighting = true;
    man.enable = true;
  };

  networking = {
    computerName = hostname;
    hostName = hostname;
    localHostName = hostname;
    knownNetworkServices = [
      "AX88179A"
      "Thunderbolt Bridge"
      "Wi-Fi"
      "iPhone USB"
    ];
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
  # launchd.daemons = {
  #   tailscaled = {
  #     command = "${pkgs.tailscale}/bin/tailscaled";
  #     serviceConfig = {
  #       RunAtLoad = true;
  #       Label = "com.tailscale.tailscaled";
  #     };
  #   };
  # };

  # Enable sudo authentication with Touch ID
  security.pam.enableSudoTouchIdAuth = true;

  services = {
    nix-daemon.enable = true;
    tailscale.enable = true;
    yabai = {
      enable = true;
      enableScriptingAddition = true;
      # TODO: yabairc (and maybe skhdrc?) refer to sketchybarrc and related files. How should this be organized?
      # Could maybe use services.yabai.config to pass reference to skhd config dir?
      extraConfig = builtins.readFile (flake-root + "/config/yabai/yabairc");
    };
    skhd = {
      # When home-manager or nix-darwin creates launchd services on Darwin, it tries to use things like $HOME in the PATH set in EnvironmentVariables in the launchd service. However, according to LaunchControl, that field does not support variable expansion. Hence $HOME/.nix-profile/bin does not end up in the PATH for skhd.
      # See https://github.com/LnL7/nix-darwin/issues/406
      # Also, nix-based string replacement does not work when reading from separate file, so we have to do that here.
      enable = true;
      skhdConfig =
        (builtins.readFile (flake-root + "/config/skhd/skhdrc"))
        + ''

          lctrl + lcmd - return : ${pkgs.kitty}/bin/kitty --single-instance ~'';
    };
    # NOTE: The config files for these services are in the users home directory. They are set in modules/darwin/home-manager as xdg.configFile's.
    # It would be better to be able to set the configs as part of the service definitions, but that is not supported.
    karabiner-elements.enable = true;
    # The sketchybar service module has a config option, but it takes the contents of sketchybarrc as argument. My config is split across multiple arguments.
    sketchybar = {
      enable = true;
      # Empty config string means nix won't manage the config.
      # TODO: If we want to have the config managed by nix, we can set `config` here to a string that simply imports our usual sketchybarrc. We'd have to only use relative paths in any sketchybar config, and we'd have to point Yabai configuration at the nix-managed files as well.
      # This would make config tinkering more annoying.
      config = "";
      # Dependencies of config
      extraPackages = [ pkgs.jq ];
    };
  };

  # TODO: This should be moved into a file for gui client settings so it doesn't get loaded on all servers.
  # Enable fonts dir
  fonts =
    let
      key = if pkgs.stdenv.isDarwin then "fonts" else "packages";
    in
    {
      fontDir.enable = true;
      ${key} = with pkgs; [
        dejavu_fonts
        emacs-all-the-icons-fonts
        jetbrains-mono
        feather-font # from overlay
        font-awesome
        hack-font
        meslo-lgs-nf
        nerdfonts
        noto-fonts
        noto-fonts-emoji
      ];
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

        # Autohide menu bar to make space for sketchyba
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
        ShowStatusBar = true;
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
      };

      trackpad = {
        Clicking = true;
        # If true, using the trackpad with three fingers lets you drag the mouse as if left click was held down on a mouse, e.g. to highlight text or move windows.
        TrackpadThreeFingerDrag = false;
        # Enable silent clicking
        ActuationStrength = 0;
      };
      # Sounds like something I want, but it actually reduces motions related to trackpad movements which I want to keep.
      universalaccess = {
        reduceMotion = false;
      };
    };

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
  };
}
