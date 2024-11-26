# add custom functions to fpath
fpath=(~/.config/zsh/funcs $fpath);
autoload -Uz $fpath[1]/*(.:t)
