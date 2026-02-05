{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:
let
  cfg = config.sysconf.desktop.niri;

  noctaliaWallpapers = {
    defaultWallpaper = "${config.home.homeDirectory}/background-image";
    wallpapers = { };
  };
in
{
  options.sysconf.desktop.niri = {
    enable = lib.mkEnableOption "niri";
  };

  config = lib.mkIf cfg.enable {
    home = {
      packages =
        with pkgs;
        [
          niri
          foot
          fuzzel
          grim
          mako
          playerctl
          polkit_gnome
          slurp
          swappy
          swayidle
          wl-clipboard
          xdg-desktop-portal-gtk
          xdg-desktop-portal-wlr
        ]
        ++ [ pkgs-unstable.noctalia-shell ];

      file.".cache/noctalia/wallpapers.json".text = builtins.toJSON noctaliaWallpapers;
    };

    # Config files are managed manually in ~/.config/niri/ and ~/.config/noctalia/
    # to allow rapid iteration without rebuilding

    systemd.user.services = {
      noctalia-shell = {
        Unit = {
          Description = "Noctalia Shell";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
          ConditionEnvironment = "XDG_CURRENT_DESKTOP=niri";
        };
        Service = {
          ExecStart = lib.getExe pkgs-unstable.noctalia-shell;
          Restart = "on-failure";
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };

      mako = {
        Unit = {
          Description = "Mako notifications";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
          ConditionEnvironment = "XDG_CURRENT_DESKTOP=niri";
        };
        Service = {
          ExecStart = lib.getExe pkgs.mako;
          Restart = "on-failure";
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };

      polkit-gnome-authentication-agent = {
        Unit = {
          Description = "Polkit authentication agent";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
          ConditionEnvironment = "XDG_CURRENT_DESKTOP=niri";
        };
        Service = {
          ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          Restart = "on-failure";
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };

      swayidle = {
        Unit = {
          Description = "Idle manager";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
          ConditionEnvironment = "XDG_CURRENT_DESKTOP=niri";
        };
        Service = {
          ExecStart = "${pkgs.swayidle}/bin/swayidle -w timeout 600 'noctalia-shell ipc call lockScreen lock' before-sleep 'noctalia-shell ipc call lockScreen lock'";
          Restart = "on-failure";
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };
    };
  };
}

# niri regex: https://docs.rs/regex/latest/regex/#syntax
