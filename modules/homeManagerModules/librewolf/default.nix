{ config, lib, pkgs, ... }:

let
  cfg = config.local.librewolf;
in
{
  options.local.librewolf = {
    enable = lib.mkEnableOption "LibreWolf browser";
    deviceName = lib.mkOption {
      description = "Firefox Sync device name";
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    xdg.configFile."tridactyl/tridactylrc".source = ./tridactylrc;
    programs.librewolf = {
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
      profiles.primary = {
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

    home.activation.librewolfNativeMessaging = lib.hm.dag.entryAfter [
      "writeBoundary"
    ] "ln -sf ~/.mozilla/native-messaging-hosts ~/.librewolf/native-messaging-hosts";
  };
}
