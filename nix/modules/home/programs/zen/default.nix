{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.sysconf.programs.zen-browser;
in
{
  imports = [
    ./xdg.nix
  ];

  options.sysconf.programs.zen-browser = {
    enable = lib.mkEnableOption "zen-browser configuration";

    profileName = lib.mkOption {
      type = lib.types.str;
      default = "default";
      description = "Name of the zen-browser profile to configure.";
    };

    extensions = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "List of Firefox extensions to install.";
      example = lib.literalExpression "with pkgs.firefox-addons; [ ublock-origin privacy-badger ]";
    };

    settings = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.oneOf [
          lib.types.bool
          lib.types.str
          lib.types.int
        ]
      );
      default = { };
      description = "Preferences to set in zen-browser.";
      example = {
        "browser.shell.checkDefaultBrowser" = false;
        "browser.startup.homepage" = "about:blank";
        "sidebar.verticalTabs" = true;
      };
    };

    userChrome = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Custom CSS for zen-browser UI customization.";
    };

    policies = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Enterprise policies to apply to zen-browser.";
      example = {
        DisableAppUpdate = true;
        DisableTelemetry = true;
        DisablePocket = true;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.zen-browser = {
      enable = true;
      languagePacks = [ "en-US" ];
      nativeMessagingHosts = with pkgs; [ vdhcoapp ]; # video download helper companion app
      policies = {
        DisableAppUpdate = true;
        DisableTelemetry = true;
        DisablePocket = true;
        DontCheckDefaultBrowser = true;
        FirefoxHome = {
          Search = true;
          TopSites = false;
          Highlights = false;
          Pocket = false;
          Snippets = false;
        };
      }
      // cfg.policies;

      profiles.${cfg.profileName} = {
        userChrome = cfg.userChrome + ''
          /* Personal Zen Browser UI customizations */

          /* Hide tab bar if using vertical tabs */
          #tabbrowser-tabs[orient="horizontal"] {
            display: none !important;
          }

          /* Compact sidebar styling */
          .sidebar-panel {
            font-size: 12px !important;
          }

          /* Better URL bar visibility */
          #urlbar {
            background-color: rgba(255, 255, 255, 0.1) !important;
          }
        '';

        search = import ./search.nix { inherit pkgs; };

        extensions.packages =
          with pkgs.firefox-addons;
          [
            bitwarden
            floccus
            privacy-badger
            tranquility-1
            # video-downloadhelper
          ]
          ++ cfg.extensions;

        settings = {
          # Basic settings
          # "browser.shell.checkDefaultBrowser" = false;
          "browser.startup.homepage" = "about:blank";
          "browser.tabs.warnOnClose" = false;
          "sidebar.verticalTabs" = true;
          "widget.gtk.libadwaita-colors.enabled" = false;
          "zen.view.use-single-toolbar" = false;

          # Extension auto-enable
          "extensions.autoDisableScopes" = 0;

          # Privacy settings
          "browser.safebrowsing.downloads.remote.enabled" = false;
          "privacy.trackingprotection.enabled" = true;
          "dom.security.https_only_mode" = true;

          # Disable telemetry and data collection
          "browser.ping-centre.telemetry" = false;
          "datareporting.healthreport.uploadEnabled" = false;
          "datareporting.policy.dataSubmissionEnabled" = false;
          "toolkit.telemetry.archive.enabled" = false;
          "toolkit.telemetry.bhrPing.enabled" = false;
          "toolkit.telemetry.coverage.opt-out" = true;
          "toolkit.telemetry.enabled" = false;
          "toolkit.telemetry.firstShutdownPing.enabled" = false;
          "toolkit.telemetry.newProfilePing.enabled" = false;
          "toolkit.telemetry.server" = "data:,";
          "toolkit.telemetry.shutdownPingSender.enabled" = false;
          "toolkit.telemetry.unified" = false;
          "toolkit.telemetry.updatePing.enabled" = false;

          # Disable Firefox studies
          "app.shield.optoutstudies.enabled" = false;
          "app.normandy.enabled" = false;
        }
        // cfg.settings;
      };
    };
  };
}
