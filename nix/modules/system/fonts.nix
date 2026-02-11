{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sysconf.fonts;
  settings = config.sysconf.settings;
in
{
  options.sysconf.fonts = {
    enable = lib.mkEnableOption "centralized font configuration" // {
      default = settings.hostRole == "desktop";
    };

    sansSerif = lib.mkOption {
      type = lib.types.str;
      default = "Inter";
      description = "Default sans-serif font family";
    };

    serif = lib.mkOption {
      type = lib.types.str;
      default = "Noto Serif";
      description = "Default serif font family";
    };

    monospace = lib.mkOption {
      type = lib.types.str;
      default = "JetBrainsMono Nerd Font";
      description = "Default monospace font family";
    };

    emoji = lib.mkOption {
      type = lib.types.str;
      default = "Noto Color Emoji";
      description = "Default emoji font family";
    };

    size = lib.mkOption {
      type = lib.types.number;
      description = "Font size to use in terminals, editors, etc.";
      default = 18;
    };
  };

  config = lib.mkIf cfg.enable {
    # Install font packages system-wide
    fonts = {
      packages = with pkgs; [
        # Sans-serif: modern, highly readable UI font
        inter

        # Serif: comprehensive Unicode support for documents
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
        noto-fonts-color-emoji

        # Monospace: programming/terminal with icons
        nerd-fonts.jetbrains-mono

        # Additional international font support
        noto-fonts
      ];

      # Configure fontconfig defaults and rendering
      fontconfig = {
        enable = true;

        defaultFonts = {
          sansSerif = [ cfg.sansSerif ];
          serif = [ cfg.serif ];
          monospace = [ cfg.monospace ];
          emoji = [ cfg.emoji ];
        };

        # Rendering settings for crisp, smooth text
        antialias = true;
        hinting = {
          enable = true;
          style = "slight"; # Good balance of sharpness and accuracy
        };
        subpixel = {
          rgba = "rgb"; # Standard LCD subpixel arrangement
          lcdfilter = "default";
        };
      };
    };

    # Make fonts available in X11 (for XWayland compatibility)
    # services.xserver.desktopManager.xterm.enable = false;
  };
}
