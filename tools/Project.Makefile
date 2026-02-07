
-include $(THORSANVIL_ROOT)/Makefile.config
-include $(THORSANVIL_ROOT)/build/tools/Colour.Makefile

.PHONY:	all test clean veryclean install uninstall profile build lint vera doc %.dir

MAKEFLAGS 		+= --silent
SHELL			= /bin/bash
NEOVIM			?= FALSE
FILEDIR			?=


SUB_PROJECTS	= $(foreach target,$(TARGET),$(target).dir)

all:		ACTION=build
release-only:	ACTION=release-only
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
build-hcont:ACTION=build-hcont
print:		ACTION=print
tools:		ACTION=tools
dumpversion:ACTION=dumpversion

ACTION		?=all
BUILD_ROOT	?=$(THORSANVIL_ROOT)/build
PREFIX		?=$(BUILD_ROOT)


all:		$(SUB_PROJECTS)
release-only:	$(SUB_PROJECTS)
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
build-hcont:$(SUB_PROJECTS)
print:		$(SUB_PROJECTS)
tools:		$(SUB_PROJECTS)
dumpversion:$(SUB_PROJECTS)

header-only:
	@host=$$(git remote get-url origin);									\
	dst=$$(mktemp -d);														\
	echo "host: $${host}  dst: $${dst}";									\
	git clone --single-branch --branch header-only $${host} $${dst};		\
	$(MAKE) FILEDIR=$(FILEDIR) NEOVIM=$(NEOVIM) THORSANVIL_ROOT=$(THORSANVIL_ROOT) PREFIX=$${dst} build-honly;	\
	echo "DONE";															\
	echo "		$${dst}";													\
	echo;																	\
	echo "Please Check $${dst} and commit push if required";
headercont:
	@host=$$(git remote get-url origin);									\
	dst="${DST}";															\
	echo "host: $${host}  dst: $${dst}";									\
	$(MAKE) FILEDIR=$(FILEDIR) NEOVIM=$(NEOVIM) THORSANVIL_ROOT=$(THORSANVIL_ROOT) PREFIX=$${dst} build-hcont;	\
	echo "DONE";															\
	echo "		$${dst}";													\
	echo;																	\
	echo "Please Check $${dst} and commit push if required";


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
include $(THORSANVIL_ROOT)/build/tools/NeoVim.Makefile
	
