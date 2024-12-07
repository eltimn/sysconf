# This error occurs
# 08:24:56.038  ERROR  wezterm_gui::frontend > Failed to create window: with_egl_lib failed: with_egl_lib(libEGL.so.1) failed: egl GetDisplay: Failed but with error code: SUCCESS, libEGL.so: libEGL.so: cannot open shared object file: No such file or directory, with_egl_lib(libEGL.so.1) failed: egl GetDisplay: Failed but with error code: SUCCESS, libEGL.so: libEGL.so: cannot open shared object file: No such file or directory

{
  programs.wezterm = {
    enable = true;
    enableZshIntegration = true;
    # extraConfig = {
    # };
  };
}
