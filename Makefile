.DEFAULT_GOAL:=compile

SHELL:=/bin/zsh -i
PWD:=$(shell pwd)

MAN_INSTALL_DIR?=/usr/local/share/man/man1
MAN_INSTALL_DIR:=/Users/chrisgerber/share/man/man1
MANPAGE_1=$(MAN_INSTALL_DIR)/azimuth.1


##
## Build
BUILD_DIR:= build
$(BUILD_DIR):
	mkdir $@


##
## Scripts
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


##
## Docs
DOCS_DIR=docs

$(BUILD_DIR)/dot-help: main.zsh $(BUILD_DIR)
	$(shell source $<; -dot-help > $@)

$(BUILD_DIR)/grep-fnc: $(BUILD_DIR)/dot-help
	awk '$$1 ~ "-dot" { print $$1 }' $< | grep -oE '\-[a-zA-Z-]*' > $@

$(DOCS_DIR)/azimuth.functions.md: $(BUILD_DIR)/grep-fnc docs/azimuth.awk main.zsh
	( cat $< | xargs -I{} awk -v fncname="{}" -f docs/azimuth.awk main.zsh ) > $@

%.1.md: %.header.md %.functions.md %.description.md %.footer.md
	cat $^ > $@

$(DOCS_DIR)/%.1: $(DOCS_DIR)/%.1.md
	pandoc $< -s -t man -o $@

$(MAN_INSTALL_DIR)/%.1 : $(DOCS_DIR)/%.1
	install -g admin -m 0664 $< $(MAN_INSTALL_DIR)
	gzip $@


compile : main.zsh.zwc completions.zwc functions.zwc $(DOCS_DIR)/azimuth.1

install: $(MANPAGE_1)

clean : ; rm -f main.zsh main.zsh.zwc completions.zwc functions.zwc $(DOCS_DIR)/azimuth.1

ALWAYS: ;

.PHONY : compile install clean
