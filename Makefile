export MODULESHOME = $(shell pwd)
.PHONY: doc www initdir install clean .makeinstallpath

# load previously saved install paths if any
-include .makeinstallpath

# set default installation paths if not yet defined
prefix ?= /usr/local/modules-tcl
bindir ?= $(prefix)/bin
libexecdir ?= $(prefix)/libexec
initdir ?= $(prefix)/init
datarootdir ?= $(prefix)/share
mandir ?= $(datarootdir)/man
docdir ?= $(datarootdir)/doc

all: initdir doc ChangeLog .makeinstallpath

# save defined install paths
.makeinstallpath:
	@echo "prefix := $(prefix)" >$@
	@echo "bindir := $(bindir)" >>$@
	@echo "libexecdir := $(libexecdir)" >>$@
	@echo "initdir := $(initdir)" >>$@
	@echo "datarootdir := $(datarootdir)" >>$@
	@echo "mandir := $(mandir)" >>$@
	@echo "docdir := $(docdir)" >>$@

initdir:
	make -C init all prefix=$(prefix) libexecdir=$(libexecdir) \
		initdir=$(initdir)

doc:
	make -C doc all prefix=$(prefix) datarootdir=$(datarootdir) \
		mandir=$(mandir) docdir=$(docdir)

www:
	make -C www all

ChangeLog:
	contrib/gitlog2changelog.py

install: ChangeLog .makeinstallpath
	mkdir -p $(libexecdir)
	mkdir -p $(bindir)
	mkdir -p $(docdir)
	cp modulecmd.tcl $(libexecdir)/
	chmod +x $(libexecdir)/modulecmd.tcl
	cp contrib/envml $(bindir)/
	chmod +x $(bindir)/envml
	cp ChangeLog $(docdir)/
	cp NEWS $(docdir)/
	cp readme.txt $(docdir)/README
	make -C init install
	make -C doc install

distclean: clean

clean: 
	rm -f *.log *.sum ChangeLog .makeinstallpath
	make -C init clean
	make -C doc clean
	make -C www clean

test:
	MODULEVERSION=Tcl; export MODULEVERSION; \
	OBJDIR=`pwd -P`; export OBJDIR; \
	TESTSUITEDIR=`cd testsuite;pwd -P`; export TESTSUITEDIR; \
	runtest --srcdir $$TESTSUITEDIR --objdir $$OBJDIR --tool modules -v
