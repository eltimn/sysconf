# Ensure SSH_AUTH_SOCK points to gcr-ssh-agent
# Cosmic Desktop sets this to /run/user/1000/keyring/ssh at session start,
# but we want to use gcr-ssh-agent instead
export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR:-/run/user/$UID}/gcr/ssh"

# add custom functions to fpath
fpath=(~/.config/zsh/funcs $fpath);
autoload -Uz $fpath[1]/*(.:t)
