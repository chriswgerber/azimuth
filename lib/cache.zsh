#!/bin/zsh


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
