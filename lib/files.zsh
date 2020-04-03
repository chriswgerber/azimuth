#!/bin/zsh


function -dot-cache-source-file() {
  # Source a file from the cache.
  local fh="${ZSH_CACHE_DIR}/$1"

  test -e "${fh}" && source "${fh}"
}


function -dot-cache-update-file() {
  # Update a file in the cache directory by overwriting the contents with the
  # output of the passed command.
  local fh="${ZSH_CACHE_DIR}/$1" cmmd="$2"
  echo "Updating cached file ${fh}"
  (eval "${cmmd}")&> "${fh}"
}


function -dot-source-dotfile() {
  # Source a file in the dotfile dir.
  # If it doesn't find the matching file in the dotfile directory, it will
  # source it from the current working directory.
  if [ -e "${__DD}/$1" ]; then
    source "${__DD}/$1";
  elif [ -e "${1}" ]; then
    source "${1}";
  fi
}


function -dot-source-dirglob() {
  # Sources all files matching argument, beginning with the root file and then
  # source all in 1st level subdirectory.
  local _target_file=$1

  -dot-source-dotfile "${_target_file}"

  for the_file in $(ls $__DD/*/$_target_file); do
    -dot-source-dotfile $the_file;
  done
}


function -dot-autoload-functions() {
  # Adds */functions to the autoload path.
  local _src_dir=$1

  fpath=($_CUR_DIR/functions $fpath)

  for fdir in $(find $_src_dir -type d -maxdepth 1 -not -name "*.*" -print); do
    if test -d "${fdir}/functions"; then
      fpath=($fdir/functions $fpath)
    fi
  done
}


function -dot-autoload-completions() {
  # Adds */completions to the autoload path.
  local _src_dir=$1

  fpath=($_CUR_DIR/completions $fpath)

  for fdir in $(find $_src_dir -type d -maxdepth 1 -not -name "*.*" -print); do
    if test -d "${fdir}/completions"; then
      fpath=($fdir/completions $fpath)
    fi
  done
}


function -dot-add-symlink-to-home() {
  # Creates symlink in the $HOME directory
  local _src="$__DD/$1" _dest="$HOME/${2#"$HOME/"}"

  if ! test -L $_dest; then
    if ! test -e $_dest; then
      if test -e "$_src"; then
        ln -sf "$_src" "$_dest"
        return 0
      fi
      printf \
        "Unable to create symlink for %s; src file %s does not exist.\n" \
        $_dest \
        $_src
    fi
    printf \
      "Unable to create symlink for %s; dest file %s already exists.\n" \
      $_dest \
      $_dest
  fi
}
