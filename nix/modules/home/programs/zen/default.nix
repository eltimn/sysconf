{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.sysconf.programs.zen-browser;

  syncZenThemePkg = pkgs.writeShellScriptBin "sync-zen-theme" ''
    # This script will run when darkman detects a theme change and will update the zen-browser theme accordingly.
    THEME_MODE="$1"

    # check if the theme mode is valid
    if [[ "$THEME_MODE" != "dark" && "$THEME_MODE" != "light" ]]; then
      echo "Invalid theme mode: $THEME_MODE"
      exit 1
    fi

    # Create symlinks for zen-browser userChrome and userContent CSS files based on the current theme
    ln -sf "${config.home.homeDirectory}/.config/zen/themes/userChrome-$THEME_MODE.css" "${config.home.homeDirectory}/.config/zen/themes/userChrome.css"
    ln -sf "${config.home.homeDirectory}/.config/zen/themes/userContent-$THEME_MODE.css" "${config.home.homeDirectory}/.config/zen/themes/userContent.css"
  '';
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
      default = ''@import "${config.home.homeDirectory}/.config/zen/themes/userChrome.css";'';
      description = "Custom CSS for zen-browser UI customization.";
    };

    userContent = lib.mkOption {
      type = lib.types.lines;
      default = ''@import "${config.home.homeDirectory}/.config/zen/themes/userContent.css";'';
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
      suppressXdgMigrationWarning = true;
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
        search = import ./search.nix { inherit pkgs; };

        extensions.packages =
          with pkgs.firefox-addons;
          [
            bitwarden
            floccus
            privacy-badger
            pwas-for-firefox
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

    # home.activation.initZen = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    #   $DRY_RUN_CMD mkdir -p "${chromeDir}"
    #   $DRY_RUN_CMD cat << EOF > "${chromeDir}/userChrome.css"
    #   ${cfg.userChrome}
    #   EOF
    #   $DRY_RUN_CMD cat << EOF > "${chromeDir}/userContent.css"
    #   ${cfg.userContent}
    #   EOF
    #   $DRY_RUN_CMD chmod u+w "${chromeDir}/userChrome.css"
    #   $DRY_RUN_CMD chmod u+w "${chromeDir}/userContent.css"
    # '';

    home.packages = [ syncZenThemePkg ];

    xdg.configFile = {
      "zen/${cfg.profileName}/chrome/userChrome.css".text = cfg.userChrome;
      "zen/${cfg.profileName}/chrome/userContent.css".text = cfg.userContent;
      "zen/themes/userChrome-dark.css".source = ./files/userChrome-dark.css;
      "zen/themes/userContent-dark.css".source = ./files/userContent-dark.css;
      # Leave these blank and use the default light theme.
      "zen/themes/userChrome-light.css".text = "";
      "zen/themes/userContent-light.css".text = "";
    };

    sysconf.desktop.niri.themeHandlers.zen-browser = syncZenThemePkg;
  };
}
