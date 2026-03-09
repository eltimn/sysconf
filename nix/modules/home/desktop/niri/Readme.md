# Niri

## Theming

For DMS and Waybar, Niri uses a custom theme mode switcher using darkman. Each
app has its own themes and switches between them. For Waybar, its theme can be
updated via a `themeHandler` like the rest of the apps. For DMS, it is currently
not automated and stays in dark mode.

For Nocatalia, it uses its internal theme switcher. See Readme for Noctalia for
more details.

## Niri Services

These are services that are not provided by Waybar or Noctalia. DMS handles them
itself.

They are:

- swayidle - Idle management (screensaver, lock screen, etc.)
- mako - Notification daemon
- polkit - Authentication agent

## Screencasting w/ wf-recorder

wf-recorder usage examples:

```shell
wf-recorder -f output.mp4                    # Full screen
wf-recorder -g "$(slurp)" -f output.mp4      # Select region
wf-recorder -o HDMI-A-1 -f output.mp4        # Specific monitor
```

Key options:

- -a - Record audio (microphone)
- --audio=<device> - Record specific audio device
- -c <codec> - Use specific codec (libx264, libvpx, etc.)
- -r 30 - Set framerate

## Resources

- [Niri regex](https://docs.rs/regex/latest/regex/#syntax)
