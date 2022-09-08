.DEFAULT_GOAL:=build

SHELL:=/bin/zsh

PWD:=$(shell pwd)

MAN_INSTALL_DIR=/usr/local/share/man/man1

MANPAGE_1=$(MAN_INSTALL_DIR)/azimuth.1


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

docs/azimuth.1: docs/azimuth.1.md
	pandoc $< -s -t man -o $@

$(MANPAGE_1) : docs/azimuth.1
	install -g admin -m 0664 $< $(MAN_INSTALL_DIR)
	gzip $@


build : main.zsh.zwc completions.zwc functions.zwc docs/azimuth.1


install: $(MANPAGE_1)


clean : ; rm -f main.zsh main.zsh.zwc completions.zwc functions.zwc docs/azimuth.1

ALWAYS: ;

.PHONY : build install clean
