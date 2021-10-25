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

  -dot-add-fpath "${_CUR_DIR}/functions"
  -dot-add-fpath "${_CUR_DIR}/completions"

  # Config
  # --------------------------------------
  -dot-source-dirglob "config.zsh"
  -dot-source-dotfile "post-config.zsh"

  # Init
  # --------------------------------------
  -dot-source-dirglob "init.zsh"
  -dot-source-dotfile "post-init.zsh"

  # Finish Autocomplete Setup
  # --------------------------------------
  -dot-reload-compinit
}

function -dot-help() {
  # Print all -dot commands
  #
  # Usage:
  #   1 (optional) = Command to print help for

  local _cmd="${1}"
  local _cmds="$(compgen -c | sort | grep -E '^\-dot')"
  local _src_file="$(whence -v - -dot-help | awk '{print $7}')"

  if test -n "${_cmd}"; then
    echo ''
    cmdArray=( "${_cmd}" )
  else
    echo 'Available Commands:\n'
    cmdArray=( $(echo "$_cmds") )
  fi

  for _name in "${cmdArray[@]}"; do
    echo "${_name}()\n"

    awk \
      -v fncname="${_name}" \
      '$0 ~ fncname {
        getline;
        while ( $0 ~ /#/ ) {
          gsub(/#/, "");
          print "    " $0;
          getline;
        }
      }' \
      "${_src_file}"

    echo ""
  done;
}
