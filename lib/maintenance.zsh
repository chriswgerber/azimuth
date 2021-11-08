#!/bin/zsh


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

  -dot-main "${repo_dir}"
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

  test -f "${DOTFILES_DIR}/upgrade.zsh" && \
    source "${DOTFILES_DIR}/upgrade.zsh"
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
