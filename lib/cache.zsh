#!/bin/zsh


function -dot-cache-get-file() {
  # Create or get the name of a file in the cache directory.
  # Usage :
  #  $1 = Name of the file to read from the cache. Will create the file if it
  #       doesn't exist.

  local fh="${ZSH_CACHE_DIR}/$1"

  if ! test -e "${fh}"; then
    mkdir -p "$(dirname ${fh})"
    touch "${fh}"
  fi

  echo "${fh}"
}


function -dot-cache-source-file() {
  # Source a file from the cache.
  # Usage :
  #   $1 = File name from cache directory.

  local fh=$(-dot-cache-get-file $1)

  test -e "${fh}" && source "${fh}"
}


function -dot-cache-update-file() {
  # Update a file in the cache directory by overwriting the contents with the
  # output of the passed command.
  # Usage :
  #   $1 = The name of the file to be updated.
  #   $2 = The command to be run to update the file.

  local fh=$(-dot-cache-get-file $1) cmmd="$2"

  echo "Updating cached file ${fh}"

  (eval "${cmmd}") &>"${fh}"
}
