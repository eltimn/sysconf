# COSMIC Desktop Dark Theme Configuration
{ config, ... }:
let
  mkRaw = config.lib.cosmic.mkRON "raw";
in
{
  wayland.desktopManager.cosmic.appearance.theme.dark = {
    # Text tint (light for dark theme)
    text_tint = config.lib.cosmic.mkRON "optional" {
      red = mkRaw "0.9254902";
      green = mkRaw "0.9372549";
      blue = mkRaw "0.95686275";
    };
    # Accent color (muted blue)
    accent = config.lib.cosmic.mkRON "optional" {
      red = mkRaw "0.18";
      green = mkRaw "0.35";
      blue = mkRaw "0.55";
    };
    # Success color (green)
    success = config.lib.cosmic.mkRON "optional" {
      red = mkRaw "0.57254905";
      green = mkRaw "0.8117647";
      blue = mkRaw "0.6117647";
    };
    # Warning color (yellow)
    warning = config.lib.cosmic.mkRON "optional" {
      red = mkRaw "0.96862745";
      green = mkRaw "0.8784314";
      blue = mkRaw "0.38431373";
    };
    # Destructive color (red/pink)
    destructive = config.lib.cosmic.mkRON "optional" {
      red = mkRaw "0.99215686";
      green = mkRaw "0.6313726";
      blue = mkRaw "0.627451";
    };
    # Corner radii
    corner_radii = {
      radius_0 = config.lib.cosmic.mkRON "tuple" [
        0.0
        0.0
        0.0
        0.0
      ];
      radius_xs = config.lib.cosmic.mkRON "tuple" [
        2.0
        2.0
        2.0
        2.0
      ];
      radius_s = config.lib.cosmic.mkRON "tuple" [
        8.0
        8.0
        8.0
        8.0
      ];
      radius_m = config.lib.cosmic.mkRON "tuple" [
        8.0
        8.0
        8.0
        8.0
      ];
      radius_l = config.lib.cosmic.mkRON "tuple" [
        8.0
        8.0
        8.0
        8.0
      ];
      radius_xl = config.lib.cosmic.mkRON "tuple" [
        8.0
        8.0
        8.0
        8.0
      ];
    };
    # Spacing
    spacing = {
      space_none = 0;
      space_xxxs = 4;
      space_xxs = 8;
      space_xs = 12;
      space_s = 16;
      space_m = 24;
      space_l = 32;
      space_xl = 48;
      space_xxl = 64;
      space_xxxl = 128;
    };
    # Gaps and hints
    gaps = config.lib.cosmic.mkRON "tuple" [
      0
      8
    ];
    active_hint = 3;
    is_frosted = false;
    # Window hint defaults to accent color if not set
    window_hint = config.lib.cosmic.mkRON "optional" null;
    # Secondary container (None)
    secondary_container_bg = config.lib.cosmic.mkRON "optional" null;
    # Palette
    palette = config.lib.cosmic.mkRON "enum" {
      variant = "Dark";
      value = [
        {
          name = "cosmic-dark";
          neutral_0 = {
            red = mkRaw "0.0";
            green = mkRaw "0.0";
            blue = mkRaw "0.0";
            alpha = mkRaw "1.0";
          };
          neutral_1 = {
            red = mkRaw "0.105882354";
            green = mkRaw "0.105882354";
            blue = mkRaw "0.105882354";
            alpha = mkRaw "1.0";
          };
          neutral_2 = {
            red = mkRaw "0.1882353";
            green = mkRaw "0.1882353";
            blue = mkRaw "0.1882353";
            alpha = mkRaw "1.0";
          };
          neutral_3 = {
            red = mkRaw "0.2784314";
            green = mkRaw "0.2784314";
            blue = mkRaw "0.2784314";
            alpha = mkRaw "1.0";
          };
          neutral_4 = {
            red = mkRaw "0.36862746";
            green = mkRaw "0.36862746";
            blue = mkRaw "0.36862746";
            alpha = mkRaw "1.0";
          };
          neutral_5 = {
            red = mkRaw "0.46666667";
            green = mkRaw "0.46666667";
            blue = mkRaw "0.46666667";
            alpha = mkRaw "1.0";
          };
          neutral_6 = {
            red = mkRaw "0.5686275";
            green = mkRaw "0.5686275";
            blue = mkRaw "0.5686275";
            alpha = mkRaw "1.0";
          };
          neutral_7 = {
            red = mkRaw "0.67058825";
            green = mkRaw "0.67058825";
            blue = mkRaw "0.67058825";
            alpha = mkRaw "1.0";
          };
          neutral_8 = {
            red = mkRaw "0.7764706";
            green = mkRaw "0.7764706";
            blue = mkRaw "0.7764706";
            alpha = mkRaw "1.0";
          };
          neutral_9 = {
            red = mkRaw "0.8862745";
            green = mkRaw "0.8862745";
            blue = mkRaw "0.8862745";
            alpha = mkRaw "1.0";
          };
          neutral_10 = {
            red = mkRaw "1.0";
            green = mkRaw "1.0";
            blue = mkRaw "1.0";
            alpha = mkRaw "1.0";
          };
          gray_1 = {
            red = mkRaw "0.105882354";
            green = mkRaw "0.105882354";
            blue = mkRaw "0.105882354";
            alpha = mkRaw "1.0";
          };
          gray_2 = {
            red = mkRaw "0.14901961";
            green = mkRaw "0.14901961";
            blue = mkRaw "0.14901961";
            alpha = mkRaw "1.0";
          };
          accent_blue = {
            red = mkRaw "0.3882353";
            green = mkRaw "0.8156863";
            blue = mkRaw "0.8745098";
            alpha = mkRaw "1.0";
          };
          accent_indigo = {
            red = mkRaw "0.6313726";
            green = mkRaw "0.7529412";
            blue = mkRaw "0.92156863";
            alpha = mkRaw "1.0";
          };
          accent_purple = {
            red = mkRaw "0.90588236";
            green = mkRaw "0.6117647";
            blue = mkRaw "0.99607843";
            alpha = mkRaw "1.0";
          };
          accent_pink = {
            red = mkRaw "1.0";
            green = mkRaw "0.6117647";
            blue = mkRaw "0.69411767";
            alpha = mkRaw "1.0";
          };
          accent_red = {
            red = mkRaw "0.99215686";
            green = mkRaw "0.6313726";
            blue = mkRaw "0.627451";
            alpha = mkRaw "1.0";
          };
          accent_orange = {
            red = mkRaw "1.0";
            green = mkRaw "0.6784314";
            blue = mkRaw "0.0";
            alpha = mkRaw "1.0";
          };
          accent_yellow = {
            red = mkRaw "0.96862745";
            green = mkRaw "0.8784314";
            blue = mkRaw "0.38431373";
            alpha = mkRaw "1.0";
          };
          accent_green = {
            red = mkRaw "0.57254905";
            green = mkRaw "0.8117647";
            blue = mkRaw "0.6117647";
            alpha = mkRaw "1.0";
          };
          accent_warm_grey = {
            red = mkRaw "0.7921569";
            green = mkRaw "0.7294118";
            blue = mkRaw "0.7058824";
            alpha = mkRaw "1.0";
          };
          bright_red = {
            red = mkRaw "1.0";
            green = mkRaw "0.627451";
            blue = mkRaw "0.5647059";
            alpha = mkRaw "1.0";
          };
          bright_green = {
            red = mkRaw "0.36862746";
            green = mkRaw "0.85882354";
            blue = mkRaw "0.54901963";
            alpha = mkRaw "1.0";
          };
          bright_orange = {
            red = mkRaw "1.0";
            green = mkRaw "0.6392157";
            blue = mkRaw "0.49019608";
            alpha = mkRaw "1.0";
          };
          ext_warm_grey = {
            red = mkRaw "0.60784316";
            green = mkRaw "0.5568628";
            blue = mkRaw "0.5411765";
            alpha = mkRaw "1.0";
          };
          ext_orange = {
            red = mkRaw "1.0";
            green = mkRaw "0.6784314";
            blue = mkRaw "0.0";
            alpha = mkRaw "1.0";
          };
          ext_yellow = {
            red = mkRaw "0.99607843";
            green = mkRaw "0.85882354";
            blue = mkRaw "0.2509804";
            alpha = mkRaw "1.0";
          };
          ext_blue = {
            red = mkRaw "0.28235295";
            green = mkRaw "0.7254902";
            blue = mkRaw "0.78039217";
            alpha = mkRaw "1.0";
          };
          ext_purple = {
            red = mkRaw "0.8117647";
            green = mkRaw "0.49019608";
            blue = mkRaw "1.0";
            alpha = mkRaw "1.0";
          };
          ext_pink = {
            red = mkRaw "0.9764706";
            green = mkRaw "0.22745098";
            blue = mkRaw "0.5137255";
            alpha = mkRaw "1.0";
          };
          ext_indigo = {
            red = mkRaw "0.24313726";
            green = mkRaw "0.53333336";
            blue = mkRaw "1.0";
            alpha = mkRaw "1.0";
          };
        }
      ];
    };
  };
}
