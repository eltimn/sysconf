# This is included on every host
{
  config,
  lib,
  pkgs,
  ...
}:
let
  settings = config.sysconf.settings;
in
{
  imports = [
    ./containers
    ./desktop
    ./services
    ./users
    ./settings.nix
    ./sops.nix
  ];

  config = lib.mkMerge [
    {
      environment.systemPackages = with pkgs; [
        age
        bat
        btop
        dnsutils
        ghostty.terminfo
        git
        gum
        htop
        jq
        parted
        s3cmd
        sshfs
        stow
        tldr
        tree
        vim
        wget
        whois
      ];

      programs.zsh.enable = true;
    }

    (lib.mkIf (settings.desktopEnvironment == "gnome") {
      sysconf.desktop.gnome.enable = true;
    })
    (lib.mkIf (settings.desktopEnvironment == "cosmic") {
      sysconf.desktop.cosmic.enable = true;
    })
  ];
}
