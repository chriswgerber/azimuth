#!/usr/bin/env zsh


function -dot-cache-source-file() {
    local fh
    fh="${ZSH_CACHE_DIR}/$1"

    test -e "${fh}" && source "${fh}"
}


function -dot-cache-update-file() {
    local fh
    local cmmd

    fh="${ZSH_CACHE_DIR}/$1"
    cmmd="$2"

    echo "Updating cached file ${1}"

    rm -f "${fh}" && (eval "${cmmd}") > "${fh}"
}


function -dot-source-dotfile() {
    # Source a file in the dotfile dir.
    if [ -e "${__DD}/$1" ]; then
        source "${__DD}/$1";
    elif [ -e "${1}" ]; then
        source "${1}";
    fi
}


function -dot-source-dirglob() {
  # Sources all files matching argument, beginning with the root file and then
  # source all in 1st level subdirectory.
  local _target_file
  _target_file=$1

  -dot-source-dotfile "${_target_file}"

  for the_file in $(ls $__DD/*/$_target_file); do
    -dot-source-dotfile $the_file;
  done
}


function -dot-add-symlink-to-home() {
    # Generates symlink in the $HOME directory
    local src=$1
    local des=$2

    if [ -L $HOME/$des ] && [ -e $HOME/$des ]; then return 0; fi

    test -d "$(dirname $HOME/$des)" || mkdir -p "$(dirname $HOME/$des)"

    if [ ! -L $HOME/$des ]; then
        ln -sf "$__DD/$src" "$HOME/$des"
    fi
}
