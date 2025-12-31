{ config, ... }:
{
  # Enable COSMIC Desktop declarative configuration
  wayland.desktopManager.cosmic.enable = true;

  # Enable COSMIC Calculator
  programs.cosmic-ext-calculator.enable = true;

  programs.cosmic-ext-tweaks = {
    enable = true;
    settings.app_theme = config.lib.cosmic.mkRON "enum" "System";
  };
}
