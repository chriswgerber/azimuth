#!/bin/zsh


function -dot-install-github-repo() {
  # Idempotently clone repo from GitHub into directory.
  # Usage:
  # $1 (required) = Namespace/ProjectName
  # $2 (required) = Filesystem Location
  # $3            = Protocol (SSH|HTTPS)

  local __url __dir=$2 __protocol="${GIT_PROTOCOL:=ssh}"

  if ! test -d $__dir; then mkdir -p $__dir; fi
  local __test=$(git -C $__dir remote -v &>/dev/null)

  if test $? -ne 0; then
    if test "$3"; then __protocol="$3"; fi;

    case $__protocol in
      https|HTTPS) # Use HTTPS
        __url="https://github.com/$1.git"
        ;;
      ssh|SSH|*)   # Default
        __url="git@github.com:$1.git"
        ;;
    esac;

    git clone --depth 10 $__url $__dir;
  fi
}


function -dot-install-omz() {
  # Installs OMZ into the ZSH directory
  -dot-install-github-repo \
    "robbyrussell/oh-my-zsh" \
    "${ZSH}:=${ZSH_CACHE_DIR}/oh-my-zsh"
}


function -dot-install-github-plugin() {
  # Install Github Plugin

  local name=$1 plugin_name=${1#*/} __dir="${2:=${ZSH_CUSTOM}/plugins}"

  -dot-install-github-repo \
    "$name" \
    "${__dir}/${plugin_name}" \
    "HTTPS";

  plugins=($plugins $plugin_name)
}


function -dot-upgrade-shell-env() {
  # Upgrade the Dotfiles environment
  -dot-upgrade-dotfiles-dir

  # We have to run the brew upgrade first since everything is installed by it.
  -dot-upgrade-brew

  # The Rest
  -dot-upgrade-cache-repos
  -dot-upgrade-zsh-plugins
  -dot-upgrade-dotfiles-projects

  # Lastly, reload the shell
  eval "${SHELL}"
}


alias -upgrade-shell-env="-dot-upgrade-shell-env"


function -dot-upgrade-cache-repos() {
  # Update cache directory repositories
  local __cachedir="${ZSH_CACHE_DIR:=$__DD/.cache}"
  local __basedir="$(dirname $__cachedir)"

  for i in $(ls ${__cachedir}); do
    (
      set -v
      git -C ${__basedir}/$i pull origin master
    ) &
  done

  wait
}


function -dot-upgrade-zsh-plugins() {
  # Update plugins from Github
  local _plugins_dir="${ZSH_CUSTOM}/plugins"

  for i in $(ls ${_plugins_dir}/); do
    (
      set -v
      git -C ${_plugins_dir}/$i pull origin master
    ) &
  done

  wait
}


function -dot-upgrade-dotfiles-projects() {
  # Run upgrade.zsh across project
  for i in $(ls -d $__DD/*/upgrade.zsh); do
    (
      set -v
      source "${i}"
    ) &
  done

  wait
}


function -dot-upgrade-dotfiles-dir() {
  # Update the dotfiles directory, caching the contents while updating.
  (
    set -v
    git -C $__DD stash
    git -C $__DD pull --ff-only origin master || true
  )

  (git -C $__DD stash pop || true) &>/dev/null

  -dot-main
}


function -dot-upgrade-brew() {
  # Upgrade Homebrew
  local _update_args _upgrade_args _dump_args _cmd

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

  ( # Dump installed brews to file.
    if [ -n "$BREW_FILE" ]; then
      _cmd="brew bundle dump --force --all --describe --file=${BREW_FILE}"
      eval "${_cmd}"
    fi
  ) &

  ( # Cleanup cached brews
    _cmd="brew cleanup --verbose --prune=${BREW_CLEANUP_PRUNE_DAYS}"
    eval "${_cmd}"
  ) &

  wait
}
