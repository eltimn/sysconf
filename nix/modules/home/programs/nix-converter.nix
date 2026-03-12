{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sysconf.programs.nixConverter;

  json2nixClipboardScript = pkgs.writeShellApplication {
    name = "json2nix-clipboard";
    runtimeInputs = [
      pkgs.nix-converter
      pkgs.jq
      pkgs.perl
    ];
    text = ''
      # Convert clipboard contents (JSON/YAML/JSONC) to Nix

      get_clipboard() {
        if command -v wl-paste &> /dev/null && [ -n "''${WAYLAND_DISPLAY:-}" ]; then
          wl-paste
        elif command -v xclip &> /dev/null && [ -n "''${DISPLAY:-}" ]; then
          xclip -selection clipboard -o
        elif command -v pbpaste &> /dev/null; then
          pbpaste
        elif command -v xsel &> /dev/null; then
          xsel --clipboard --output
        else
          echo "Error: No clipboard tool found" >&2
          exit 1
        fi
      }

      set_clipboard() {
        if command -v wl-copy &> /dev/null && [ -n "''${WAYLAND_DISPLAY:-}" ]; then
          wl-copy
        elif command -v xclip &> /dev/null && [ -n "''${DISPLAY:-}" ]; then
          xclip -selection clipboard
        elif command -v pbcopy &> /dev/null; then
          pbcopy
        elif command -v xsel &> /dev/null; then
          xsel --clipboard --input
        else
          echo "Error: No clipboard tool found" >&2
          exit 1
        fi
      }

      strip_jsonc_comments() {
        local content="$1"
        perl -0777 -pe 's/\/\/[^\n]*//g; s/\/\*[\s\S]*?\*\///g' <<< "$content"
      }

      tmpfile=$(mktemp)
      trap 'rm -f "$tmpfile"' EXIT

      # Get clipboard content
      get_clipboard > "$tmpfile"

      if [ ! -s "$tmpfile" ]; then
        echo "Error: Clipboard is empty" >&2
        exit 1
      fi

      content=$(cat "$tmpfile")

      # Determine format
      format=""

      # Test 1: Is it valid JSON?
      if echo "$content" | jq empty 2>/dev/null; then
        format="json"
      else
        # Test 2: Is it JSONC (comments)?
        stripped=$(strip_jsonc_comments "$content")

        if echo "$stripped" | jq empty 2>/dev/null; then
          format="json"
          echo "$stripped" > "$tmpfile"
        else
          # Test 3: Is it partial JSON (object contents without braces)?
          first_char=$(echo "$content" | head -c 1 | tr -d '[:space:]')

          if [ "$first_char" != "{" ] && [ "$first_char" != "[" ]; then
            # Strip trailing comma and wrap with {}
            cleaned=$(echo "$content" | perl -0777 -pe 's/,\s*\z//')
            wrapped_content="{$cleaned}"
            wrapped_stripped=$(strip_jsonc_comments "$wrapped_content")

            if echo "$wrapped_stripped" | jq empty 2>/dev/null; then
              format="json"
              echo "$wrapped_stripped" > "$tmpfile"
            else
              format="yaml"
            fi
          else
            format="yaml"
          fi
        fi
      fi

      # Convert
      converted=$(nix-converter -f "$tmpfile" -l "$format" 2>&1)

      if [ -z "$converted" ]; then
        echo "Error: Conversion failed" >&2
        exit 1
      fi

      echo "$converted" | set_clipboard
      echo "Converted to Nix (clipboard updated)"
    '';
  };
in
{
  options.sysconf.programs.nixConverter = {
    enable = lib.mkEnableOption "nix-converter - convert clipboard JSON/YAML to Nix";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.nix-converter
      json2nixClipboardScript
    ];
  };
}
