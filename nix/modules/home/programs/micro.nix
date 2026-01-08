{
  config,
  lib,
  ...
}:

with lib;

let
  cfg = config.sysconf.programs.micro;
in
{
  options.sysconf.programs.micro = {
    enable = mkEnableOption "micro text editor with custom configuration";
  };

  config = mkIf cfg.enable {
    programs.micro = {
      enable = true;
      settings = {
        # Theme and appearance
        colorscheme = "bubblegum";
        cursorline = true; # Highlight the current line
        ruler = true; # Show line numbers
        scrollbar = true; # Show scrollbar

        # Editor behavior
        autoindent = true;
        tabsize = 2;
        tabstospaces = true; # Use spaces instead of tabs
        softwrap = false; # Don't wrap long lines
        smartpaste = true;

        # Search
        ignorecase = true;
        incsearch = true;
        hlsearch = true; # Highlight search results

        # Quality of life
        savecursor = true; # Remember cursor position
        saveundo = true; # Remember undo history
        clipboard = "terminal"; # Use terminal clipboard (works over SSH)
        mouse = true;
        mkparents = true; # Auto-create parent directories when saving

        # Visual guides
        colorcolumn = 0; # Set to 80 or 120 if you want a guide column
        rmtrailingws = true; # Remove trailing whitespace on save

        # Status line
        statusline = true;
        statusformatl = "$(filename) $(modified)($(line),$(col)) | ft:$(opt:filetype)";
        statusformatr = "$(bind:ToggleKeyMenu): help";
      };
    };

    # Custom keybindings
    home.file.".config/micro/bindings.json".text = builtins.toJSON {
      # VS Code-style Ctrl+D to select next occurrence (multi-cursor)
      "Ctrl-d" = "SpawnMultiCursor"; # default: "Duplicate|DuplicateLine"
      # Default
      "Alt-/" = "lua:comment.comment";
      "CtrlUnderscore" = "lua:comment.comment";
    };
  };
}
