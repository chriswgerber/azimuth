.DEFAULT_GOAL := build
SHELL:=/bin/zsh

PWD:=$(shell pwd)

%.zsh.zwc : %.zsh
	zsh -vc 'zcompile -Uz $@ $^'

main.zsh.zwc : main.zsh
	zsh -vc 'fpath=("$(PWD)/functions" "$(PWD)/completions" $$fpath); source $<; zcompile -cam $@'

main.zsh : libexec/main_header.sh $(wildcard lib/*.zsh)
	echo '#!/bin/zsh' > $@
	for file in $^; do awk 'NR > 1 { print }' < "$$file" >>$@ ; done


build : main.zsh.zwc


clean : ; rm -f main.zsh main.zsh.zwc completions.zwc functions.zwc


.PHONY : build clean
