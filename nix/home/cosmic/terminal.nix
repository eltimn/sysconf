# COSMIC Terminal Configuration
{ ... }:
{
  programs.cosmic-term = {
    enable = true;
    settings = {
      syntax_theme_light = "COSMIC Light Dark Text";
    };
    # Default profile required when using colorSchemes
    profiles = [
      {
        name = "Default";
        is_default = true;
        hold = false;
        syntax_theme_dark = "COSMIC Dark";
        syntax_theme_light = "COSMIC Light Dark Text";
      }
    ];
    # Custom color scheme for light mode with darker text
    colorSchemes = [
      {
        mode = "light";
        name = "COSMIC Light Dark Text";
        foreground = "#1B1B1B";
        bright_foreground = "#000000";
        dim_foreground = "#4C4F69";
        cursor = "#1B1B1B";
        normal = {
          black = "#5C5F77";
          red = "#D20F39";
          green = "#40A02B";
          yellow = "#DF8E1D";
          blue = "#1E66F5";
          magenta = "#EA76CB";
          cyan = "#179299";
          white = "#ACB0BE";
        };
        bright = {
          black = "#6C6F85";
          red = "#D20F39";
          green = "#40A02B";
          yellow = "#DF8E1D";
          blue = "#1E66F5";
          magenta = "#EA76CB";
          cyan = "#179299";
          white = "#BCC0CC";
        };
        dim = {
          black = "#5C5F77";
          red = "#D20F39";
          green = "#40A02B";
          yellow = "#DF8E1D";
          blue = "#1E66F5";
          magenta = "#EA76CB";
          cyan = "#179299";
          white = "#ACB0BE";
        };
      }
    ];
  };
}
