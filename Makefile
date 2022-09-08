.DEFAULT_GOAL:=build

SHELL:=/bin/zsh

PWD:=$(shell pwd)


%.zwc: $(wildcard %/*)
	$(info += Compiling file $@)
	$(info += Compiling functions [$(notdir $(wildcard $(basename $@)/*))])
	zsh -c 'fpath=("$(PWD)/$(basename $@)" $$fpath); \
		autoload +X $(notdir $(wildcard $(basename $@)/*)); \
		zcompile -cam $@ $(notdir $(wildcard $(basename $@)/*))'


main.zsh.zwc : main.zsh
	zsh -vc 'fpath=("$(PWD)/functions" "$(PWD)/completions" $$fpath); source $<; zcompile -cam $@'


main.zsh : libexec/main_header.sh $(wildcard lib/*.zsh)
	echo '#!/bin/zsh' > $@
	for file in $^; do awk 'NR > 1 { print }' < "$$file" >>$@ ; done


build : main.zsh.zwc completions.zwc functions.zwc


clean : ; rm -f main.zsh main.zsh.zwc completions.zwc functions.zwc

ALWAYS: ;

.PHONY : build clean
