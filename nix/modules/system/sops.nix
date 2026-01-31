{
  config,
  lib,
  inputs,
  ...
}:
{
  options.sysconf.system.sops = {
    secretsPath = lib.mkOption {
      type = lib.types.path;
      default = builtins.toString inputs.sysconf-secrets;
      description = "The path secrets files are in.";
    };
  };

  imports = [ inputs.sops-nix.nixosModules.sops ];

  config = {
    # SOPS
    sops = {
      age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      defaultSopsFile = "${config.sysconf.system.sops.secretsPath}/secrets-enc.yaml";
      defaultSopsFormat = "yaml";
    };
  };
}
