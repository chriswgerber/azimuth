#!/bin/zsh


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
  # Print help info about a command.
  #
  # Args:
  #   1: Name of the command.
  #   2: (optional) File to source command from.

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
