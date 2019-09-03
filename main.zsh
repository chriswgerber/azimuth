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
    -reload-compinit "${_CUR_DIR}"

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

    # Complete local fpath
    # --------------------------------------
    -reload-compinit "${_CUR_DIR}"
}
