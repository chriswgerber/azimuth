#!/bin/zsh


function -dot-main() {
  # Load the framework. Sources files in order of:
  #  - file.zsh
  #  - */file.zsh
  #  - post-file.zsh
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
