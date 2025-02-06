# TODO: also install a desktop entry
# https://github.com/MarceColl/zen-browser-flake/blob/e6ab73f405e9a2896cce5956c549a9cc359e5fcc/flake.nix#L59
{
  pkgs,
}:

let
  name = "filen-desktop";
  version = "v3.0.44";
  # name = "${pname}-${version}";

  src = pkgs.fetchurl {
    url = "https://github.com/FilenCloudDienste/filen-desktop/releases/download/${version}/Filen_linux_x86_64.AppImage";
    sha256 = "4e8c379a0de9477c519001069d3dbc6f9a553b02481e9b7aba760d39867b3417";
  };

in
# appimageContents = pkgs.appimageTools.extractType2 { inherit name src; };
pkgs.appimageTools.wrapType2 {
  inherit name src;

  # extraInstallCommands = ''
  #   mv $out/bin/${name} $out/bin/${pname}
  #   install -m 444 -D ${appimageContents}/ubports-installer.desktop $out/share/applications/${pname}.desktop

  #   install -m 444 -D ${appimageContents}/${pname}.png $out/share/icons/hicolor/512x512/apps/${pname}.png

  #   substituteInPlace $out/share/applications/${pname}.desktop \
  #   	--replace 'Exec=AppRun --no-sandbox %U' 'Exec=${pname} %U'
  # '';

  # meta = {
  #   description = "File sync tool";
  #   homepage = "https://filen.io/";
  #   downloadPage = "https://github.com/FilenCloudDienste/filen-desktop/releases";
  #   license = lib.licenses.agpl3Only;
  #   platforms = [ "x86_64-linux" ];
  # };
}
