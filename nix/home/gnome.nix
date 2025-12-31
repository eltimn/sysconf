{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      gnome-terminal # needed to run mount-secret on log in
      gnome-tweaks
      gnomeExtensions.appindicator
      gnomeExtensions.clipboard-indicator
      gnomeExtensions.dash-to-dock
    ];
  };
}
