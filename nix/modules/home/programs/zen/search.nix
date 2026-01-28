{ pkgs, ... }:
{
  force = true;
  default = "ddg";
  engines =
    let
      nixSnowflakeIcon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
    in
    {
      "Nix Packages" = {
        urls = [
          {
            template = "https://search.nixos.org/packages";
            params = [
              {
                name = "type";
                value = "packages";
              }
              {
                name = "channel";
                value = "unstable";
              }
              {
                name = "query";
                value = "{searchTerms}";
              }
            ];
          }
        ];
        icon = nixSnowflakeIcon;
        definedAliases = [ "p" ];
      };

      "Nix Options" = {
        urls = [
          {
            template = "https://search.nixos.org/options";
            params = [
              {
                name = "channel";
                value = "unstable";
              }
              {
                name = "query";
                value = "{searchTerms}";
              }
            ];
          }
        ];
        icon = nixSnowflakeIcon;
        definedAliases = [ "o" ];
      };

      "Home Manager Options" = {
        urls = [
          {
            template = "https://home-manager-options.extranix.com/";
            params = [
              {
                name = "query";
                value = "{searchTerms}";
              }
              {
                name = "release";
                value = "master";
              }
            ];
          }
        ];
        icon = nixSnowflakeIcon;
        definedAliases = [ "hm" ];
      };

      "Cosmic Manager Options" = {
        urls = [
          {
            template = "https://heitoraugustoln.github.io/cosmic-manager/options/index.html";
            params = [
              {
                name = "search";
                value = "{searchTerms}";
              }
            ];
          }
        ];
        icon = nixSnowflakeIcon;
        definedAliases = [ "cm" ];
      };

      "NUR" = {
        urls = [
          {
            template = "https://nur.nix-community.org/";
            params = [
              {
                name = "query";
                value = "{searchTerms}";
              }
            ];
          }
        ];
        icon = nixSnowflakeIcon;
        definedAliases = [ "nur" ];
      };

      "Firefox Addons" = {
        urls = [
          {
            template = "https://nur.nix-community.org/repos/rycee/";
            params = [
              {
                name = "query";
                value = "{searchTerms}";
              }
            ];
          }
        ];
        icon = nixSnowflakeIcon;
        definedAliases = [ "ffa" ];
      };

      "Google Maps" = {
        urls = [
          {
            template = "https://maps.google.com";
            params = [
              {
                name = "q";
                value = "{searchTerms}";
              }
            ];
          }
        ];
        definedAliases = [
          "maps"
          "gmaps"
        ];
      };

      "ddg" = {
        urls = [
          {
            template = "https://duckduckgo.com";
            params = [
              {
                name = "q";
                value = "{searchTerms}";
              }
              {
                name = "origin";
                value = "unknown";
              }
            ];
          }
        ];
        definedAliases = [
          "duck"
          "ddg"
          "dck"
          "dckk"
        ];
      };

      "StartPage" = {
        urls = [
          {
            template = "https://www.startpage.com/sp/search";
            params = [
              {
                name = "q";
                value = "{searchTerms}";
              }
            ];
          }
        ];
        definedAliases = [
          "startpage"
          "sp"
          "pp"
        ];
        icon = "https://www.startpage.com/sp/cdn/favicons/favicon-gradient.ico";
        updateInterval = 24 * 60 * 60 * 1000;
      };

      bing.metaData.hidden = "true";
    };
}
