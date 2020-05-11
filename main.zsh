#!/bin/zsh


_CUR_DIR=$(dirname "$0")


source "${_CUR_DIR}/lib/cache.zsh"
source "${_CUR_DIR}/lib/files.zsh"
source "${_CUR_DIR}/lib/maintenance.zsh"
source "${_CUR_DIR}/lib/utils.zsh"


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
