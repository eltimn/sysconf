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

    userContent = lib.mkOption {
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
        userChrome = cfg.userChrome;
        # userChrome = cfg.userChrome + ''
        #   /* Personal Zen Browser UI customizations */
        #   /* Cosmic Theme Integration - Responsive to system dark/light mode */

        #   /* Dark Mode */
        #   @media (prefers-color-scheme: dark) {
        #     :root, html#main-window, body {
        #       /* Zen Specific Variables */
        #       --zen-primary-color: #2E598C !important;
        #       --zen-main-browser-background: #3b414d !important;
        #       --zen-main-browser-background-toolbar: #000000 !important;

        #       /* Legacy/Standard Variables - Dark */
        #       --zen-colors-primary: #2E598C !important;
        #       --zen-colors-secondary: #2e343eff !important;
        #       --zen-colors-tertiary: #3b414d !important;
        #       --zen-colors-border: #2e343eff !important;
        #       --zen-colors-background: #3b414d !important;
        #       --zen-colors-sidebar: #000000 !important;
        #       --toolbar-bgcolor: #000000 !important;
        #       --lwt-text-color: #eceff4 !important;
        #       --lwt-sidebar-background-color: #000000 !important;
        #     }

        #     #navigator-toolbox {
        #        background-color: #3b414d !important;
        #        border-bottom: 1px solid #474747 !important;
        #     }

        #     #sidebar-box, .sidebar-panel, #sidebar-search-container {
        #        background-color: #000000 !important;
        #     }
        #   }

        #   /* Light Mode */
        #   @media (prefers-color-scheme: light) {
        #     :root, html#main-window, body {
        #        /* Zen Specific Variables */
        #        --zen-primary-color: #003a99 !important;
        #        --zen-main-browser-background: #e2e2e2 !important;
        #        --zen-main-browser-background-toolbar: #f5f7fa !important;

        #        /* Legacy/Standard Variables - Light */
        #        --zen-colors-primary: #003a99 !important;
        #        --zen-colors-secondary: #c6c6c6 !important;
        #        --zen-colors-tertiary: #ffffff !important;
        #        --zen-colors-border: #c6c6c6 !important;
        #        --zen-colors-background: #e2e2e2 !important;
        #        --zen-colors-sidebar: #f5f7fa !important;
        #        --toolbar-bgcolor: #e2e2e2 !important;
        #        --lwt-text-color: #292929 !important;
        #        --lwt-sidebar-background-color: #f5f7fa !important;
        #     }

        #     #navigator-toolbox {
        #        background-color: #e2e2e2 !important;
        #        border-bottom: 1px solid #c6c6c6 !important;
        #     }

        #     #sidebar-box, .sidebar-panel, #sidebar-search-container {
        #        background-color: #f5f7fa !important;
        #     }
        #   }

        #   /* Hide tab bar if using vertical tabs */
        #   #tabbrowser-tabs[orient="horizontal"] {
        #     display: none !important;
        #   }

        #   /* Compact sidebar styling */
        #   .sidebar-panel {
        #     font-size: 12px !important;
        #     color: var(--lwt-text-color) !important;
        #   }
        # '';

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
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          "browser.shell.checkDefaultBrowser" = false;
          "browser.startup.homepage" = "about:blank";
          "browser.tabs.warnOnClose" = false;
          "sidebar.verticalTabs" = true;
          "widget.gtk.libadwaita-colors.enabled" = false;
          "zen.view.use-single-toolbar" = false;
          "browser.newtabpage.activity-stream.showSponsored" = false;
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;

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

    home.file.".zen/${cfg.profileName}/chrome/userContent.css".text = cfg.userContent;

    # Create user css files as mutable files (not symlink) so it can be edited externally
    # home.activation.copyZenConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    #   $DRY_RUN_CMD cat << EOF > "${config.home.homeDirectory}/.zen/${cfg.profileName}/chrome/userChrome.css"
    #   @import "${config.home.homeDirectory}/.cache/noctalia/zen-browser/zen-userChrome.css";
    #   EOF
    #   $DRY_RUN_CMD cat << EOF > "${config.home.homeDirectory}/.zen/${cfg.profileName}/chrome/userContent.css"
    #   @import "${config.home.homeDirectory}/.cache/noctalia/zen-browser/zen-userContent.css";
    #   EOF
    #   $DRY_RUN_CMD chmod u+w "${config.home.homeDirectory}/.zen/${cfg.profileName}/chrome/userChrome.css"
    #   $DRY_RUN_CMD chmod u+w "${config.home.homeDirectory}/.zen/${cfg.profileName}/chrome/userContent.css"
    # '';
  };
}
