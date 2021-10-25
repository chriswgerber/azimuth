#!/bin/zsh


function -dot-install-brew-bundle() {
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


function -dot-dump-brew-bundle() {
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


function -dot-upgrade-dir-repos() {
  # Update plugins from Github
  #
  # Usage:
  #   $1 = Directory to check for repos.
  #   $2 = Array of directory names to ignore

  local _remote_url
  local _found
  local _target_dir=$1
  local _ignore_dirs=(${2})

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
  #
  # Usage :
  #   $1 = Dotfiles Repo Directory

  local repo_dir=${1:=${DOTFILES_DIR}}

  (
    set -v
    git -C "${repo_dir}" stash
    git -C "${repo_dir}" pull --ff-only origin master || true
  )

  (git -C "${repo_dir}" stash pop || true) &>/dev/null

  -dot-main
}


function -dot-upgrade-brew() {
  # Run brew update, upgrade, and cleanup

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


function -dot-upgrade-cache-repos() {
  # Update cache directory repositories

  local __cachedir="${DOT_CACHE_DIR:=${DOTFILES_DIR}/.cache}"
  local _ignored_plugins=(${DOT_UPGRADE_IGNORE})

  echo "Upgrading ${__cachedir}, ignoring ${_ignored_plugins}"

  -dot-upgrade-dir-repos "${__cachedir}" ${_ignored_plugins}
}


function -dot-upgrade-zsh-plugins() {
  # Update plugins for ZSH in "${ZSH_CUSTOM}/plugins"

  -dot-upgrade-dir-repos "${ZSH_CUSTOM}/plugins"
}


function -dot-upgrade-dotfiles-projects() {
  # Run upgrade.zsh across all directories in dotfiles dir

  for i in $(ls -d ${DOTFILES_DIR}/*/upgrade.zsh); do
    (
      set -v
      source "${i}"
    ) &
  done

  wait
}


function -dot-upgrade-shell-env() {
  # Upgrade the Dotfiles environment
  #
  # Runs all the upgrade functions against the environment.

  echo "Updating dotfiles dir"
  -dot-upgrade-dotfiles-dir ${DOTFILES_DIR}

  # We have to run the brew upgrade first since everything is installed by it.
  echo "Updating brew"
  -dot-upgrade-brew

  echo "Updating omz"
  upgrade_oh_my_zsh

  echo "Updating cache repos"
  -dot-upgrade-cache-repos

  echo "Updating dotfiles directories"
  -dot-upgrade-dotfiles-projects

  # Lastly, reload the shell
  exec "${SHELL}"
}


function -dot-upgrade-completion() {
  # Upgrade a completion file.
  #
  # Usage :
  #   1 = Name of the command
  #   2 = Path of completions directory

  local commd="${1}"
  local arggs=( "${@[2,-2]}" )
  local dirr="${@[-1]}"

  command -v ${commd} || { printf "command not found: %s. Skipping\n" "${commd}" && return 1 }

  {
    mkdir -p "${dir}" || true

    printf 'Upgrading completion\n\tCommand:\t%s\n\tArguments:\t%s\n\tDirectory:\t%s\n' \
      "${commd}" \
      "${arggs}" \
      "${dirr}/"

    set -x

    "${commd}" ${arggs[@]} &> "${dirr}/_${commd}"

    set +x
  }
}
