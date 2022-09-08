# Azimuth

ZSH Dotfile library.

```zsh
# Clone repo into cache or lib directory
source "~Library/Caches/com.chriswgerber.azimuth/main.zsh"

# Set directory that has dotfiles
DOTFILES_DIR="${HOME}/.dotfiles"

# Run main
-dot-main ${DOTFILES_DIR}"
```

```zsh
$ -dot-help
Available Commands:

-dot-autoload-reload()

       Reload the functions added to fpath.

-dot-azimuth-update()

       Upgrade brew, zsh, plugins, and dotfiles.
      
       Runs (in order):
         -dot-brew-upgrade
         -dot-zsh-plugins-upgrade
         -dot-dir-projects-upgrade
         -dot-cache-repos-update
         -dot-fpath-recompile

-dot-brew-bundle-dump()

       Dump brew packages to file.
      
       Usage:
         $1 = Brewfile to write. Defaults to env `BREW_FILE`

-dot-brew-bundle-install()

       Installs all of the packages in a Homebrew Brewfile.
      
       Usage:
         $1 = Brewfile to use. Defaults to env `BREW_FILE`

-dot-brew-upgrade()

       Run brew update, upgrade, and cleanup.
      
       if $BREW_FILE is defined, it will also dump installed packages to $BREW_FILE.
      
       To enable verbose brew commands, set the end $ZSH_DEBUG.

-dot-cache-create-file()

       Create or get the name of a file in the cache directory.
      
       Usage :
         $1 = Name of the file to read from the cache. Will create the file if it
              doesn't exist.

-dot-cache-fnc-clear()

       Delete all compiled ZSH functions.
      
       Usage :
         $1 = Target Directory to search

-dot-cache-fnc-dir()

       Cache the contents of a zsh `functions` directory.
      
       Usage :
         $1 = Target Directory
         $2 = Optional file name of the compiled functions.

-dot-cache-read-file()

       Source a file from the cache.
      
       Usage :
         $1 = File name from cache directory.

-dot-cache-repos-update()

       Update cache directory repositories

-dot-cache-update-file()

       Update a file in the cache directory by overwriting the contents with the
       output of the passed command.
      
       Usage :
         $1 = The name of the file to be updated.
         $2 = The command to be run to update the file.

-dot-compinit-reload()

       Reload/Setup Autoload functions and compinit

-dot-deprecated-log()

       Log use of deprecated function.
      
       Args:
         1: Message to print

-dot-deprecated-log-clear()

-dot-dir-glob-source()

       Sources all files matching argument, beginning with the root file and then
       source all in 1st level subdirectory.
      
       Usage :
         $1 = The name of the file to find across directories.

-dot-dir-projects-upgrade()

       Run upgrade.zsh for all projects in ${DOTFILES_DIR}
      
       Usage ;
           $1: The target directory

-dot-dir-repos-upgrade()

       Update plugins from Github
      
       Usage:
         $1 = Directory to check for repos.
         $2 = Array of directory names to ignore

-dot-file-source()

       Source a file in the dotfile dir.
      
       If it doesn't find the matching file in the dotfile directory, it will
       source it from the current working directory.
      
       Usage :
         $1 = The name of the file to find in the dotfiles directory.

-dot-fpath-add()

       Add the directory, and any 1st level directories, to the fpath.
      
       Usage:
         1 - Directory to begin search. azimuth/functions azimuth/completions
         2 - Name of directory to load within the base directory

-dot-fpath-completion-update()

       Upgrade a completion file.
      
       Usage :
         1 = Name of the command
         2 = Path of completions directory

-dot-fpath-recompile()

       Recompile ZSH functions and dirs for autoloading.
      
       Usage:
          $1 = Directory to recompile. Defaults to $DOTFILES_DIR.

-dot-github-plugin-add()

       Install Github Plugin
      
       Usage:
         $1 = Group + Plugin Name
         $2 = Install Directory

-dot-github-repo-install()

       Idempotently clone repo from GitHub into directory.
      
       Usage:
         $1 (required) = Namespace/ProjectName
         $2 (required) = Filesystem Location
         $3            = Protocol (SSH|HTTPS)

-dot-help()

       Print all -dot commands
      
       Usage:
         1 (optional) = Command to print help for

-dot-help-print-cmd()

-dot-log-message()

-dot-main()

       Load the framework. Sources files in order of:
         - file.zsh
         - */file.zsh
         - post-file.zsh
      
       Args:
        $1 - Directory location of the Dotfiles.
             Defaults to `$DOTFILES_DIR, if set, or `$HOME`.

-dot-omz-install()

       Installs OMZ into the ZSH directory

-dot-path-add()

       A stupid function that adds a new Path to the beginning of the PATH.
      
       Usage:
         $1 = Path string.

-dot-symlink-update()

       Creates symlink in the $HOME directory
      
       Usage :
         $1 = Source file to use as link.
         $2 = Destination for symlink.

-dot-timestamp-get()

-dot-zprofile-run()

       Run a cprof-like load of the ZSH Environment

-dot-zsh-plugins-upgrade()

       Update plugins for ZSH in "${ZSH_CUSTOM}/plugins"

```
