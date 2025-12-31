{ ... }:

{
  # Cinnamon desktop
  services.xserver = {
    enable = true;
    libinput.enable = true;
    displayManager.lightdm.enable = true;
    desktopManager = {
      cinnamon.enable = true;
    };
    displayManager.defaultSession = "cinnamon";
    xkb = {
      layout = "us";
      variant = "";
    };
  };
}
