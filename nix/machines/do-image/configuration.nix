{
  pkgs,
  lib,
  modulesPath,
  ...
}:
let
  nellySshKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILKlXvCa8D1VqasrHkgsnajPhaUA5N2pJ0b9OASPqYij nelly@lappy"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGXS57Mn5Hsbkyv/byapcmgEVkRKqEnudWaCSDmpkRdb nelly@ruca"
  ];
in
{
  imports = [
    "${modulesPath}/virtualisation/digital-ocean-image.nix"
  ];

  # Temporary hostname for image
  networking.hostName = lib.mkForce "nixos-do";
  networking.hostId = "8425e349";

  # Enable flakes and nix-command for deployment
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.settings.trusted-users = [
    "root"
    "sysconf"
  ];

  # Create sysconf deployment user
  users.users.sysconf = {
    isSystemUser = true;
    group = "wheel";
    home = "/var/lib/sysconf";
    createHome = true;
    shell = pkgs.bash;
    openssh.authorizedKeys.keys = nellySshKeys;
  };

  # Primary user account
  users.users.nelly = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.bash;
    openssh.authorizedKeys.keys = nellySshKeys;
  };

  # Allow passwordless sudo for wheel (NixOps req)
  security.sudo.wheelNeedsPassword = false;

  # SSH configuration
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  # Minimal packages for remote management
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    htop
    # zfs
    curl
  ];

  # Enable ZFS support
  # boot.supportedFilesystems = [ "zfs" ];
  # boot.zfs.forceImportRoot = false;

  # Minimal firewall
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];

  system.stateVersion = "25.11";
}
