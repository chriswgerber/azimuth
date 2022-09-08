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

## Docs

```Zsh
man azimuth
```

## Updating Docs

```Zsh
# Creates Groff list for Functions.
$ -dot-help |
  awk '$1 ~ "-dot" { print $1 }' |
  grep -oE '\-[a-zA-Z-]*' |
  xargs -I{} awk \
    -v fncname="{}" \
    '$0 ~ "function " fncname {
        print "| *`" fncname "`*";
        print "";
        getline;
        while ( $0 ~ /#/ ) {
          gsub(/#/, "");
          if ( "  " == $0 ) print "";
          else print "| " $0;
          getline;
        }
        print "";
    }' main.zsh | 
  pbcopy
```
