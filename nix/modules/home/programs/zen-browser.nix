{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.sysconf.programs.zen-browser;
  profileName = "nelly";
in
{
  options.sysconf.programs.zen-browser = {
    enable = lib.mkEnableOption "zen-browser configuration";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.zen-browser ];

    # Create the base .zen directory structure
    home.file.".zen/profiles.ini".text = ''
      [Install${builtins.hashString "md5" profileName}]
      Default=${profileName}
      Locked=1

      [Profile0]
      Name=${profileName}
      IsRelative=1
      Path=${profileName}
      Default=1

      [General]
      StartWithLastProfile=1
      Version=2
    '';

    # User preferences file
    home.file.".zen/${profileName}/user.js".text = ''
      // Zen Browser user preferences
      // This file is read on startup and preferences are applied to the profile

      // Basic settings
      user_pref("browser.shell.checkDefaultBrowser", false);
      user_pref("browser.startup.homepage", "about:blank");
      user_pref("browser.tabs.warnOnClose", false);
      user_pref("sidebar.verticalTabs", true);
      user_pref("widget.gtk.libadwaita-colors.enabled", false); // disable libadwaita theming
      user_pref("zen.view.use-single-toolbar", false); // puts the url bar on top instead of in sidebar
      user_pref("zen.urlbar.behavior", "normal");

      // Disable telemetry and data collection
      user_pref("browser.ping-centre.telemetry", false);
      user_pref("datareporting.healthreport.uploadEnabled", false);
      user_pref("datareporting.policy.dataSubmissionEnabled", false);
      user_pref("toolkit.telemetry.archive.enabled", false);
      user_pref("toolkit.telemetry.bhrPing.enabled", false);
      user_pref("toolkit.telemetry.coverage.opt-out", true);
      user_pref("toolkit.telemetry.enabled", false);
      user_pref("toolkit.telemetry.firstShutdownPing.enabled", false);
      user_pref("toolkit.telemetry.newProfilePing.enabled", false);
      user_pref("toolkit.telemetry.server", "data:,");
      user_pref("toolkit.telemetry.shutdownPingSender.enabled", false);
      user_pref("toolkit.telemetry.unified", false);
      user_pref("toolkit.telemetry.updatePing.enabled", false);

      // Privacy settings
      user_pref("browser.safebrowsing.downloads.remote.enabled", false);
      user_pref("privacy.trackingprotection.enabled", true);
      user_pref("dom.security.https_only_mode", true);

      // Disable Pocket
      user_pref("extensions.pocket.enabled", false);

      // Disable sponsored content
      user_pref("browser.newtabpage.activity-stream.showSponsored", false);
      user_pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);

      // Disable Firefox studies
      user_pref("app.shield.optoutstudies.enabled", false);
      user_pref("app.normandy.enabled", false);
    '';

    # Chrome directory for CSS customization
    home.file.".zen/${profileName}/chrome/userChrome.css".text = "";
  };
}
