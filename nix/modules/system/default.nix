# This is included on every host
{ pkgs, ... }:
{
  imports = [
    ./containers
    ./services
    ./sops.nix
  ];

  environment.systemPackages = with pkgs; [
    age
    bat
    btop
    dnsutils
    ghostty.terminfo
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
}
