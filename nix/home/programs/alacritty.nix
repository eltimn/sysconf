# does not have tabs

{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [ alacritty-theme ];
  };

  # requires nixGL: https://github.com/nix-community/nixGL
  programs.alacritty = {
    enable = true;
    # settings = {
    # };
  };
}
