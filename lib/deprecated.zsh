#!/bin/zsh


function -dot-timestamp-get() {
  echo "$(TZ=America/Chicago /usr/local/bin/gdate '+%FT%T.%3N%:z')"
}


function -dot-deprecated-log-clear() {
  local logfile="${DOTFILES_DIR}/deprecated.log"

  rm ${logfile} && touch ${logfile}
}


function -dot-log-message() {
  local msg_format='[ %s ]\t%s'
  local stamp="$(-dot-timestamp-get)"
  local _msg="${1}"

  printf "${msg_format}" ${stamp} "${_msg}"
}


function -dot-deprecated-log() {
  # Log use of deprecated function.
  #
  # Args:
  #   1: Message to print

  local logfile="${DOTFILES_DIR}/deprecated.log"
  local msg="${1}"

  ( echo "$(-dot-log-message "${msg}")" ) >>${logfile}
}


# ==================== #
# Deprecated Functions #
# ==================== #


function -dot-upgrade-dotfiles-projects() {
  # Run upgrade.zsh across all directories in dotfiles dir
  #
  # @DEPRECATED Use -dot-dir-projects-upgrade
  local bad_file=${funcstack[@]:1:1}
  local bad_fnc="${0}"
  local new_fnc="-dot-dir-projects-upgrade"

  -dot-deprecated-log "$(printf "Update %s:%s\t->\t%s" "${bad_file}" "${bad_fnc}" "${new_fnc}")"

  -dot-dir-projects-upgrade $@
}


function -dot-add-fpath() {
  # Add the directory, and any 1st level directories, to the fpath.
  #
  # @DEPRECATED Use -dot-fpath-add
  #
  # Usage:
  #   1 - Directory to begin search. azimuth/functions azimuth/completions
  #   2 - Name of directory to load within the base directory
  local bad_file=${funcstack[@]:1:1}
  local bad_fnc="${0}"
  local new_fnc="-dot-fpath-add"

  -dot-deprecated-log "$(printf "Update %s:%s\t->\t%s" "${bad_file}" "${bad_fnc}" "${new_fnc}")"

  -dot-fpath-add $@
}


function -dot-add-path() {
  # A stupid function that adds a new Path to the beginning of the PATH.
  #
  # @DEPRECATED Use -dot-path-add
  #
  # Usage:
  #   $1 = Path string.
  local bad_file=${funcstack[@]:1:1}
  local bad_fnc="${0}"
  local new_fnc="-dot-fpath-add"

  -dot-deprecated-log "$(printf "Update %s:%s\t->\t%s" "${bad_file}" "${bad_fnc}" "${new_fnc}")"

  ${new_fnc} $@
}


function -dot-add-symlink-to-home() {
  # Creates symlink in the $HOME directory
  #
  # @DEPRECATED Use -dot-symlink-update
  #
  # Usage :
  #   $1 = Source file to use as link.
  #   $2 = Destination for symlink.
  local bad_file=${funcstack[@]:1:1}
  local bad_fnc="${0}"
  local new_fnc="-dot-symlink-update"

  -dot-deprecated-log "$(printf "Update %s:%s\t->\t%s" "${bad_file}" "${bad_fnc}" "${new_fnc}")"

  ${new_fnc} $@
}


function -dot-cache-source-file() {
  # Source a file from the cache.
  #
  # @DEPRECATED Use -dot-cache-read-file
  #
  # Usage :
  #   $1 = File name from cache directory.
  local bad_file=${funcstack[@]:1:1}
  local bad_fnc="${0}"
  local new_fnc="-dot-cache-read-file"

  -dot-deprecated-log "$(printf "Update %s:%s\t->\t%s" "${bad_file}" "${bad_fnc}" "${new_fnc}")"

  ${new_fnc} $@
}


function -dot-cache-get-file() {
  # Create or get the name of a file in the cache directory.
  #
  # @DEPRECATED Use -dot-cache-create-file
  #
  # Usage :
  #   $1 = Name of the file to read from the cache. Will create the file if it
  #        doesn't exist.
  local bad_file=${funcstack[@]:1:1}
  local bad_fnc="${0}"
  local new_fnc="-dot-cache-create-file"

  -dot-deprecated-log "$(printf "Update %s:%s\t->\t%s" "${bad_file}" "${bad_fnc}" "${new_fnc}")"

  ${new_fnc} $@
}


function -dot-dump-brew-bundle() {
  # Dump brew packages to file.
  #
  # @DEPRECATED Use -dot-brew-bundle-dump
  #
  # Usage:
  #   $1 = Brewfile to write. Defaults to env `BREW_FILE`
  local bad_file=${funcstack[@]:1:1}
  local bad_fnc="${0}"
  local new_fnc="-dot-brew-bundle-dump"

  -dot-deprecated-log "$(printf "Update %s:%s\t->\t%s" "${bad_file}" "${bad_fnc}" "${new_fnc}")"

  ${new_fnc} $@
}


function -dot-install-brew-bundle() {
  # Installs all of the packages in a Homebrew Brewfile.
  #
  # @DEPRECATED Use -dot-brew-bundle-install
  #
  # Usage:
  #   $1 = Brewfile to use. Defaults to env `BREW_FILE`
  local bad_file=${funcstack[@]:1:1}
  local bad_fnc="${0}"
  local new_fnc="-dot-brew-bundle-install"

  -dot-deprecated-log "$(printf "Update %s:%s\t->\t%s" "${bad_file}" "${bad_fnc}" "${new_fnc}")"

  ${new_fnc} $@
}


function -dot-upgrade-brew() {
  # Run brew update, upgrade, and cleanup.
  #
  # @DEPRECATED Use -dot-brew-upgrade
  #
  # if $BREW_FILE is defined, it will also dump installed packages to $BREW_FILE.
  #
  # To enable verbose brew commands, set the end $ZSH_DEBUG.
  local bad_file=${funcstack[@]:1:1}
  local bad_fnc="${0}"
  local new_fnc="-dot-brew-upgrade"

  -dot-deprecated-log "$(printf "Update %s:%s\t->\t%s" "${bad_file}" "${bad_fnc}" "${new_fnc}")"

  ${new_fnc} $@
}


function -dot-install-github-repo() {
  # Idempotently clone repo from GitHub into directory.
  #
  # @DEPRECATED Use -dot-github-repo-install
  #
  # Usage:
  #   $1 (required) = Namespace/ProjectName
  #   $2 (required) = Filesystem Location
  #   $3            = Protocol (SSH|HTTPS)
  local bad_file=${funcstack[@]:1:1}
  local bad_fnc="${0}"
  local new_fnc="-dot-github-repo-install"

  -dot-deprecated-log "$(printf "Update %s:%s\t->\t%s" "${bad_file}" "${bad_fnc}" "${new_fnc}")"

  ${new_fnc} $@
}


function -dot-install-github-plugin() {
  # Install Github Plugin
  #
  # @DEPRECATED Use -dot-github-plugin-add
  #
  # Usage:
  #   $1 = Group + Plugin Name
  #   $2 = Install Directory
  local bad_file=${funcstack[@]:1:1}
  local bad_fnc="${0}"
  local new_fnc="-dot-github-plugin-add"

  -dot-deprecated-log "$(printf "Update %s:%s\t->\t%s" "${bad_file}" "${bad_fnc}" "${new_fnc}")"

  ${new_fnc} $@
}


function -dot-install-omz() {
  # Installs OMZ into the ZSH directory
  #
  # @DEPRECATED Use -dot-omz-install
  local bad_file=${funcstack[@]:1:1}
  local bad_fnc="${0}"
  local new_fnc="-dot-omz-install"

  -dot-deprecated-log "$(printf "Update %s:%s\t->\t%s" "${bad_file}" "${bad_fnc}" "${new_fnc}")"

  ${new_fnc} $@
}


function -dot-reload-autoload() {
  # Reload the functions added to fpath.
  #
  # @DEPRECATED Use -dot-autoload-reload
  local bad_file=${funcstack[@]:1:1}
  local bad_fnc="${0}"
  local new_fnc="-dot-autoload-reload"

  -dot-deprecated-log "$(printf "Update %s:%s\t->\t%s" "${bad_file}" "${bad_fnc}" "${new_fnc}")"

  ${new_fnc} $@
}


function -dot-reload-compinit() {
  #
  # @DEPRECATED Use -dot-compinit-reload
  local bad_file=${funcstack[@]:1:1}
  local bad_fnc="${0}"
  local new_fnc="-dot-compinit-reload"

  -dot-deprecated-log "$(printf "Update %s:%s\t->\t%s" "${bad_file}" "${bad_fnc}" "${new_fnc}")"

  ${new_fnc} $@
}


function -dot-source-dotfile() {
  # Source a file in the dotfile dir.
  #
  # @DEPRECATED Use -dot-file-source
  #
  # If it doesn't find the matching file in the dotfile directory, it will
  # source it from the current working directory.
  #
  # Usage :
  #   $1 = The name of the file to find in the dotfiles directory.
  local bad_file=${funcstack[@]:1:1}
  local bad_fnc="${0}"
  local new_fnc="-dot-file-source"

  -dot-deprecated-log "$(printf "Update %s:%s\t->\t%s" "${bad_file}" "${bad_fnc}" "${new_fnc}")"

  ${new_fnc} $@
}


function -dot-source-dirglob() {
  # Sources all files matching argument, beginning with the root file and then
  # source all in 1st level subdirectory.
  #
  # @DEPRECATED Use -dot-dir-glob-source
  #
  # Usage :
  #   $1 = The name of the file to find across directories.
  local bad_file=${funcstack[@]:1:1}
  local bad_fnc="${0}"
  local new_fnc="-dot-dir-glob-source"

  -dot-deprecated-log "$(printf "Update %s:%s\t->\t%s" "${bad_file}" "${bad_fnc}" "${new_fnc}")"

  ${new_fnc} $@
}


function -dot-upgrade-completion() {
  # Upgrade a completion file.
  #
  # @DEPRECATED Use -dot-fpath-completion-update
  #
  # Usage :
  #   1 = Name of the command
  #   2 = Path of completions directory
  local bad_file=${funcstack[@]:1:1}
  local bad_fnc="${0}"
  local new_fnc="-dot-fpath-completion-update"

  -dot-deprecated-log "$(printf "Update %s:%s\t->\t%s" "${bad_file}" "${bad_fnc}" "${new_fnc}")"

  ${new_fnc} $@
}


function -dot-upgrade-zsh-plugins() {
  # Update plugins for ZSH in "${ZSH_CUSTOM}/plugins"
  #
  # @DEPRECATED Use -dot-zsh-plugins-upgrade
  local bad_file=${funcstack[@]:1:1}
  local bad_fnc="${0}"
  local new_fnc="-dot-zsh-plugins-upgrade"

  -dot-deprecated-log "$(printf "Update %s:%s\t->\t%s" "${bad_file}" "${bad_fnc}" "${new_fnc}")"

  ${new_fnc} $@
}


function -dot-upgrade-dir-repos() {
  # Update plugins from Github
  #
  # @DEPRECATED Use -dot-dir-repos-upgrade
  #
  # Usage:
  #   $1 = Directory to check for repos.
  #   $2 = Array of directory names to ignore
  local bad_file=${funcstack[@]:1:1}
  local bad_fnc="${0}"
  local new_fnc="-dot-dir-repos-upgrade"

  -dot-deprecated-log "$(printf "Update %s:%s\t->\t%s" "${bad_file}" "${bad_fnc}" "${new_fnc}")"

  ${new_fnc} $@
}


function -dot-upgrade-cache-repos() {
  # Update cache directory repositories
  #
  # @DEPRECATED Use -dot-cache-repos-update
  local bad_file=${funcstack[@]:1:1}
  local bad_fnc="${0}"
  local new_fnc="-dot-cache-repos-update"

  -dot-deprecated-log "$(printf "Update %s:%s\t->\t%s" "${bad_file}" "${bad_fnc}" "${new_fnc}")"

  ${new_fnc} $@
}


function -dot-upgrade-dotfiles-dir() {
  # Update the dotfiles directory, caching the contents while updating.
  #
  # @DEPRECATED Do not use.
  #
  # Usage :
  #   $1 = Dotfiles Repo Directory
  local bad_file=${funcstack[@]:1:1}
  local bad_fnc="${0}"
  local new_fnc="NONE"

  -dot-deprecated-log "$(printf "Delete %s:%s\t->\t%s" "${bad_file}" "${bad_fnc}" "${new_fnc}")"

  # local repo_dir=${1:=${DOTFILES_DIR}}

  # (
  #   set -v
  #   git -C "${repo_dir}" stash
  #   git -C "${repo_dir}" pull --ff-only origin master || true
  # )

  # (git -C "${repo_dir}" stash pop || true) &>/dev/null

  # -dot-main "${repo_dir}"
}
