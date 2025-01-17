{
  pkgs ? import <nixpkgs> { },
}:
pkgs.appimageTools.wrapType2 {
  name = "filen-desktop";
  src = pkgs.fetchurl {
    url = "https://cdn.filen.io/@filen/desktop/release/latest/Filen_linux_x86_64.AppImage";
    sha256 = "35aa39072f19f2531b45ca76320c3ec5a8a21735310a6e92dd2004e457c36699";
  };
  # extraPkgs = pkgs: with pkgs; [ ];
}
