

main.zsh: $(wildcard lib/*.zsh)
	echo '#!/bin/zsh\n\n' >$@
	echo '_CUR_DIR=$$(dirname "$$0")' >>$@
	for file in $^; do \
		awk 'NR > 1 { print }' < "$$file" >>$@ ; \
	done
