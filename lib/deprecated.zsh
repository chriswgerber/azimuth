#!/bin/zsh


function -dot-timestamp-get() {
  echo "$(TZ=America/Chicago /usr/local/bin/gdate '+%FT%T.%3N%:z')"
}


function -dot-deprecated-log-clear() {
  local logfile="${DOTFILES_DIR}/deprecated.log"

  rm ${logfile} && touch ${logfile}
}


function -dot-deprecated-log() {
  # Log use of deprecated function.
  #
  # Args:
  #   1: Correct function to use
  #   2: Message to print
  local logfile="${DOTFILES_DIR}/deprecated.log"
  local msg_format='[%s] %s\t->\t%s "%s"'
  local _bad_func="${funcstack[@]:1:1}"
  local _good_fnc="${1}"
  local _msg="${2}"

  (
    printf "${msg_format}" \
      $(-dot-timestamp-get) \
      "${_bad_fnc}" \
      "${_good_fnc}" \
      "${_msg}"

    echo ""
  ) >>${logfile}
}


# ==================== #
# Deprecated Functions #
# ==================== #


function -dot-upgrade-dotfiles-projects() {
  # Run upgrade.zsh across all directories in dotfiles dir
  #
  # @DEPRECATED Use -dot-dir-projects-upgrade

  -dot-deprecated-log "-dot-dir-projects-upgrade" "Used at \"${funcstack[@]:1:1}\""

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

  -dot-deprecated-log "-dot-fpath-add" "Used at \"${funcstack[@]:1:1}\""

  -dot-fpath-add $@
}


function -dot-add-path() {
  # A stupid function that adds a new Path to the beginning of the PATH.
  #
  # @DEPRECATED Use -dot-path-add
  #
  # Usage:
  #   $1 = Path string.

  -dot-deprecated-log "-dot-path-add" "Used at \"${funcstack[@]:1:1}\""

  -dot-path-add $@
}


function -dot-add-symlink-to-home() {
  # Creates symlink in the $HOME directory
  #
  # @DEPRECATED Use -dot-symlink-update
  #
  # Usage :
  #   $1 = Source file to use as link.
  #   $2 = Destination for symlink.

  -dot-deprecated-log "-dot-symlink-update" "Used at \"${funcstack[@]:1:1}\""

  -dot-symlink-update $@
}


function -dot-cache-source-file() {
  # Source a file from the cache.
  #
  # @DEPRECATED Use -dot-cache-read-file
  #
  # Usage :
  #   $1 = File name from cache directory.

  -dot-deprecated-log "-dot-cache-read-file" "Used at \"${funcstack[@]:1:1}\""

  -dot-cache-read-file $@
}


function -dot-cache-get-file() {
  # Create or get the name of a file in the cache directory.
  #
  # @DEPRECATED Use -dot-cache-create-file
  #
  # Usage :
  #   $1 = Name of the file to read from the cache. Will create the file if it
  #        doesn't exist.

  -dot-deprecated-log "-dot-cache-create-file" "Used at \"${funcstack[@]:1:1}\""

  -dot-cache-create-file $@
}


function -dot-dump-brew-bundle() {
  # Dump brew packages to file.
  #
  # @DEPRECATED Use -dot-brew-bundle-dump
  #
  # Usage:
  #   $1 = Brewfile to write. Defaults to env `BREW_FILE`

  -dot-deprecated-log "-dot-brew-bundle-dump" "Used at \"${funcstack[@]:1:1}\""

  -dot-brew-bundle-dump $@
}


function -dot-install-brew-bundle() {
  # Installs all of the packages in a Homebrew Brewfile.
  #
  # @DEPRECATED Use -dot-brew-bundle-install
  #
  # Usage:
  #   $1 = Brewfile to use. Defaults to env `BREW_FILE`

  -dot-deprecated-log "-dot-brew-bundle-install" "Used at \"${funcstack[@]:1:1}\""

  -dot-brew-bundle-install $@
}


function -dot-upgrade-brew() {
  # Run brew update, upgrade, and cleanup.
  #
  # @DEPRECATED Use -dot-brew-upgrade
  #
  # if $BREW_FILE is defined, it will also dump installed packages to $BREW_FILE.
  #
  # To enable verbose brew commands, set the end $ZSH_DEBUG.

  -dot-deprecated-log "-dot-brew-upgrade" "Used at \"${funcstack[@]:1:1}\""

  -dot-brew-upgrade $@
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

  -dot-deprecated-log "-dot-github-repo-install" "Used at \"${funcstack[@]:1:1}\""

  -dot-github-repo-install $@
}


function -dot-install-github-plugin() {
  # Install Github Plugin
  #
  # @DEPRECATED Use -dot-github-plugin-add
  #
  # Usage:
  #   $1 = Group + Plugin Name
  #   $2 = Install Directory

  -dot-deprecated-log "-dot-github-plugin-add" "Used at \"${funcstack[@]:1:1}\""

  -dot-github-plugin-add $@
}


function -dot-install-omz() {
  # Installs OMZ into the ZSH directory
  #
  # @DEPRECATED Use -dot-omz-install

  -dot-deprecated-log "-dot-omz-install" "Used at \"${funcstack[@]:1:1}\""

  -dot-omz-install $@
}


function -dot-reload-autoload() {
  # Reload the functions added to fpath.
  #
  # @DEPRECATED Use -dot-autoload-reload

  -dot-deprecated-log "-dot-autoload-reload" "Used at \"${funcstack[@]:1:1}\""

  -dot-autoload-reload $@
}


function -dot-reload-compinit() {
  #
  # @DEPRECATED Use -dot-compinit-reload

  -dot-deprecated-log "-dot-compinit-reload" "Used at \"${funcstack[@]:1:1}\""

  -dot-compinit-reload $@
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

  -dot-deprecated-log "-dot-file-source" "Used at \"${funcstack[@]:1:1}\""

  -dot-file-source $@
}


function -dot-source-dirglob() {
  # Sources all files matching argument, beginning with the root file and then
  # source all in 1st level subdirectory.
  #
  # @DEPRECATED Use -dot-dir-glob-source
  #
  # Usage :
  #   $1 = The name of the file to find across directories.

  -dot-deprecated-log "-dot-dir-glob-source" "Used at \"${funcstack[@]:1:1}\""

  -dot-dir-glob-source $@
}


function -dot-upgrade-completion() {
  # Upgrade a completion file.
  #
  # @DEPRECATED Use -dot-fpath-completion-update
  #
  # Usage :
  #   1 = Name of the command
  #   2 = Path of completions directory

  -dot-deprecated-log "-dot-fpath-completion-update" "Used at \"${funcstack[@]:1:1}\""

  -dot-fpath-completion-update $@
}


function -dot-upgrade-zsh-plugins() {
  # Update plugins for ZSH in "${ZSH_CUSTOM}/plugins"
  #
  # @DEPRECATED Use -dot-zsh-plugins-upgrade

  -dot-deprecated-log "-dot-zsh-plugins-upgrade" "Used at \"${funcstack[@]:1:1}\""

  -dot-zsh-plugins-upgrade $@
}


function -dot-upgrade-dir-repos() {
  # Update plugins from Github
  #
  # @DEPRECATED Use -dot-dir-repos-upgrade
  #
  # Usage:
  #   $1 = Directory to check for repos.
  #   $2 = Array of directory names to ignore

  -dot-deprecated-log "-dot-dir-repos-upgrade" "Used at \"${funcstack[@]:1:1}\""

  -dot-dir-repos-upgrade $@
}


function -dot-upgrade-cache-repos() {
  # Update cache directory repositories
  #
  # @DEPRECATED Use -dot-cache-repos-update

  -dot-deprecated-log "-dot-cache-repos-update" "Used at \"${funcstack[@]:1:1}\""

  -dot-cache-repos-update $@
}


function -dot-upgrade-dotfiles-dir() {
  # Update the dotfiles directory, caching the contents while updating.
  #
  # @DEPRECATED Do not use.
  #
  # Usage :
  #   $1 = Dotfiles Repo Directory

  -dot-deprecated-log "NONE" "Used at \"${funcstack[@]:1:1}\""

  local repo_dir=${1:=${DOTFILES_DIR}}

  (
    set -v
    git -C "${repo_dir}" stash
    git -C "${repo_dir}" pull --ff-only origin master || true
  )

  (git -C "${repo_dir}" stash pop || true) &>/dev/null

  -dot-main "${repo_dir}"
}
