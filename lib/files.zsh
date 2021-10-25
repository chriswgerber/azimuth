#!/bin/zsh


function -dot-source-dotfile() {
  # Source a file in the dotfile dir.
  #
  # If it doesn't find the matching file in the dotfile directory, it will
  # source it from the current working directory.
  #
  # Usage :
  #   $1 = The name of the file to find in the dotfiles directory.

  local fh="${1}"
  local base_dir="${2:=${DOTFILES_DIR}}"

  if test -r "${base_dir}/${fh}"; then
    source "${base_dir}/${fh}";
  elif test -r "${fh}"; then
    source "${fh}";
  fi
}


function -dot-source-dirglob() {
  # Sources all files matching argument, beginning with the root file and then
  # source all in 1st level subdirectory.
  #
  # Usage :
  #   $1 = The name of the file to find across directories.

  local _target_file=$1
  local base_dir=${2:=$DOTFILES_DIR}

  -dot-source-dotfile "${_target_file}"

  for the_file in $($SHELL +o nomatch -c "ls ${base_dir}/*/${_target_file} 2>/dev/null"); do
    -dot-source-dotfile $the_file;
  done
}


function -dot-add-symlink-to-home() {
  # Creates symlink in the $HOME directory
  #
  # Usage :
  #   $1 = Source file to use as link.
  #   $2 = Destination for symlink.

  local _src="$DOTFILES_DIR/${1#"$DOTFILES_DIR/"}"
  local _dest="$HOME/${2#"$HOME/"}"
  local _dest_dir

  if ! test -L "$_dest"; then
    if ! test -e "$_dest"; then
      _dest_dir="$(dirname "$_dest")"
      printf "Creating link for file %s at %s\n" "$_src" "$_dest"

      if test -e "$_src"; then
        printf "Creating target directory %s\n" "$_dest_dir"

        mkdir -p "$_dest_dir"
        ln -sf "$_src" "$_dest"
        return
      else
        printf \
          "Unable to create symlink for %s; src file %s does not exist.\n" \
          "$_dest" \
          "$_src"
      fi
    else
      printf \
        "Unable to create symlink for %s; dest file %s already exists.\n" \
        "$_src" \
        "$_dest"
    fi
  fi
}
