MANPAGES=
SMANPAGES=dpkg-speedup
MANFILES=$(addprefix man/,$(addsuffix .1,$(MANPAGES)))
SMANFILES=$(addprefix man/,$(addsuffix .8,$(SMANPAGES)))
manpages: $(MANFILES) $(SMANFILES)
$(MANFILES): man/%.1: bin/% lib/lib-help.sh
	HELPUTILS=./lib $< --help-nroff > $@
$(SMANFILES): man/%.8: sbin/% lib/lib-help.sh
	HELPUTILS=./lib $< --help-nroff > $@
