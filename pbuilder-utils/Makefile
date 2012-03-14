MANPAGES=debify pbuilder-createall pbuilder-module pbuilder-setup pbuilder-updateall spbuilder uploadchangestool
MANFILES=$(addprefix man/,$(addsuffix .1,$(MANPAGES)))
manpages: $(MANFILES)
man/%.1: bin/% lib/lib-help.sh
	HELPUTILS=./lib  $< --help-nroff > $@
