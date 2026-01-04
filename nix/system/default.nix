{ pkgs, ... }:
{
  imports = [
    ./containers
    ./services
    ./sops.nix
  ];

  environment.systemPackages = with pkgs; [
    s3cmd
  ];
}
