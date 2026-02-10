{
  inputs,
  lib,
  pkgs-unstable,
  ...
}:
let
  secretsPath = builtins.toString inputs.sysconf-secrets;

  mkKeyCommand = pathSegments: [
    "sops"
    "--extract"
    (lib.concatStrings (map (s: ''["${s}"]'') pathSegments))
    "--decrypt"
    "${secretsPath}/secrets-enc.yaml"
  ];

  # Shared secret definitions for user passwords
  mkPasswordKeys = {
    "nelly-password" = {
      keyCommand = mkKeyCommand [
        "users"
        "nelly"
        "password"
      ];
      destDir = "/run/keys";
      user = "root";
      group = "root";
      permissions = "0400";
    };

    "nelly-git-github" = {
      keyCommand = mkKeyCommand [
        "git"
        "github"
      ];
      destDir = "/run/keys";
      user = "nelly";
      group = "users";
      permissions = "0400";
    };

    "nelly-git-user" = {
      keyCommand = mkKeyCommand [
        "git"
        "user"
      ];
      destDir = "/run/keys";
      user = "nelly";
      group = "users";
      permissions = "0400";
    };
  };

  illmaticKeys = mkPasswordKeys // {
    # Caddy needs Cloudflare credentials
    "caddy-env" = {
      keyCommand = [
        "sops"
        "--decrypt"
        "${secretsPath}/caddy-enc.env"
      ];
      destDir = "/run/keys";
      user = "caddy";
      group = "caddy";
      permissions = "0400";
    };
    # Borg needs a password
    "borg-passphrase-illmatic" = {
      keyCommand = mkKeyCommand [ "borg_passphrase_illmatic" ];
      destDir = "/run/keys";
      user = "root";
      group = "keys";
      permissions = "0440";
    };
    "pocketid-encryption-key" = {
      keyCommand = mkKeyCommand [
        "pocketid"
        "encryption_key"
      ];
      destDir = "/run/keys";
      user = "pocket-id";
      group = "keys";
      permissions = "0440";
    };
    "filen-cli-auth-config" = {
      keyCommand = mkKeyCommand [
        "filen"
        "auth_config"
      ];
      destDir = "/run/keys";
      user = "nelly";
      group = "users";
      permissions = "0400";
    };
    "gocryptfs-services" = {
      keyCommand = mkKeyCommand [
        "gocryptfs"
        "services"
      ];
      destDir = "/run/keys";
      user = "root";
      group = "root";
      permissions = "0400";
    };
    "zfs-encryption-private" = {
      keyCommand = mkKeyCommand [
        "zfs_encryption"
        "private"
      ];
      destDir = "/run/keys";
      user = "root";
      group = "root";
      permissions = "0400";
    };
    "searxng-env" = {
      keyCommand = mkKeyCommand [ "searxng_env" ];
      destDir = "/run/keys";
      user = "root";
      group = "root";
      permissions = "0400";
    };
  };

  # a function to create a colmena configuration
  colmenaConfig =
    fqdn: tags: deploymentKeys:
    let
      hostName = builtins.head (lib.strings.splitString "." fqdn);
    in
    {

      deployment = {
        inherit tags;
        targetHost = fqdn;
        targetUser = "sysconf";
        targetPort = 22;
        keys = deploymentKeys;
      };

      imports = [
        {
          networking.hostName = hostName;
        }
        inputs.disko.nixosModules.disko
        ./nix/machines/${hostName}/configuration.nix
        ./nix/modules/system
        inputs.home-manager.nixosModules.home-manager
      ];

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users.nelly = {
          imports = [
            ./nix/machines/${hostName}/home-nelly.nix
            ./nix/modules/home # home manager modules
          ];
        };
        extraSpecialArgs = { inherit pkgs-unstable; };
        sharedModules = [
          inputs.sops-nix.homeManagerModules.sops
          inputs.zen-browser-flake.homeModules.default
        ];
      };
    };
in
{
  ## Local hosts ##
  cbox = colmenaConfig "cbox" [ "local" "cbox" "dns" ] mkPasswordKeys;
  illmatic = colmenaConfig "illmatic" [ "local" "illmatic" "dns" ] illmaticKeys;

  ## Digital Ocean (DO) hosts ##
  # nixos-test-01 = colmenaConfig "nixos-test-01.eltimn.com" [ "do" "digitalocean" ] mkPasswordKeys;
}
