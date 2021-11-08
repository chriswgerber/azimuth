#!/bin/zsh

function -dot-timestamp-get() {
  echo "$(TZ=America/Chicago /usr/local/bin/gdate '+%FT%T.%3N%:z')"
}


function -dot-deprecated-log-clear() {
  local logfile="${DOTFILES_DIR}/deprecated.log"

  echo "" > ${logfile}

}


function -dot-deprecated-log() {
  local logfile="${DOTFILES_DIR}/deprecated.log"
  local _func="${1}"
  local _msg="${2}"

  (
    printf \
      "%s\t%s\t%s\n" \
      $(-dot-timestamp-get) \
      "${_func}" \
      "${_msg}"
  ) >>${logfile}
}


function -dot-add-fpath() {
  # Add the directory, and any 1st level directories, to the fpath.
  #
  # @DEPRECATED Use -dot-fpath-add
  #
  # Usage:
  #   1 - Directory to begin search. azimuth/functions azimuth/completions
  #   2 - Name of directory to load within the base directory

  -dot-deprecated-log "-dot-add-fpath" "Used at "${funcstack[@]:1:1}""

  -dot-fpath-add ${1} ${2}
}


function -dot-add-path() {
  # A stupid function that adds a new Path to the beginning of the PATH.
  #
  # @DEPRECATED Use -dot-path-add
  #
  # Usage:
  #   $1 = Path string.

  -dot-deprecated-log "-dot-add-path" "Used at "${funcstack[@]:1:1}""

  -dot-path-add ${1}
}


function -dot-add-symlink-to-home() {
  # Creates symlink in the $HOME directory
  #
  # @DEPRECATED Use -dot-symlink-update
  #
  # Usage :
  #   $1 = Source file to use as link.
  #   $2 = Destination for symlink.

  -dot-deprecated-log "-dot-add-symlink-to-home" "Used at "${funcstack[@]:1:1}""

  -dot-symlink-update ${1} ${2}
}


function -dot-cache-source-file() {
  # Source a file from the cache.
  #
  # @DEPRECATED Use -dot-cache-read-file
  #
  # Usage :
  #   $1 = File name from cache directory.

  -dot-deprecated-log "-dot-cache-source-file" "Used at "${funcstack[@]:1:1}""

  -dot-cache-read-file $1
}


function -dot-cache-get-file() {
  # Create or get the name of a file in the cache directory.
  #
  # @DEPRECATED Use -dot-cache-create-file
  #
  # Usage :
  #   $1 = Name of the file to read from the cache. Will create the file if it
  #        doesn't exist.

  -dot-deprecated-log "-dot-cache-get-file" "Used at "${funcstack[@]:1:1}""

  -dot-cache-create-file ${1}
}


function -dot-dump-brew-bundle() {
  # Dump brew packages to file.
  #
  # @DEPRECATED Use -dot-brew-bundle-dump
  #
  # Usage:
  #   $1 = Brewfile to write. Defaults to env `BREW_FILE`

  -dot-deprecated-log "-dot-dump-brew-bundle" "Used at "${funcstack[@]:1:1}""

  -dot-brew-bundle-dump ${1}
}


function -dot-install-brew-bundle() {
  # Installs all of the packages in a Homebrew Brewfile.
  #
  # @DEPRECATED Use -dot-brew-bundle-install
  #
  # Usage:
  #   $1 = Brewfile to use. Defaults to env `BREW_FILE`

  -dot-deprecated-log "-dot-install-brew-bundle" "Used at "${funcstack[@]:1:1}""

  -dot-brew-bundle-install ${1}
}


function -dot-upgrade-brew() {
  # Run brew update, upgrade, and cleanup.
  #
  # @DEPRECATED Use -dot-brew-upgrade
  #
  # if $BREW_FILE is defined, it will also dump installed packages to $BREW_FILE.
  #
  # To enable verbose brew commands, set the end $ZSH_DEBUG.

  -dot-deprecated-log "-dot-upgrade-brew" "Used at "${funcstack[@]:1:1}""

  -dot-brew-upgrade
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

  -dot-deprecated-log "-dot-install-github-repo" "Used at "${funcstack[@]:1:1}""

  local __test
  local __url
  local __repo="${1}"
  local __dir="${2}"
  local __protocol="${GIT_PROTOCOL:=ssh}"

  if ! test -d $__dir; then
    mkdir -p $__dir;
  fi

  __test=$(git -C $__dir remote -v &>/dev/null)

  if test $? -ne 0 -o ! -d "${__dir}/.git"; then
    if test "$3"; then __protocol="$3"; fi;

    case $__protocol in
      https|HTTPS) # Use HTTPS
        __url="https://github.com/${__repo}.git"
        ;;
      ssh|SSH|*)   # Default
        __url="git@github.com:${__repo}.git"
        ;;
    esac;

    rm -r ${__dir} || true;

    git clone --depth 10 $__url $__dir;
  fi
}


function -dot-install-github-plugin() {
  # Install Github Plugin
  #
  # @DEPRECATED Use -dot-github-plugin-add
  #
  # Usage:
  #   $1 = Group + Plugin Name
  #   $2 = Install Directory

  -dot-deprecated-log "-dot-install-github-plugin" "Used at "${funcstack[@]:1:1}""

  -dot-github-plugin-add ${1} ${2}
}


function -dot-install-omz() {
  # Installs OMZ into the ZSH directory
  #
  # @DEPRECATED Use -dot-omz-install

  -dot-deprecated-log "-dot-install-omz" "Used at "${funcstack[@]:1:1}""

  -dot-omz-install
}


function -dot-reload-autoload() {
  # Reload the functions added to fpath.
  #
  # @DEPRECATED Use -dot-autoload-reload

  -dot-deprecated-log "-dot-reload-autoload" "Used at "${funcstack[@]:1:1}""

  -dot-autoload-reload
}


function -dot-reload-compinit() {
  #
  # @DEPRECATED Use -dot-compinit-reload

  -dot-deprecated-log "-dot-reload-compinit" "Used at "${funcstack[@]:1:1}""

  -dot-compinit-reload
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

  -dot-deprecated-log "-dot-source-dotfile" "Used at "${funcstack[@]:1:1}""

  -dot-file-source ${1} ${2}
}


function -dot-source-dirglob() {
  # Sources all files matching argument, beginning with the root file and then
  # source all in 1st level subdirectory.
  #
  # @DEPRECATED Use -dot-dir-glob-source
  #
  # Usage :
  #   $1 = The name of the file to find across directories.

  -dot-deprecated-log "-dot-source-dirglob" "Used at "${funcstack[@]:1:1}""

  -dot-dir-glob-source $1 ${2}
}
