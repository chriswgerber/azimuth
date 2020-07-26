#!/bin/zsh


function -dot-add-path() {
  # A stupid function that adds a new Path to the beginning of the PATH.
  # Usage:
  # $1 = Path string.

  export PATH="${1}:${PATH}"
}


function -dot-profile-zsh() {
  # Run a cprof-like load of the ZSH Environment
  # Usage :

  # exposes zprofexport
  if [[ -z "$ZSH_DEBUG" ]]; then
    echo 'Set $ZSH_DEBUG=1 to enable profiling.'
  else
    zmodload zsh/zprof
    time (zsh -i -c exit)
    zprof
  fi
}


function -dot-reload-compinit() {
  # Reload/Setup Autoload functions and compinit
  # Usage :

  autoload -U compinit
  # autoload -Uz +X compdef
  autoload -U +X bashcompinit

  # Autoload fpath and bash completes compat, as well
  -dot-reload-autoload

  compinit -C -i -d "${ZSH_COMPDUMP}" && bashcompinit
}


function -dot-reload-autoload() {
  # Reload the functions added to fpath.
  local subarray

  for func in $^fpath/*(N-.x:t); do
    autoload -Uz $func
  done
}
