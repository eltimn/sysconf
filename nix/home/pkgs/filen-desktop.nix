{
  pkgs ? import <nixpkgs> { },
}:
pkgs.appimageTools.wrapType2 {
  name = "filen-desktop";
  src = pkgs.fetchurl {
    url = "https://cdn.filen.io/@filen/desktop/release/latest/Filen_linux_x86_64.AppImage";
    sha256 = "628b5203f2f897e6ece4908b9c5198d251996e97bd00d497869d8bdea24965d6";
  };
  # extraPkgs = pkgs: with pkgs; [ ];
}
