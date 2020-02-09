#!/bin/zsh


_CUR_DIR=$(dirname "$0")


source "${_CUR_DIR}/lib/files.zsh"
source "${_CUR_DIR}/lib/maintenance.zsh"
source "${_CUR_DIR}/lib/plugins.zsh"
source "${_CUR_DIR}/lib/utils.zsh"


function -dot-main() {
  # Sources files in order of:
  #
  # - file.zsh
  # - */file.zsh
  # - post-file.zsh
  export __DD="${DOTFILES_DIR:=$HOME}"

  # Setup local fpath
  # --------------------------------------
  -dot-autoload-functions $__DD
  -dot-autoload-completions $__DD
  -reload-autoload

  # Secrets
  # --------------------------------------
  -dot-source-dirglob "secrets.zsh"
  -dot-source-dotfile "post-secrets.zsh"

  # Config
  # --------------------------------------
  -dot-source-dirglob "config.zsh"
  -dot-source-dotfile "post-config.zsh"

  # Need to reload functions before init.
  -reload-autoload

  # Init
  # --------------------------------------
  -dot-source-dirglob "init.zsh"
  -dot-source-dotfile "post-init.zsh"

  # Finish Autocomplete Setup
  # --------------------------------------
  -reload-compinit "${_CUR_DIR}"
}
