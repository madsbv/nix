{
  mod,
  user,
  config,
  lib,
  osConfig,
  hostname,
  pkgs,
  flake-root,
  nox,
  inputs,
  ...
}:

# Home manager configuration for graphical client machines.

let
  # Really just for git
  name = "Mads Bach Villadsen";
  email = "mvilladsen@pm.me";
in
{
  imports = [
    ./email.nix
    (mod "home-manager/common/common")
  ];

  home = {
    packages = pkgs.callPackage ./packages.nix { inherit nox; };
  };

  local = {
    email = {
      enable = true;
      maildir = "${config.xdg.dataHome}/Mail";
      muhome = "${config.xdg.cacheHome}/mu";
      muAddressArgs = osConfig.age.secrets.mu-init-addresses.path;
      pmbridge-password = osConfig.age.secrets.pmbridge-password.path;
    };
  };

  home = {
    sessionPath = [ "$HOME/go/bin" ];
    sessionVariables = {
      TERMINAL = "kitty";
    };
    activation.librewolfNativeMessaging = lib.hm.dag.entryAfter [
      "writeBoundary"
    ] ''ln -sf ~/.mozilla/native-messaging-hosts ~/.librewolf/native-messaging-hosts'';
  };

  xdg.configFile."tridactyl" = {
    source = flake-root + "/config/tridactyl/";
  };

  programs = {
    librewolf = {
      enable = true;
      languagePacks = [
        "en-US"
        "da"
      ];
      settings = {
        "browser.download.useDownloadDir" = true;
        "browser.newtab.extensionControlled" = true;
        "browser.newtab.privateAllowed" = true;
        "browser.newtabpage.activity-stream.showSearch" = false;
        "browser.newtabpage.enabled" = false;
        "browser.search.separatePrivateDefault" = false;
        "browser.startup.homepage" = "chrome://browser/content/blanktab.html";
        "browser.startup.page" = 3;
        "browser.tabs.inTitlebar" = 0;
        "browser.tabs.warnOnOpen" = false;
        "browser.theme.content-theme" = 0;
        "browser.theme.toolbar-theme" = 0;
        "browser.toolbars.bookmarks.visibility" = "never";
        "browser.translations.panelShown" = true;
        "datareporting.usage.uploadEnabled" = false;
        "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
        "extensions.ui.extension.hidden" = false;
        "extensions.ui.plugin.hidden" = false;
        "general.autoScroll" = true;
        "identity.fxaccounts.account.device.name" = "LibreWolf on mbv-workstation";
        "identity.fxaccounts.enabled" = true;
        # The default (1, sticky blocking). Set to "2" for strict blocking.
        "media.autoplay.blocking_policy" = 1;
        "media.eme.enabled" = true;
        "privacy.clearOnShutdown.history" = false;
        "privacy.clearOnShutdown.downloads" = false;
        "privacy.donottrackheader.enabled" = true;
        "privacy.globalprivacycontrol.enabled" = false;
        # Tridactyl on addons.mozilla.org and others
        "privacy.resistFingerprinting.block_mozAddonManager" = true;
        "privacy.userContext.extension" = "tridactyl.vim@cmcaine.co.uk";
        "services.sync.declinedEngines" = "passwords,addresses,creditcards";
        "services.sync.engine.passwords" = false;
        "services.sync.engine.prefs.modified" = false;
        # userChrome.css
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "webgl.disabled" = false;
      };
      nativeMessagingHosts = [ pkgs.tridactyl-native ];
      profiles = {
        primary = {
          isDefault = true;
          userChrome = ''
            /* Hide tab bar completely */
            #TabsToolbar {
              visibility: collapse;
            }
            /* When window is not focused, match the URL bar opacity with the inactive application buttons */
            #nav-bar {
              :root[tabsintitlebar] & {
                will-change: opacity;
                transition: opacity var(--inactive-window-transition);

                &:-moz-window-inactive {
                  opacity: var(--inactive-titlebar-opacity);
                }
              }
            }
          '';
        };
      };
    };
    go = {
      enable = true;
      goPath = "go";
      # TODO: This makes the package available as a library, not binary. Is there an alternative in Nix or do we add a `go install` command to activation script?
      packages = {
        "github.com/bootdotdev/bootdev" = inputs.bootdev;
      };
    };

    kitty = {
      enable = true;
      shellIntegration.enableZshIntegration = true;
      # TODO: Either do settings natively in nix, or figure out how to just manage this config file as xdg config?
      extraConfig =
        builtins.readFile (flake-root + "/config/kitty/kitty.conf")
        + builtins.readFile (config.scheme inputs.base16-kitty);
    };
    wezterm = {
      enable = true;
      enableZshIntegration = true;
    };

    # mbv: Let's just use this for now
    alacritty = {
      enable = true;
      settings = {
        cursor = {
          style = "Block";
        };

        window = {
          opacity = 1.0;
          padding = {
            x = 24;
            y = 24;
          };
        };

        font = {
          normal = {
            family = "MesloLGS NF";
            style = "Regular";
          };
          size = lib.mkMerge [
            (lib.mkIf pkgs.stdenv.hostPlatform.isLinux 10)
            (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin 14)
          ];
        };

        # Base16 colors
        colors =
          with config.scheme.withHashtag;
          let
            default = {
              black = base00;
              white = base07;
              inherit
                red
                green
                yellow
                blue
                cyan
                magenta
                ;
            };
          in
          {
            primary = {
              background = base00;
              foreground = base07;
            };
            cursor = {
              text = base02;
              cursor = base07;
            };
            normal = default;
            bright = default;
            dim = default;
          };
      };
    };
    ssh = {
      enable = true;
      package = pkgs.openssh;
      matchBlocks = {
        "github.com" = {
          hostname = "github.com";
          identitiesOnly = true;
        };
      };
      extraOptionOverrides.IdentityFile = osConfig.age.secrets."id.${hostname}.${user}".path;
    };
    gh = {
      enable = true;
      settings.editor = "vim";
    };
    git = {
      userName = name;
      userEmail = email;
    };
  };
}
