{
  flake-root,
  config,
  pkgs,
  inputs,
  mod,
  ...
}:

# Just a single user on this machine
let
  user = "mvilladsen";
in
{
  imports = [
    ./dock
    ./homebrew
    ./autorestic.nix
    (mod "system/common/client")
  ];

  users = {
    users.${user} = {
      home = "/Users/${user}";
      isHidden = false;
      # Set as users.defaultShell on nixos, but that option doesn't exist on nix-darwin
      shell = pkgs.zsh;
    };
    knownUsers = [ "builder" ];
    knownGroups = [ "builders" ];
  };

  # Enable sudo authentication with Touch ID
  security = {
    pam.services.sudo_local.touchIdAuth = true;
    sudo.extraConfig = "%admin ALL = (ALL) NOPASSWD: ALL";
  };

  # Enable linux builder VM.
  # This setting relies on having access to a cached version of the builder, since Darwin can't build it itself. The configuration options of the builder *can* be changed, but requires access to a (in this case) aarch64-linux builder to build. Hence on a new machine, or if there's any problems with the existing builder, the build fails.
  # For this reason, avoid changing the configuration options of linux-builder if at all possible.
  nix = {
    linux-builder = {
      enable = true;
      package = pkgs.darwin.linux-builder-x86_64;
      # Default is 1; increase priority of local builder over unreliable remote machines, since we usually won't build much x86_64 on aarch64 machines.
      speedFactor = 10;
      # Likely to fix weird build issues (including related to evaluating derivations while running `just check-all` as discovered on 250102), but at the cost of more rebuilding.
      # Enable if problems arise, or consider removing /var/lib/darwin-builder to force reinstantiation of the builders store without enabling this option.
      # ephemeral = true;
    };
  };

  # For some reason the mkMerge/mkIf combo in modules/shared doesn't want to play nice with this option.
  programs = {
    zsh.enableSyntaxHighlighting = true;
    man.enable = true;
  };

  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    user = "${user}";
    taps = with inputs; {
      "homebrew/homebrew-core" = homebrew-core;
      "homebrew/homebrew-cask" = homebrew-cask;
      "homebrew/homebrew-bundle" = homebrew-bundle;
      "homebrew/homebrew-services" = homebrew-services;
      "felixkratz/homebrew-formulae" = felixkratz-formulae;
      "pirj/homebrew-noclamshell" = pirj-noclamshell;
      "apple/homebrew-apple" = homebrew-apple;
    };
    mutableTaps = false;
  };

  home-manager = {
    users.${user}.home.homeDirectory = config.users.users.${user}.home;
    sharedModules = [ (mod "home-manager/darwin") ];
  };

  age.secrets = {
    # Build autorestic config with absolute paths to needed binaries by writing template, then doing text substitution in generator.
    # Proof of concept for combining secrets with nix-native information.
    # XXX: The generator is not actually needed anymore, but keeping it here for discoverability reasons.
    "mbv-mba.autorestic.yml.base".rekeyFile = flake-root + "/secrets/other/mbv-mba.autorestic.yml.age";
    "mbv-mba.autorestic.yml" = {
      generator = {
        dependencies = {
          autorestic-base = config.age.secrets."mbv-mba.autorestic.yml.base";
        };
        script =
          {
            pkgs,
            lib,
            decrypt,
            deps,
            ...
          }:
          # Insert absolute paths to binaries for fd and head (otherwise fd might not exist and the darwin system head might be used, which does not support as many options)
          ''
            ${decrypt} ${lib.escapeShellArg deps.autorestic-base.file} | ${lib.getBin pkgs.sd}/bin/sd "@fd@" "${lib.getBin pkgs.fd}/bin/fd" | ${lib.getBin pkgs.sd}/bin/sd "@head@" "${lib.getBin pkgs.coreutils-full}/bin/head"
          '';
      };
    };
  };

  local = {
    autorestic.ymlFile = config.age.secrets."mbv-mba.autorestic.yml".path;
    ssh-clients.users = [ user ];

    keys.enable_authorized_access = true;
    emacs = {
      enable = true;
      # package = pkgs.my-emacs-mac;
    };

    # TODO: Configure
    # Fully declarative dock using the latest from Nix Store
    dock = {
      enable = true;
      entries = [
        { path = "/System/Applications/Messages.app/"; }
        # Kitty or Alacritty?
        { path = "${pkgs.alacritty}/Applications/Alacritty.app/"; }
        { path = "/System/Applications/Music.app/"; }
        { path = "/System/Applications/Photos.app/"; }
        {
          path = "${config.users.users.${user}.home}/Dropbox/docs/work";
          section = "others";
          options = "--sort name --view grid --display folder";
        }
        {
          path = "${config.users.users.${user}.home}/Downloads";
          section = "others";
          options = "--sort name --view grid --display stack";
        }
      ];
    };
  };

  services = {
    tailscale.enable = true;
    # NOTE: On permissions: The MacOS System Settings menus for giving various accessibility permissions to things like Yabai and SKHD fill up with duplicates over time after upgrading each app multiple times. One can get rid of this by running `tccutil reset All`, which resets permissions for everything, and clears up the duplicates.
    # Note that this is a pretty brute-force method. It will require reenabling permissions on everything, and will possibly lock up the system until a restart.
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
      skhdConfig = (builtins.readFile (flake-root + "/config/skhd/skhdrc")) + ''

        ctrl + alt - return : ${pkgs.kitty}/bin/kitty --single-instance $HOME'';
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
  # Fix for skhd not hot-reloading changes to config files on nix-darwin activation.
  # https://github.com/LnL7/nix-darwin/issues/333#issuecomment-1981495455
  system.activationScripts.hotloadSKHD.text = ''
    su - $(logname) -c '${pkgs.skhd}/bin/skhd -r'
  '';

  # Note: To correlate settings in System Settings with their names here, you can use `defaults read` to output (I think) all system settings. You can then save that to a file, change something in System Settings, and diff the new output of defaults read against the previous output. E.g.:
  # defaults read > before
  # # Do change
  # defaults read | diff before -
  # # See which options changed
  # ```
  system = {
    primaryUser = user;
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
