# Niri/Noctalia

## Theming

Theme switching is handled by Nocatalia. When the mode is switched, Noctalia:

1. Updates its own settings.json file with colorSchemes.darkMode = true/false
2. Updates any app's theme it is controlling.
3. Runs userTemplates:
  1. Updates a file that is used to determine dark/light (uses hex of bg color
     and determines its luminance)
  2. Runs `darkman set light/dark` which acts a backend for dbus system settings
     that GTK and other apps listen on for changes.

### Current Limitations

- footserver: needs a restart, but I don't want to automate this as it would
  kill terminals that are in use.
- Noctalia overwrites some config files for apps that it controls. Zen creates
  config files that are not controlled by Nix, so that Noctalia can overwrite
  them.
- Noctalia only overwrites files when first configuring app templates.
