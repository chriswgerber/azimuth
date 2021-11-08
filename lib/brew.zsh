#!/bin/zsh


function -dot-brew-bundle-install() {
  # Installs all of the packages in a Homebrew Brewfile.
  #
  # Usage:
  #   $1 = Brewfile to use. Defaults to env `BREW_FILE`

  local _brewfile=${1:=${BREW_FILE}}
  local _brew=$(command -v brew)

  test -n ${_brew} ||
    { echo 'HomeBrew not found; "brew" command not available' && return 1 }
  test -r ${_brewfile} ||
    { echo 'Unable to find or read Brewfile.' && return 1 }

  printf 'Installing brew packages from %s\n' "${_brewfile}"
  printf 'Executing: %s bundle install --file "%s" --verbose\n' ${_brew} ${_brewfile}

  ${_brew} bundle install --file "${_brewfile}" --verbose
}


function -dot-brew-bundle-dump() {
  # Dump brew packages to file.
  #
  # Usage:
  #   $1 = Brewfile to write. Defaults to env `BREW_FILE`

  local _brewfile=${1:=${BREW_FILE}}
  local _brew=$(command -v brew)

  test -n ${_brew} || {echo 'HomeBrew not found; "brew" command not available' && return 1}

  printf 'Installing brew packages from %s\n' "${_brewfile}"
  printf 'Executing: %s bundle dump --file "%s" --force --all\n' ${_brew} ${_brewfile}

  ${_brew} bundle dump --file "${_brewfile}" --force --all
}


function -dot-brew-upgrade() {
  # Run brew update, upgrade, and cleanup.
  #
  # if $BREW_FILE is defined, it will also dump installed packages to $BREW_FILE.
  #
  # To enable verbose brew commands, set the end $ZSH_DEBUG.

  local _update_args
  local _upgrade_args
  local _dump_args
  local _cmd

  { # Update brew
    _update_args="--force"
    if [[ -n "$ZSH_DEBUG" ]]; then _update_args="--verbose ${_update_args}"; fi
    _cmd="brew update $_update_args"
    echo "${_cmd}"
    eval "${_cmd}"
  }

  { # Upgrade brews
    _upgrade_args="--display-times"
    if [[ -n "$ZSH_DEBUG" ]]; then _upgrade_args="--verbose ${_upgrade_args}"; fi
    _cmd="brew upgrade $_upgrade_args"
    echo "${_cmd}"
    eval "${_cmd}"
  }

  { # Dump installed brews to file.
    if [ -n "$BREW_FILE" ]; then
      -dot-dump-brew-bundle
    fi
  }

  { # Cleanup cached brews
    _cmd="brew cleanup --verbose --prune=${BREW_CLEANUP_PRUNE_DAYS}"
    echo "${_cmd}"
    eval "${_cmd}"
  }
}
