# Not in use.
{
  config,
  pkgs,
  lib,
  ...
}:

let
  # 1. DEFINE PATHS
  cipherDir = config.sysconf.settings.secretCipherPath;
  mountPoint = "${config.home.homeDirectory}/secret";

  # 2. HELPER SCRIPT
  # We create a tiny script to fetch the password.
  # This prevents quoting errors inside the systemd options string.
  askPassScript = pkgs.writeShellScript "get-gocryptfs-pass" ''
    ${pkgs.libsecret}/bin/secret-tool lookup gocryptfs secret
  '';

  # 3. CALCULATE UNIT NAME
  # Systemd requires mount units to be named exactly after their path
  # e.g. /home/alice/Private -> home-alice-Private.mount
  # We use lib.strings.escapeSystemdPath to do this automatically.
  # mountUnitName = lib.strings.escapeSystemdPath mountPoint;
  mountUnitName = lib.removePrefix "-" (lib.replaceStrings [ "/" ] [ "-" ] mountPoint);
in
{
  home.packages = with pkgs; [
    gocryptfs
    libsecret
  ];

  # This section ensures the mount point directory exists and is managed by Nix.
  home.activation.createGocryptfsMountPoint = lib.hm.dag.entryAfter [ "copyQuirks" ] ''
    # Create the mount point directory if it does not exist
    mkdir -p ${mountPoint}
    # Set owner-only permissions (optional, but good practice for mount points)
    chmod 700 ${mountPoint}
  '';

  # --- The Mount Unit ---
  # Defines HOW to mount the volume
  systemd.user.mounts."${mountUnitName}" = {
    Unit = {
      Description = "Gocryptfs Mount";
      # If the keyring crashes, we want this to stop too
      # TODO: Do we, though? It should only be needed at mount time...
      PartOf = [ "gnome-keyring-daemon.service" ];
    };

    Mount = {
      What = cipherDir;
      Where = mountPoint;
      # We use fuse.gocryptfs so systemd knows which helper to call
      Type = "fuse.gocryptfs";

      # Options:
      # 1. quiet: reduce log noise
      # 2. extpass: points to our nix-generated helper script
      Options = "extpass=${askPassScript}";
    };
  };

  # --- The Automount Unit ---
  # Defines WHEN to mount (on access)
  systemd.user.automounts."${mountUnitName}" = {
    Unit = {
      Description = "Automount Gocryptfs on access";
      After = [
        "graphical-session.target"
        "gnome-keyring-daemon.service"
      ];
    };

    Automount = {
      # The directory to watch
      Where = mountPoint;
      # Unmount after 5 minutes of inactivity (optional, increases security)
      TimeoutIdleSec = "300";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}

# This is an alternative approach using a regular service that mounts
# the gocryptfs volume at login time. The downside is that the volume
# is always mounted while the user is logged in, even if not needed.
# Also, automount would delay mounting until you actually click or access the folder,
# which can sometimes solve keyring race conditions more elegantly.
# systemd.user.services = {
# 	mount-secrets = {
# 		Unit = {
# 			Description = "Mount Gocryptfs volume";
# 			# Wait for the graphical session and the keyring
# 			After = [
# 				"graphical-session.target"
# 				"gnome-keyring-daemon.service"
# 			];
# 			PartOf = [ "graphical-session.target" ];
# 		};

# 		Service = {
# 			Type = "forking";

# 			# Note: We use /run/wrappers/bin/fusermount for ExecStop because
# 			# FUSE unmounting often requires the setuid wrapper on NixOS.
# 			ExecStart = ''
# 									${pkgs.gocryptfs}/bin/gocryptfs \
# 									--extpass="${pkgs.libsecret}/bin/secret-tool lookup gocryptfs secret" \
# 									${config.home.homeDirectory}/secret-cipher \
# 									${config.home.homeDirectory}/secret
# 								'';

# 			ExecStop = "/run/wrappers/bin/fusermount -u ${config.home.homeDirectory}/secrets";

# 			Restart = "on-failure";
# 			RestartSec = "5s";
# 		};

# 		Install = {
# 			WantedBy = [ "graphical-session.target" ];
# 		};
# 	};
# };
