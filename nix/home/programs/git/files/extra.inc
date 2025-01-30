[color]
  branch = auto
  diff = auto
  interactive = auto
  status = auto
  ui = auto

[color "branch"]
  current = yellow reverse
  local = yellow
  remote = green

[color "status"]
  added = yellow
  changed = green
  untracked = cyan

[apply]
  whitespace = fix

[push]
  default = simple

[pull]
  ff = only

[init]
  defaultBranch = main

[url "ssh://git@github.com/"]
  insteadOf = https://github.com/
