{ pkgs, ... }:

{
  # ROCm (Radeon Open Compute) configuration module
  # This module is currently unused but kept for future reference
  # Contains all ROCm-related packages and settings
  #
  # To use this module in the future, import it in your system configuration:
  # imports = [ ./system/rocm.nix ];

  # ROCm packages for GPU acceleration
  environment.systemPackages = with pkgs; [
    rocmPackages.clr.icd
    rocmPackages.rocm-smi
    rocmPackages.rocminfo
  ];

  # Hardware graphics configuration for ROCm
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = [
      pkgs.rocmPackages.clr.icd
    ];
  };

  # GNOME video driver configuration for AMD GPUs
  # This is kept separate as it's GPU-specific, not ROCm-specific
  # eltimn.system.gnome.videoDrivers = [ "amdgpu" ];
}
