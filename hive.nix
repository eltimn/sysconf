{
  inputs,
  lib,
  pkgs-unstable,
  ...
}:
let
  secretsPath = builtins.toString inputs.sysconf-secrets;

  # Shared secret definitions for user passwords
  mkPasswordKeys = {
    "nelly-password" = {
      keyCommand = [
        "sops"
        "--extract"
        "[\"users\"][\"nelly\"][\"password\"]"
        "--decrypt"
        "${secretsPath}/secrets-enc.yaml"
      ];
      destDir = "/run/keys";
      user = "root";
      group = "root";
      permissions = "0400";
    };

    "nelly-git-github" = {
      keyCommand = [
        "sops"
        "--extract"
        "[\"git\"][\"github\"]"
        "--decrypt"
        "${secretsPath}/secrets-enc.yaml"
      ];
      destDir = "/run/keys";
      user = "nelly";
      group = "users";
      permissions = "0400";
    };

    "nelly-git-user" = {
      keyCommand = [
        "sops"
        "--extract"
        "[\"git\"][\"user\"]"
        "--decrypt"
        "${secretsPath}/secrets-enc.yaml"
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
      keyCommand = [
        "sops"
        "--extract"
        "[\"borg_passphrase_illmatic\"]"
        "--decrypt"
        "${secretsPath}/secrets-enc.yaml"
      ];
      destDir = "/run/keys";
      user = "root";
      group = "keys";
      permissions = "0440";
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
        targetHost = fqdn;
        targetUser = "sysconf";
        targetPort = 22;
        keys = deploymentKeys;
        tags = tags;
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
        sharedModules = [ inputs.sops-nix.homeManagerModules.sops ];
      };
    };
in
{
  ## Local hosts ##
  # cbox = colmenaConfig "cbox" [ "local" ] mkPasswordKeys;
  illmatic = colmenaConfig "illmatic" [ "local" ] illmaticKeys;

  ## Digital Ocean (DO) hosts ##
  nixos-test-01 = colmenaConfig "nixos-test-01.eltimn.com" [ "do" "digitalocean" ] mkPasswordKeys;
}
