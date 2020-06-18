.DEFAULT_GOAL := build

SHELL:=/bin/zsh

functions.zwc: $(wildcard functions/*)
	/bin/zsh -c "zcompile -Uz $@ $^"

main.zsh: libexec/main_header.sh $(wildcard lib/*.zsh)
	echo '#!/bin/zsh' > $@
	for file in $^; do \
		awk 'NR > 1 { print }' < "$$file" >>$@ ; \
	done

build: main.zsh functions.zwc

clean: ; rm -f main.zsh functions.zwc

.PHONY: build clean
