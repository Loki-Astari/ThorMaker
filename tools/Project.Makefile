
-include $(THORSANVIL_ROOT)/Makefile.config
-include $(THORSANVIL_ROOT)/build/tools/Colour.Makefile

.PHONY:	all test clean veryclean install uninstall profile build lint vera doc %.dir

MAKE	= make --silent
SHELL	= /bin/bash
NEOVIM  ?= FALSE
FILEDIR ?=


SUB_PROJECTS	= $(foreach target,$(TARGET),$(target).dir)

all:		ACTION=build
test:		ACTION=test
clean:		ACTION=clean
veryclean:	ACTION=veryclean NODEP=1
install:	ACTION=install
uninstall:	ACTION=uninstall
profile:	ACTION=profile
build:		ACTION=build
lint:		ACTION=lint
vera:		ACTION=vera
doc:		ACTION=doc
build-honly:ACTION=build-honly

ACTION		?=all
BUILD_ROOT	?=$(THORSANVIL_ROOT)/build
PREFIX		?=$(BUILD_ROOT)


all:		$(SUB_PROJECTS)
test:		$(SUB_PROJECTS)
clean:		$(SUB_PROJECTS)
veryclean:	$(SUB_PROJECTS)
install:	$(SUB_PROJECTS)
uninstall:	$(SUB_PROJECTS)
profile:	$(SUB_PROJECTS)
build:		$(SUB_PROJECTS)
lint:		check_lint $(SUB_PROJECTS)
vera:		$(SUB_PROJECTS)
doc:		$(SUB_PROJECTS) docbuild
build-honly:$(SUB_PROJECTS)

header-only:
	@host=$$(git remote get-url origin);									\
	dst=$$(mktemp -d);														\
	echo "host: $${host}  dst: $${dst}";									\
	git clone --single-branch --branch header-only $${host} $${dst};		\
	$(MAKE) FILEDIR=$(FILEDIR) NEOVIM=$(NEOVIM) THORSANVIL_ROOT=$(THORSANVIL_ROOT) PREFIX=$${dst} build-honly;	\
	echo "DONE";															\
	echo "		$${dst}"

docbuild:
	@if [[ -d docSource ]]; then		\
		cd docSource;				\
		andvari build;				\
	fi

%.dir:
	@$(ECHO) $(call colour_text, LIGHT_PURPLE, "Building Dir $* Start")
	@if test -d $*; then														\
		$(MAKE) -j1 -C $* $(ACTION) FILEDIR=$(FILEDIR)$*/ NEOVIM=$(NEOVIM) THORSANVIL_ROOT=$(THORSANVIL_ROOT) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER);		\
	else																		\
		$(ECHO) $(call colour_text, RED, "Sub Project $* non local ignoring");		\
	fi
	@$(ECHO) $(call colour_text, LIGHT_PURPLE, "Building Dir $* Finish")

include $(THORSANVIL_ROOT)/build/tools/Platform.Makefile
include $(THORSANVIL_ROOT)/build/tools/lint.Makefile
	
