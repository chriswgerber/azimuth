#!/bin/zsh
#===============================================================================
# DO NOT EDIT THIS FILE DIRECTLY. This file is generated by running
# `make main.zsh` and any changes made here will be overwritten with each build.
#
# To edit the contents of this file, find the corresponding file in lib/ and
# make changes before running `make`.
#
#===============================================================================


_CUR_DIR=$(dirname "$0")


function -dot-main() {
  # Load the framework. Sources files in order of:
  #   - file.zsh
  #   - */file.zsh
  #   - post-file.zsh
  #
  # Args:
  #  $1 - Directory location of the Dotfiles.
  #       Defaults to `$DOTFILES_DIR, if set, or `$HOME`.

  local src_dir="${1}"

  if test -z $src_dir; then
    src_dir="${DOTFILES_DIR:=${HOME}}";
  fi

  # Load Framework functions
  # --------------------------------------
  fpath=(${_CUR_DIR}/main.zsh.zwc $fpath)

  -dot-fpath-add "${_CUR_DIR}/functions"
  -dot-fpath-add "${_CUR_DIR}/completions"

  # Config
  # --------------------------------------
  -dot-dir-glob-source "config.zsh"
  -dot-file-source "post-config.zsh"

  # Init
  # --------------------------------------
  -dot-dir-glob-source "init.zsh"
  -dot-file-source "post-init.zsh"

  # Finish Autocomplete Setup
  # --------------------------------------
  -dot-compinit-reload
}


function -dot-help() {
  # Print all -dot commands
  #
  # Usage:
  #   1 (optional) = Command to print help for
  local _ignore_deprecations="@DEPRECATED"
  local _cmd="${1}"
  local _cmds="$(compgen -c | sort | grep -E '^\-dot')"
  local _src_file="$(whence -v - -dot-help | awk '{print $7}')"
  local _out

  if test -n "${_cmd}"; then
    _ignore_deprecations=""
    echo ''
    cmdArray=( "${_cmd}" )
  else
    echo 'Available Commands:\n'
    cmdArray=( $(echo "$_cmds") )
  fi

  for _name in "${cmdArray[@]}"; do
    _out=$(-dot-help-print-cmd "${_name}" "${_src_file}")

    case "${_out}" in
      *${_ignore_deprecations}*) printf "" ;;
      *)             echo "${_out}\n" ;;
    esac

  done;
}


function -dot-help-print-cmd() {
  local _fncname="${1}"
  local _srcfile="${2}"

  if test -z "${_srcfile}"; then
    _srcfile="$(whence -v - -dot-help-print-cmd | awk '{print $7}')"
  fi

  echo "${_fncname}()\n"
  awk -v fncname="${_fncname}" \
    '$0 ~ "function " fncname {
      getline;
      while ( $0 ~ /#/ ) {
        gsub(/#/, "");
        print "    " $0;
        getline;
      }
    }' \
    "${_srcfile}"
  echo ""
}


function -dot-zprofile-run() {
  # Run a cprof-like load of the ZSH Environment

  # exposes zprofexport
  if ! test $(command -v zprof); then
    echo 'error: Call `zmodload zsh/zprof` to load zsh profiling module.'
    return
  fi

  time (zsh -i -c exit)
  zprof
}


function -dot-azimuth-update() {
  # Upgrade brew, zsh, plugins, and dotfiles.
  #
  # Runs (in order):
  #   -dot-brew-upgrade
  #   -dot-zsh-plugins-upgrade
  #   -dot-dir-projects-upgrade
  #   -dot-cache-repos-update
  #   -dot-fpath-recompile
  local _msgfmt="+==\n+== Exec: %s\n+==\n"

  printf "${_msgfmt}" "-dot-brew-upgrade"
  -dot-brew-upgrade

  printf "${_msgfmt}" "-dot-zsh-plugins-upgrade"
  -dot-zsh-plugins-upgrade

  printf "${_msgfmt}" "-dot-dir-projects-upgrade"
  -dot-dir-projects-upgrade

  printf "${_msgfmt}" "-dot-cache-repos-update"
  -dot-cache-repos-update

  printf "${_msgfmt}" "-dot-fpath-recompile"
  -dot-fpath-recompile
}


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

  printf 'Dumping brew packages to %s\n' "${_brewfile}"

  test -n ${_brew} || {echo 'HomeBrew not found; "brew" command not available' && return 1}

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
      -dot-brew-bundle-dump
    fi
  }

  { # Cleanup cached brews
    _cmd="brew cleanup --verbose --prune=${BREW_CLEANUP_PRUNE_DAYS}"
    echo "${_cmd}"
    eval "${_cmd}"
  }
}


function -dot-cache-create-file() {
  # Create or get the name of a file in the cache directory.
  #
  # Usage :
  #   $1 = Name of the file to read from the cache. Will create the file if it
  #        doesn't exist.

  local fh="${DOT_CACHE_DIR}/${1}"

  if test -e "${fh}"; then echo "${fh}"; return; fi

  mkdir -p "$(dirname ${fh})"
  touch "${fh}"
  echo "${fh}"
}


function -dot-cache-read-file() {
  # Source a file from the cache.
  #
  # Usage :
  #   $1 = File name from cache directory.

  local fh=$(-dot-cache-create-file $1)

  source "${fh}"
}


function -dot-cache-update-file() {
  # Update a file in the cache directory by overwriting the contents with the
  # output of the passed command.
  #
  # Usage :
  #   $1 = The name of the file to be updated.
  #   $2 = The command to be run to update the file.

  local fh=$(-dot-cache-create-file ${1})
  local cmmd="${2}"

  echo "Updating cached file ${fh}"

  (eval "${cmmd}") &>"${fh}"
}


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


function -dot-file-source() {
  # Source a file in the dotfile dir.
  #
  # If it doesn't find the matching file in the dotfile directory, it will
  # source it from the current working directory.
  #
  # Usage :
  #   $1 = The name of the file to find in the dotfiles directory.

  local fh="${1}"
  local base_dir="${2:=${DOTFILES_DIR}}"

  if test -r "${base_dir}/${fh}"; then
    source "${base_dir}/${fh}";
  elif test -r "${fh}"; then
    source "${fh}";
  fi

}


function -dot-dir-glob-source() {
  # Sources all files matching argument, beginning with the root file and then
  # source all in 1st level subdirectory.
  #
  # Usage :
  #   $1 = The name of the file to find across directories.

  local _target_file=$1
  local base_dir=${2:=$DOTFILES_DIR}

  -dot-file-source "${_target_file}"

  # if command -v fd; then
  #   fd -pd 2 "${base_dir}/[a-z]*/${_target_file}" "${base_dir}" -exec -dot-file-source
  #   return
  # fi

  for the_file in $($SHELL +o nomatch -c "ls ${base_dir}/*/${_target_file} 2>/dev/null"); do
    -dot-file-source $the_file;
  done

}


function -dot-dir-projects-upgrade() {
  # Run upgrade.zsh for all projects in ${DOTFILES_DIR}
  #
  # Usage ;
  #     $1: The target directory

  -dot-file-source "upgrade.zsh"
  -dot-dir-glob-source "upgrade.zsh"
  -dot-file-source "post-upgrade.zsh"
}


function -dot-dir-repos-upgrade() {
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


function -dot-symlink-update() {
  # Creates symlink in the $HOME directory
  #
  # Usage :
  #   $1 = Source file to use as link.
  #   $2 = Destination for symlink.

  local _src="$DOTFILES_DIR/${1#"$DOTFILES_DIR/"}"
  local _dest="$HOME/${2#"$HOME/"}"
  local _dest_dir

  if ! test -L "$_dest"; then
    stat "$_dest"

    printf "\n\nLinking config file\n\tsrc: %s\n\tdest: %s\n\n" \
      "${_src}" \
      "${_dest}"

    if ! test -e "$_dest"; then
      _dest_dir="$(dirname "$_dest")"
      printf "Creating link for file %s at %s\n" "$_src" "$_dest"

      if test -e "$_src"; then
        printf "Creating target directory %s\n" "$_dest_dir"

        mkdir -p "$_dest_dir"
        ln -sf "$_src" "$_dest"
        return
      else
        printf \
          "Unable to create symlink for %s; src file %s does not exist.\n" \
          "$_dest" \
          "$_src"
      fi
    else
      printf \
        "Unable to create symlink for %s; dest file %s already exists.\n" \
        "$_src" \
        "$_dest"
    fi
  fi

}


function -dot-fpath-add() {
  # Add the directory, and any 1st level directories, to the fpath.
  #
  # Usage:
  #   1 - Directory to begin search. azimuth/functions azimuth/completions
  #   2 - Name of directory to load within the base directory

  local fpath_dir="${1}"
  local skipZwc="${2:="not"}"
  local fncPath

  if ! test -d ${fpath_dir}; then
    return
  fi
  if test "${skipZwc}" != "not"; then
    fncPath="${fpath_dir}"
  else
    fncPath="$(-dot-cache-fnc-dir "${fpath_dir}")"
  fi

  export fpath=(${fncPath} $fpath)

  for fnc in $(find ${fpath_dir} \( -type f -o -type l \) -print0 | tr "\0" " "); do
    autoload -Uz $fnc
  done
}


function -dot-fpath-recompile() {
  # Recompile ZSH functions and dirs for autoloading.
  #
  # Usage:
  #    $1 = Directory to recompile. Defaults to $DOTFILES_DIR.
  local _target_dir="${1:=${DOTFILES_DIR}}"
  local compile_command="autoload -U zrecompile; zrecompile {}"

  set -v

  find "${_target_dir}" -type f -maxdepth 2 \
    \( -name "*config.zsh" -o -name "*init.zsh" \) \
    -exec echo "${compile_command}" \; | zsh -v

  find "${_target_dir}" -type d -maxdepth 2 \
    \( -name "functions" -o -name "completions" \) \
    -exec echo "${compile_command}" \; | zsh -v

  if test -d "${_target_dir}/.cache"; then
    find "${_target_dir}/.cache" -type f -depth 1 \
      -name "*.sh" \
      -exec echo "${compile_command}" \; | zsh -v
  fi

  find "${_target_dir}" -name "*.zwc.old" -print -delete
}


function -dot-cache-fnc-dir() {
  # Cache the contents of a zsh `functions` directory.
  #
  # Usage :
  #   $1 = Target Directory
  #   $2 = Optional file name of the compiled functions.

  local target_dir="${1}"
  local suffix=".zwc"
  local zwc

  # Not a directory, exiting
  if ! test -d ${target_dir}; then
    return
  fi

  zwc="${target_dir}${suffix}"

  # If there are no files or links in the directory, print and exit
  if [[ "$(find ${target_dir} \( -type f -o -type l \) -print0)" == "" ]]; then
    printf "%s" ${target_dir}
    return
  fi

  # if it's a directory, and there are files and links, and the ZWC file doesn't exist,
  # compile it.
  if ! test -f ${zwc}; then
    rm -f ${zwc}
    touch ${zwc}
    (
      set -v
      zcompile -Uz ${zwc} $(find ${target_dir} \( -type f -o -type l \) -print0 | tr "\0" " ")
    )
  fi

  printf "%s" ${zwc}
}


function -dot-cache-fnc-clear() {
  # Delete all compiled ZSH functions.
  #
  # Usage :
  #   $1 = Target Directory to search

  local target_dir="${1:=${DOTFILES_DIR}}"
  local suffix=".zwc"
  local del_compdump="true"

  for fncfile in $(find "$target_dir" -type f -name "*${suffix}" -print); do
    rm -f "${fncfile}" || true
  done

  if [[ "${del_compdump}" == "true" ]] ; then
    rm -f "${ZSH_COMPDUMP}" || true
  fi
}


function -dot-cache-repos-update() {
  # Update cache directory repositories

  local __cachedir="${DOT_CACHE_DIR:=${DOTFILES_DIR}/.cache}"
  local _ignored_plugins=(${DOT_UPGRADE_IGNORE})

  echo "Upgrading ${__cachedir}, ignoring ${_ignored_plugins}"

  -dot-dir-repos-upgrade "${__cachedir}" ${_ignored_plugins}
}


function -dot-fpath-completion-update() {
  # Upgrade a completion file.
  #
  # Usage :
  #   1 = Name of the command
  #   2 = Path of completions directory

  local commd="${1}"
  local arggs=( ${@[@]:2:2} )
  local dirr="${@[$#]}"

  if test -z $(command -v "${commd}"); then
    printf "command not found: %s. Skipping\n" "${commd}";
    return 1;
  fi

  (
    printf 'Upgrading completion\n\tCommand:\t%s\n\tArguments:\t%s\n\tDirectory:\t%s\n' \
      "${commd}" \
      "${arggs}" \
      "${dirr}/"

    set -x

    mkdir -p "${dirr}" || true

    "${commd}" ${arggs[@]} &> "${dirr}/_${commd}"

    set +x
  )
}



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


function -dot-github-repo-install() {
  # Idempotently clone repo from GitHub into directory.
  #
  # Usage:
  #   $1 (required) = Namespace/ProjectName
  #   $2 (required) = Filesystem Location
  #   $3            = Protocol (SSH|HTTPS)

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


function -dot-github-plugin-add() {
  # Install Github Plugin
  #
  # Usage:
  #   $1 = Group + Plugin Name
  #   $2 = Install Directory

  local name="${1}"
  local __dir="${2:=${ZSH_CUSTOM}/plugins}"
  local plugin_name="${name#*/}"

  -dot-github-repo-install \
    "$name" \
    "${__dir}/${plugin_name}" \
    "HTTPS";

  plugins=($plugins $plugin_name)
}


function -dot-zsh-plugins-upgrade() {
  # Update plugins for ZSH in "${ZSH_CUSTOM}/plugins"

  -dot-dir-repos-upgrade "${ZSH_CUSTOM}/plugins"
}


function -dot-omz-install() {
  # Installs OMZ into the ZSH directory

  -dot-github-repo-install \
    "robbyrussell/oh-my-zsh" \
    "${ZSH:=${ZSH_CACHE_DIR}/oh-my-zsh}"
}
