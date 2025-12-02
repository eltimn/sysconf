{
  config,
  lib,
  inputs,
  ...
}:
let
  cfg = config.eltimn.system.sops;
in
{
  options.eltimn.system.sops = {
    secretsPath = lib.mkOption {
      type = lib.types.path;
      default = ../../secrets;
      description = "The path secrets files are in.";
    };
  };

  imports = [ inputs.sops-nix.nixosModules.sops ];

  config = {
    # SOPS
    sops = {
      age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      defaultSopsFile = "${cfg.secretsPath}/secrets-enc.yaml";
      defaultSopsFormat = "yaml";
    };
  };
}
