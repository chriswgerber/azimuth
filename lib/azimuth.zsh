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
  # Zcompile functions if needed.
  if ! test -f functions.zwc; then
    command -v zcompile || autoload -Uz zcompile
    zcompile -Uz functions.zwc $(find ${_CUR_DIR}/functions -type f -print0 | tr "\0" " ")
  fi

  -dot-add-fpath "${_CUR_DIR}" "functions"
  -dot-add-fpath "${src_dir}" "functions"
  -dot-add-fpath "${_CUR_DIR}" "completions"
  -dot-add-fpath "${src_dir}" "completions"
  # Reload
  -dot-reload-autoload

  # Secrets
  # --------------------------------------
  -dot-source-dirglob "secrets.zsh"
  -dot-source-dotfile "post-secrets.zsh"

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
