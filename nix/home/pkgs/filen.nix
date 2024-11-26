{ pkgs ? import <nixpkgs> {} }:
pkgs.appimageTools.wrapType2 {
  name = "filen";
  src = pkgs.fetchurl {
    url = "https://cdn.filen.io/desktop/release/filen_x86_64.AppImage";
    sha256 = "e6f927753f55ffcd5f51dcd2f8a4df0233c018ed08251c7c42137104d1bc9e75";
  };
  # extraPkgs = pkgs: with pkgs; [ ];
}
