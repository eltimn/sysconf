{
  home = {
    # List of files to be symlinked into the user home directory.
    file.".abcde.conf".source = ./files/.abcde.conf;
    file.".ackrc".source = ./files/.ackrc;
    file.".ansible.cfg".source = ./files/.ansible.cfg;
    file.".gitignore".source = ./files/.gitignore;
    file.".mongoshrc.js".source = ./files/.mongoshrc.js;

    file."bin".source = ./files/bin;

    # links individual files
    # file.bin = {
    #   source = ./files/bin;
    #   recursive = true;
    # };
  };
}
