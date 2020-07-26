.DEFAULT_GOAL := build

SHELL:=/bin/zsh

%.zsh.zwc : %.zsh
	zsh -vc 'zcompile -Uz $@ $^'

main.zsh.zwc : main.zsh
	zsh -vc 'fpath=("$$pwd/functions" "$$pwd/completions" $$fpath); source $<; zcompile -cam $@'

functions.zwc : $(wildcard functions/*)

main.zsh : libexec/main_header.sh $(wildcard lib/*.zsh)
	echo '#!/bin/zsh' > $@
	for file in $^; do awk 'NR > 1 { print }' < "$$file" >>$@ ; done

build : main.zsh.zwc

clean : ; rm -f main.zsh functions.zwc main.zsh.zwc

.PHONY : build clean
