{ pkgs, ... }:
{
  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  environment.systemPackages = with pkgs; [
    # pipewire policy tool
    wireplumber
  ];

  # WirePlumber configuration to pin Yamaha S/PDIF and disable Monitor Audio
  environment.etc = {
    "wireplumber/wireplumber.conf.d/51-disable-monitor-audio.conf".text = ''
      monitor.alsa.rules = [
        {
          matches = [
            {
              node.name = "~.*HDMI.*"
            }
            {
              node.description = "~.*HDMI.*"
            }
          ]
          actions = {
            update-props = {
              node.disabled = true
            }
          }
        }
        {
          matches = [
            {
              node.name = "alsa_output.usb-YAMAHA_Yamaha_A-U670_A-U671-00.iec958-stereo"
            }
            {
              node.description = "~.*Yamaha.*"
            }
          ]
          actions = {
            update-props = {
              priority.driver = 1500
              priority.session = 1500
            }
          }
        }
      ]
    '';
  };
}
