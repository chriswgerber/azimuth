#!/bin/zsh


function -dot-install-github-repo() {
  # Idempotently clone repo from GitHub into directory.
  # Usage:
  # $1 (required) = Namespace/ProjectName
  # $2 (required) = Filesystem Location
  # $3            = Protocol (SSH|HTTPS)

  local __test __url __dir=$2 __protocol="${GIT_PROTOCOL:=ssh}"

  if ! test -d $__dir; then mkdir -p $__dir; fi

  __test=$(git -C $__dir remote -v &>/dev/null)

  if test $? -ne 0 -o ! -d "${__dir}/.git"; then
    if test "$3"; then __protocol="$3"; fi;

    case $__protocol in
      https|HTTPS) # Use HTTPS
        __url="https://github.com/$1.git"
        ;;
      ssh|SSH|*)   # Default
        __url="git@github.com:$1.git"
        ;;
    esac;

    rm -r ${__dir} || true;

    git clone --depth 10 $__url $__dir;
  fi
}


function -dot-install-github-plugin() {
  # Install Github Plugin
  # Usage:
  # $1 = Group + Plugin Name
  # $2 = Install Directory

  local name=$1 plugin_name=${1#*/} __dir="${2:=${ZSH_CUSTOM}/plugins}"

  -dot-install-github-repo \
    "$name" \
    "${__dir}/${plugin_name}" \
    "HTTPS";

  plugins=($plugins $plugin_name)
}


function -dot-install-omz() {
  # Installs OMZ into the ZSH directory
  # Usage: 
  # 

  -dot-install-github-repo \
    "robbyrussell/oh-my-zsh" \
    "${ZSH:=${ZSH_CACHE_DIR}/oh-my-zsh}"
}


function -dot-upgrade-dir-repos() {
  # Update plugins from Github
  # Usage:
  # $1 = Directory to check for repos.
  # $2 = Array of directory names to ignore

  local _remote_url _found
  local _target_dir=$1 _ignore_dirs=(${2})

  if test ${#__ignore_dirs[@]} -eq 0; then 
    _found=($(find "${_target_dir}" -maxdepth 1 -type d \
      -not -path "${_target_dir}" \
      -not \( \
        -name "${_ignore_dirs[1]}" \
        $(printf -- '-o -name "%s" ' "${_ignore_dirs[2,-1]}") \
      \)))
  else 
    _found=($(find "${_target_dir}" -maxdepth 1 -type d \
      -not -path "${_target_dir}" \
      ));
  fi

  for i in $_found; do
    (
      printf "=> Upgrading directory %s from origin %s.\n=> git -C %s pull origin master\n" \
        $i \
        "$(git -C $i config remote.origin.url)" \
        $i
        
      git -C $i pull origin master
    ) &
  done

  wait
}


function -dot-upgrade-dotfiles-dir() {
  # Update the dotfiles directory, caching the contents while updating.
  # Usage : 
  #

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
  # Usage : 

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

  { # Dump installed brews to file.
    if [ -n "$BREW_FILE" ]; then
      _cmd="brew bundle dump --force --all --describe --file=${BREW_FILE}"
      eval "${_cmd}"
    fi
  }

  { # Cleanup cached brews
    _cmd="brew cleanup --verbose --prune=${BREW_CLEANUP_PRUNE_DAYS}"
    eval "${_cmd}"
  }
}


function -dot-upgrade-cache-repos() {
  # Update cache directory repositories
  # Usage :

  local __cachedir="${ZSH_CACHE_DIR:=$__DD/.cache}"
  local _ignored_plugins=(${DOT_UPGRADE_IGNORE})

  -dot-upgrade-dir-repos "${__cachedir}" ${_ignored_plugins}
}


function -dot-upgrade-zsh-plugins() {
  # Update plugins for ZSH
  # Usage : 

  -dot-upgrade-dir-repos "${ZSH_CUSTOM}/plugins"
}


function -dot-upgrade-dotfiles-projects() {
  # Run upgrade.zsh across project
  # Usage : 

  for i in $(ls -d $__DD/*/upgrade.zsh); do
    (
      set -v
      source "${i}"
    ) &
  done

  wait
}


function -dot-upgrade-shell-env() {
  # Upgrade the Dotfiles environment
  # Runs all the upgrade functions against the environment.
  # Usage : 
  
  # Upgrade the dotfiles repo.
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
