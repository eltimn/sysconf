# COSMIC Desktop Light Theme Configuration (Aether Light)
{ config, ... }:
let
  mkRaw = config.lib.cosmic.mkRON "raw";
in
{
  wayland.desktopManager.cosmic.appearance.theme.light = {
    # Background color
    bg_color = config.lib.cosmic.mkRON "optional" {
      red = mkRaw "0.9607843";
      green = mkRaw "0.96862745";
      blue = mkRaw "0.98039216";
      alpha = mkRaw "1.0";
    };
    # Primary container background (white)
    primary_container_bg = config.lib.cosmic.mkRON "optional" {
      red = mkRaw "1.0";
      green = mkRaw "1.0";
      blue = mkRaw "1.0";
      alpha = mkRaw "1.0";
    };
    # Text tint
    text_tint = config.lib.cosmic.mkRON "optional" {
      red = mkRaw "0.16259864";
      green = mkRaw "0.16259852";
      blue = mkRaw "0.16259855";
    };
    # Neutral tint
    neutral_tint = config.lib.cosmic.mkRON "optional" {
      red = mkRaw "0.37644076";
      green = mkRaw "0.38999572";
      blue = mkRaw "0.41031522";
    };
    # Accent color (blue)
    accent = config.lib.cosmic.mkRON "optional" {
      red = mkRaw "0.0";
      green = mkRaw "0.22745104";
      blue = mkRaw "0.6";
    };
    # Success color
    success = config.lib.cosmic.mkRON "optional" {
      red = mkRaw "0.09411765";
      green = mkRaw "0.33333334";
      blue = mkRaw "0.16078432";
    };
    # Warning color
    warning = config.lib.cosmic.mkRON "optional" {
      red = mkRaw "0.3254902";
      green = mkRaw "0.28235295";
      blue = mkRaw "0.0";
    };
    # Destructive color
    destructive = config.lib.cosmic.mkRON "optional" {
      red = mkRaw "0.47058824";
      green = mkRaw "0.16078432";
      blue = mkRaw "0.18039216";
    };
    # Corner radii
    corner_radii = {
      radius_0 = config.lib.cosmic.mkRON "tuple" [ 0.0 0.0 0.0 0.0 ];
      radius_xs = config.lib.cosmic.mkRON "tuple" [ 2.0 2.0 2.0 2.0 ];
      radius_s = config.lib.cosmic.mkRON "tuple" [ 8.0 8.0 8.0 8.0 ];
      radius_m = config.lib.cosmic.mkRON "tuple" [ 8.0 8.0 8.0 8.0 ];
      radius_l = config.lib.cosmic.mkRON "tuple" [ 8.0 8.0 8.0 8.0 ];
      radius_xl = config.lib.cosmic.mkRON "tuple" [ 8.0 8.0 8.0 8.0 ];
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
    gaps = config.lib.cosmic.mkRON "tuple" [ 0 8 ];
    active_hint = 3;
    is_frosted = false;
    # Secondary container and window hint (None in Aether Light)
    secondary_container_bg = config.lib.cosmic.mkRON "optional" null;
    window_hint = config.lib.cosmic.mkRON "optional" null;
    # Palette
    palette = config.lib.cosmic.mkRON "enum" {
      variant = "Light";
      value = [
        {
          name = "cosmic-light";
          neutral_0 = {
            red = mkRaw "1.0";
            green = mkRaw "1.0";
            blue = mkRaw "1.0";
            alpha = mkRaw "1.0";
          };
          neutral_1 = {
            red = mkRaw "0.8862745";
            green = mkRaw "0.8862745";
            blue = mkRaw "0.8862745";
            alpha = mkRaw "1.0";
          };
          neutral_2 = {
            red = mkRaw "0.7764706";
            green = mkRaw "0.7764706";
            blue = mkRaw "0.7764706";
            alpha = mkRaw "1.0";
          };
          neutral_3 = {
            red = mkRaw "0.67058825";
            green = mkRaw "0.67058825";
            blue = mkRaw "0.67058825";
            alpha = mkRaw "1.0";
          };
          neutral_4 = {
            red = mkRaw "0.5686275";
            green = mkRaw "0.5686275";
            blue = mkRaw "0.5686275";
            alpha = mkRaw "1.0";
          };
          neutral_5 = {
            red = mkRaw "0.46666667";
            green = mkRaw "0.46666667";
            blue = mkRaw "0.46666667";
            alpha = mkRaw "1.0";
          };
          neutral_6 = {
            red = mkRaw "0.36862746";
            green = mkRaw "0.36862746";
            blue = mkRaw "0.36862746";
            alpha = mkRaw "1.0";
          };
          neutral_7 = {
            red = mkRaw "0.2784314";
            green = mkRaw "0.2784314";
            blue = mkRaw "0.2784314";
            alpha = mkRaw "1.0";
          };
          neutral_8 = {
            red = mkRaw "0.1882353";
            green = mkRaw "0.1882353";
            blue = mkRaw "0.1882353";
            alpha = mkRaw "1.0";
          };
          neutral_9 = {
            red = mkRaw "0.105882354";
            green = mkRaw "0.105882354";
            blue = mkRaw "0.105882354";
            alpha = mkRaw "1.0";
          };
          neutral_10 = {
            red = mkRaw "0.0";
            green = mkRaw "0.0";
            blue = mkRaw "0.0";
            alpha = mkRaw "1.0";
          };
          gray_1 = {
            red = mkRaw "0.8666667";
            green = mkRaw "0.8666667";
            blue = mkRaw "0.8666667";
            alpha = mkRaw "1.0";
          };
          gray_2 = {
            red = mkRaw "0.9098039";
            green = mkRaw "0.9098039";
            blue = mkRaw "0.9098039";
            alpha = mkRaw "1.0";
          };
          accent_blue = {
            red = mkRaw "0.0";
            green = mkRaw "0.32156864";
            blue = mkRaw "0.3529412";
            alpha = mkRaw "1.0";
          };
          accent_indigo = {
            red = mkRaw "0.18039216";
            green = mkRaw "0.28627452";
            blue = mkRaw "0.42745098";
            alpha = mkRaw "1.0";
          };
          accent_purple = {
            red = mkRaw "0.40784314";
            green = mkRaw "0.12941177";
            blue = mkRaw "0.4862745";
            alpha = mkRaw "1.0";
          };
          accent_pink = {
            red = mkRaw "0.5254902";
            green = mkRaw "0.015686275";
            blue = mkRaw "0.22745098";
            alpha = mkRaw "1.0";
          };
          accent_red = {
            red = mkRaw "0.47058824";
            green = mkRaw "0.16078432";
            blue = mkRaw "0.18039216";
            alpha = mkRaw "1.0";
          };
          accent_orange = {
            red = mkRaw "0.38431373";
            green = mkRaw "0.2509804";
            blue = mkRaw "0.0";
            alpha = mkRaw "1.0";
          };
          accent_yellow = {
            red = mkRaw "0.3254902";
            green = mkRaw "0.28235295";
            blue = mkRaw "0.0";
            alpha = mkRaw "1.0";
          };
          accent_green = {
            red = mkRaw "0.09411765";
            green = mkRaw "0.33333334";
            blue = mkRaw "0.16078432";
            alpha = mkRaw "1.0";
          };
          accent_warm_grey = {
            red = mkRaw "0.33333334";
            green = mkRaw "0.2784314";
            blue = mkRaw "0.25882354";
            alpha = mkRaw "1.0";
          };
          bright_red = {
            red = mkRaw "0.5372549";
            green = mkRaw "0.015686275";
            blue = mkRaw "0.09411765";
            alpha = mkRaw "1.0";
          };
          bright_green = {
            red = mkRaw "0.0";
            green = mkRaw "0.34117648";
            blue = mkRaw "0.17254902";
            alpha = mkRaw "1.0";
          };
          bright_orange = {
            red = mkRaw "0.4745098";
            green = mkRaw "0.17254902";
            blue = mkRaw "0.0";
            alpha = mkRaw "1.0";
          };
          ext_warm_grey = {
            red = mkRaw "0.60784316";
            green = mkRaw "0.5568628";
            blue = mkRaw "0.5411765";
            alpha = mkRaw "1.0";
          };
          ext_orange = {
            red = mkRaw "0.9843137";
            green = mkRaw "0.72156864";
            blue = mkRaw "0.42352942";
            alpha = mkRaw "1.0";
          };
          ext_yellow = {
            red = mkRaw "0.96862745";
            green = mkRaw "0.8784314";
            blue = mkRaw "0.38431373";
            alpha = mkRaw "1.0";
          };
          ext_blue = {
            red = mkRaw "0.41568628";
            green = mkRaw "0.7921569";
            blue = mkRaw "0.84705883";
            alpha = mkRaw "1.0";
          };
          ext_purple = {
            red = mkRaw "0.8352941";
            green = mkRaw "0.54901963";
            blue = mkRaw "1.0";
            alpha = mkRaw "1.0";
          };
          ext_pink = {
            red = mkRaw "1.0";
            green = mkRaw "0.6117647";
            blue = mkRaw "0.8666667";
            alpha = mkRaw "1.0";
          };
          ext_indigo = {
            red = mkRaw "0.58431375";
            green = mkRaw "0.76862746";
            blue = mkRaw "0.9882353";
            alpha = mkRaw "1.0";
          };
        }
      ];
    };
  };
}
