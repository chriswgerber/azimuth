#!/bin/zsh


function -dot-path-add() {
  # A stupid function that adds a new Path to the beginning of the PATH.
  #
  # Usage:
  #   $1 = Path string.

  export PATH="${1}:${PATH}"
}


function -dot-autoload-reload() {
  # Reload the functions added to fpath.

  for func in $^fpath/*(N-.x:t); do
    autoload -Uz $func
  done
}


function -dot-compinit-reload() {
  # Reload/Setup Autoload functions and compinit

  autoload -U compinit
  # autoload -Uz +X compdef
  autoload -U +X bashcompinit

  # Autoload fpath and bash completes compat, as well
  -dot-autoload-reload

  compinit -C -i -d "${ZSH_COMPDUMP}" && bashcompinit
}
