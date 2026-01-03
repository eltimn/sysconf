# System-managed rootless containers using Podman Quadlet
#
# This module allows defining rootless containers at the NixOS system level,
# avoiding the need for Home Manager while still allowing system-level config
# (firewall ports, tmpfiles, etc.) to be co-located with the container definition.
#
# The quadlet files are placed in /etc/containers/systemd/users/${UID}/ which
# podman's systemd generator picks up for the specified user.
#
# Managing the service:
#   machinectl shell <username>@ /run/current-system/sw/bin/bash
#   systemctl --user status <container-name>
#   journalctl --user -eu <container-name>
# Or:
#   sudo -u <username> XDG_RUNTIME_DIR=/run/user/<uid> systemctl --user status <container-name>
#   sudo -u <username> XDG_RUNTIME_DIR=/run/user/<uid> journalctl --user -eu <container-name>
{
  config,
  lib,
  ...
}:
let
  cfg = config.sysconf.rootlessContainers;

  # Generate quadlet container config text
  mkContainerConfig = name: containerCfg: ''
    [Unit]
    Description=${containerCfg.description}
    ${lib.optionalString (containerCfg.unitConfig != "") containerCfg.unitConfig}

    [Container]
    Image=${containerCfg.image}
    ContainerName=${name}
    ${lib.optionalString containerCfg.autoUpdate "AutoUpdate=registry"}
    ${lib.optionalString (containerCfg.network != null) "Network=${containerCfg.network}"}
    ${lib.concatMapStrings (d: "AddDevice=${d}\n") containerCfg.devices}
    ${lib.concatMapStrings (v: "Volume=${v}\n") containerCfg.volumes}
    ${lib.concatMapStrings (p: "PublishPort=${p}\n") containerCfg.ports}
    ${lib.concatMapStrings (e: "Environment=${e}\n") containerCfg.environment}
    ${lib.concatMapStrings (f: "EnvironmentFile=${f}\n") containerCfg.environmentFiles}
    ${lib.optionalString (containerCfg.containerConfig != "") containerCfg.containerConfig}

    [Service]
    Restart=${containerCfg.restart}
    RestartSec=${toString containerCfg.restartSec}
    ${lib.optionalString (containerCfg.serviceConfig != "") containerCfg.serviceConfig}

    [Install]
    WantedBy=default.target
  '';

  # Container options submodule
  containerOpts =
    { name, ... }:
    {
      options = {
        enable = lib.mkEnableOption "this container" // {
          default = true;
        };

        description = lib.mkOption {
          type = lib.types.str;
          default = "${name} container";
          description = "Description for the systemd unit";
        };

        image = lib.mkOption {
          type = lib.types.str;
          description = "Container image to run";
          example = "docker.io/library/nginx:latest";
        };

        autoUpdate = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable podman auto-update for this container";
        };

        network = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "Network mode (e.g., 'host', 'bridge', or a network name)";
          example = "host";
        };

        devices = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "Devices to add to the container";
          example = [ "/dev/dri:/dev/dri" ];
        };

        volumes = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "Volumes to mount in the container";
          example = [ "/host/path:/container/path" ];
        };

        ports = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "Ports to publish";
          example = [
            "8080:80"
            "127.0.0.1:8443:443"
          ];
        };

        environment = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "Environment variables (KEY=value format)";
          example = [ "TZ=America/Chicago" ];
        };

        environmentFiles = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "Paths to environment files";
        };

        restart = lib.mkOption {
          type = lib.types.str;
          default = "always";
          description = "Restart policy for the service";
        };

        restartSec = lib.mkOption {
          type = lib.types.int;
          default = 10;
          description = "Seconds to wait before restarting";
        };

        # Escape hatches for additional config
        unitConfig = lib.mkOption {
          type = lib.types.lines;
          default = "";
          description = "Additional [Unit] section config";
        };

        containerConfig = lib.mkOption {
          type = lib.types.lines;
          default = "";
          description = "Additional [Container] section config";
        };

        serviceConfig = lib.mkOption {
          type = lib.types.lines;
          default = "";
          description = "Additional [Service] section config";
        };
      };
    };

  # User options submodule
  userOpts =
    { name, ... }:
    {
      options = {
        uid = lib.mkOption {
          type = lib.types.int;
          description = ''
            Fixed UID for the user.
            Required because the quadlet path /etc/containers/systemd/users/$UID/
            must be known at build time, before the user is created.
          '';
        };

        group = lib.mkOption {
          type = lib.types.str;
          default = name;
          description = "Primary group for the user (created automatically if it doesn't exist)";
        };

        createGroup = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Whether to create the primary group if it doesn't exist";
        };

        extraGroups = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ "systemd-journal" ];
          description = "Additional groups for the user";
        };

        home = lib.mkOption {
          type = lib.types.str;
          default = "/var/lib/${name}";
          description = "Home directory for the user";
        };

        containers = lib.mkOption {
          type = lib.types.attrsOf (lib.types.submodule containerOpts);
          default = { };
          description = "Containers to run as this user";
        };
      };
    };

  # Helper to check if a group is a "well-known" group that shouldn't be auto-created
  isExistingGroup = groupName: builtins.elem groupName [
    "users"
    "wheel"
    "systemd-journal"
    "audio"
    "video"
    "networkmanager"
    "docker"
    "podman"
  ];

in
{
  options.sysconf.rootlessContainers = {
    enable = lib.mkEnableOption "system-managed rootless containers";

    users = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule userOpts);
      default = { };
      description = "Users and their rootless containers";
    };
  };

  config = lib.mkIf cfg.enable {
    # Enable podman
    virtualisation.podman.enable = true;

    # Create groups for users that need them
    users.groups = lib.mkMerge (
      lib.mapAttrsToList (username: userCfg:
        lib.mkIf (userCfg.createGroup && !isExistingGroup userCfg.group) {
          ${userCfg.group} = {
            gid = userCfg.uid; # Use same ID as user for simplicity
          };
        }
      ) cfg.users
    );

    # Create users
    users.users = lib.mapAttrs (username: userCfg: {
      uid = userCfg.uid;
      isSystemUser = true;
      group = userCfg.group;
      extraGroups = userCfg.extraGroups;
      home = userCfg.home;
      createHome = true;
      shell = "/run/current-system/sw/bin/bash";
      linger = true;
      autoSubUidGidRange = true;
    }) cfg.users;

    # Create quadlet files
    environment.etc = lib.mkMerge (
      lib.flatten (
        lib.mapAttrsToList (
          username: userCfg:
          lib.mapAttrsToList (
            containerName: containerCfg:
            lib.mkIf containerCfg.enable {
              "containers/systemd/users/${toString userCfg.uid}/${containerName}.container" = {
                mode = "0644";
                text = mkContainerConfig containerName containerCfg;
              };
            }
          ) userCfg.containers
        ) cfg.users
      )
    );

  };
}
