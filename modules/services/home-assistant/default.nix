{
  config,
  pkgs,
  flake-root,
  lib,
  ...
}:
let
  appdaemonConfig = pkgs.writeText "appdaemon.toml" ''
    secrets = "${config.age.secrets."appdaemon-secrets.toml".path}"

    [appdaemon]
    time_zone = "!secret time_zone"
    latitude = "!secret latitude"
    longitude = "!secret longitude"
    elevation = "!secret elevation"
    app_dir = "/etc/appdaemon/apps"

    [appdaemon.plugins.HASS]
    type = "hass"
    ha_url = "!secret ha_url"
    token = "!secret ha_token"
  '';

  # List of relative paths to files in dir, recursively
  readDirFilesRec =
    dir:
    with builtins;
    let
      # List of paths directly in dir
      subs = readDir dir;

      # List of file names in dir
      files = filter (name: subs.${name} == "regular") (attrNames subs);
      # List of subdirectories in dir
      dirs = filter (name: subs.${name} == "directory") (attrNames subs);
      # NOTE: There can also be symlinks and "unknown" type which we ignore: https://nix.dev/manual/nix/2.18/language/builtins#builtins-readDir
      # We could arguably try to include those as files using the "partition" function instead of filter (https://nix.dev/manual/nix/2.18/language/builtins#builtins-partition), seems more error prone though

      # Paths to files which are in subdirectories of dir, relative to dir
      filesInDirs = map (dir: map (file: "${dir}/${file}") readDirFilesRec dir) dirs;

      # All file names, recursively
      recFiles = foldl' (a: b: a ++ b) files filesInDirs;
    in
    recFiles;

  # Create attribute set of the form
  # { "target/file1" = { source = sourceDir/file1; } // otherAttrs; "targetDir/subdir/file2" = { source = sourceDir/subdir/file2; } // otherAttrs; }
  # Adding `dirToEtcAttrs sourceDir targetDir otherAttrs` to the environment.etc attrSet means that all files in sourceDir will be recursively linked to /etc/targetDir.
  dirToEtcAttrs =
    sourceDir: targetDir: otherAttrs:
    with builtins;
    listToAttrs (
      map (file: {
        name = "${targetDir}/${file}";
        value = {
          source = sourceDir + "/${file}";
        } // otherAttrs;
      }) (readDirFilesRec sourceDir)
    );

in
{

  services = {
    # TODO: Configure
    # Available on mbv-xps13:8123
    home-assistant = {
      enable = true;
      configWritable = true;
      lovelaceConfigWritable = true;
      extraComponents = [
        "awair"
        "accuweather"
        "tailscale"
        # Supposedly for Smart Life
        # See also https://github.com/rospogrigio/localtuya
        "tuya"
        "wake_on_lan"
        "jellyfin"
        "seventeentrack"
        "speedtestdotnet"
        "default_config"
        "met"
        "esphome"
        "tplink"
        "tplink_tapo"
        "ecobee"
        "homekit_controller"
        "roomba"
      ];
      config.homeassistant = {
        name = "!secret name";
        time_zone = "!secret time_zone";
        latitude = "!secret latitude";
        longitude = "!secret longitude";
        elevation = "!secret elevation";
        unit_system = "metric";
        temperature_unit = "C";
      };
    };
  };

  system.activationScripts = {
    linkHomeAssistantSecrets = lib.stringAfter [ "var" ] ''
      ln -s ${config.age.secrets."home-assistant-secrets.yaml".path} /var/lib/hass/secrets.yaml
    '';
    fixAppdaemonConfigPermissions = lib.stringAfter [ "etc" ] ''
      chown -R hass /etc/appdaemon
    '';
  };

  environment = {
    systemPackages = [ pkgs.appdaemon ];
    etc =
      # Copy all appdaemon apps in this repo to /etc/appdaemon/apps.
      # Allows live modification for testing and development, though /etc/appdaemon is not a persistent directory.
      dirToEtcAttrs (flake-root + "/modules/services/home-assistant/appdaemon/apps") "appdaemon/apps" {
        mode = "0644";
        user = "hass";
      }
      // {
        "/appdaemon/appdaemon.toml" = {
          source = appdaemonConfig;
          mode = "0644";
          user = "hass";
        };
      };
  };

  age.secrets = {
    "appdaemon-secrets.toml" = {
      rekeyFile = flake-root + "/secrets/other/appdaemon-secrets.toml.age";
      owner = "hass";
    };
    "home-assistant-secrets.yaml" = {
      rekeyFile = flake-root + "/secrets/other/home-assistant-secrets.yaml.age";
      owner = "hass";
    };
  };

  systemd.services.appdaemon-ha = {
    description = "Appdaemon attached to home-assistant";

    wantedBy = [ "multi-user.target" ];
    after = [
      "network.target"
      "home-assistant.target"
    ];

    restartIfChanged = true; # set to false, if restarting is problematic

    serviceConfig = {
      User = "hass";
      ExecStart = ''${pkgs.appdaemon}/bin/appdaemon --toml --config "/etc/appdaemon"'';
      Restart = "always";
    };
  };
}
