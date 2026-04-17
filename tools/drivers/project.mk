# =============================================================================
# drivers/project.mk — multi-subdirectory orchestrator
#
# Used by a top-of-tree Makefile whose role is to recurse into a list of
# subdirectories. Each subdirectory's Makefile includes tools/Makefile
# (the leaf entry point); this driver fans out user goals across them.
#
# Requires: TARGET (list of subdirectory names, possibly suffixed with
#           platform filters like .NotMac / .OnlyLinux, see below)
#           THORSANVIL_ROOT  (the repo root)
#           PLATFORM_CAT     (provided by core/platform.mk)
# Defines:  filter-*  TARGET_AFTER_HEAD_FILTER  TARGET_AFTER_FILTER
#           SUB_PROJECTS  HEAD_SUB_PROJECTS  ACTION BUILD_ROOT PREFIX
# Exports:  DISABLE_CONTROL_CODES THORSANVIL_ROOT PREFIX CXXSTDVER
# Goals:    all test clean veryclean install uninstall profile build
#           lint vera doc build-honly build-hcont print tools dumpversion
#           release-only %.dir header-only headercont docbuild
#
# Platform filters:
#   foo.NotMac    → build on non-Mac only
#   foo.NotLinux  → build on non-Linux only
#   foo.NotWin    → build on non-Windows only
#   foo.OnlyMac   → build on Mac only     (etc.)
# =============================================================================

-include $(THORSANVIL_ROOT)/Makefile.config
include $(THORSANVIL_ROOT)/build/tools/core/colour.mk
include $(THORSANVIL_ROOT)/build/tools/core/platform.mk

.PHONY:	all test clean veryclean install uninstall profile build lint vera doc %.dir

MAKEFLAGS				+= --silent
SHELL					= /bin/bash
DISABLE_CONTROL_CODES	?= FALSE
FILEDIR					?=

#
# Pass-through variables for recursive $(MAKE) invocations.
# The per-subdir %.dir rule modifies FILEDIR; other exports flow unchanged.
export DISABLE_CONTROL_CODES THORSANVIL_ROOT PREFIX CXXSTDVER

filter-remove			= $(filter-out %.Not$(2),$(1))
filter-NotMac			= $(patsubst %.NotMac,%,$(1))
filter-NotLinux			= $(patsubst %.NotLinux,%,$(1))
filter-NotWin			= $(patsubst %.NotWin,%,$(1))
filter-nots				= $(call filter-NotMac,$(call filter-NotLinux,$(call filter-NotWin,$(call filter-remove,$(1),$(PLATFORM_CAT)))))
filter-keep-current		= $(patsubst %.Only$(PLATFORM_CAT),%,$(1))
filter-OnlyMac			= $(filter-out %.OnlyMac,$(1))
filter-OnlyLinux		= $(filter-out %.OnlyLinux,$(1))
filter-OnlyWin			= $(filter-out %.OnlyWin,$(1))
filter-only				= $(call filter-OnlyMac,$(call filter-OnlyLinux,$(call filter-OnlyWin,$(call filter-keep-current,$(1)))))
TARGET_AFTER_HEAD_FILTER= $(call filter-remove,$(call filter-remove,$(call filter-remove,$(TARGET),Win),Linux),Mac)
TARGET_AFTER_FILTER 	= $(call filter-only,$(call filter-nots,$(TARGET)))
SUB_PROJECTS			= $(foreach target,$(TARGET_AFTER_FILTER),$(target).dir)
HEAD_SUB_PROJECTS		= $(foreach target,$(TARGET_AFTER_HEAD_FILTER),$(target).dir)

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
build-honly:$(HEAD_SUB_PROJECTS)
build-hcont:$(HEAD_SUB_PROJECTS)
print:		$(SUB_PROJECTS)
tools:		$(SUB_PROJECTS)
dumpversion:$(SUB_PROJECTS)

header-only:
	@host=$$(git remote get-url origin);									\
	dst=$$(mktemp -d);														\
	echo "host: $${host}  dst: $${dst}";									\
	git clone --single-branch --branch header-only $${host} $${dst};		\
	$(MAKE) PREFIX=$${dst} build-honly;										\
	echo "DONE";															\
	echo "		$${dst}";													\
	echo;																	\
	echo "Please Check $${dst} and commit push if required";
headercont:
	@host=$$(git remote get-url origin);									\
	dst="${DST}";															\
	echo "host: $${host}  dst: $${dst}";									\
	$(MAKE) PREFIX=$${dst} build-hcont;										\
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
	@$(ECHO) $(call colour_text, LIGHT_PURPLE, "Building Dir $(FILEDIR)$* Start")
	@if test -d $*; then														\
		$(MAKE) -j1 -C $* $(ACTION) FILEDIR=$(FILEDIR)$*/;						\
	else																		\
		$(ECHO) $(call colour_text, RED, "Sub Project $* non local ignoring");		\
	fi
	@$(ECHO) $(call colour_text, LIGHT_PURPLE, "Building Dir $(FILEDIR)$* Finish")

include $(THORSANVIL_ROOT)/build/tools/targets/lint.mk
include $(THORSANVIL_ROOT)/build/tools/integrations/neovim.mk
include $(THORSANVIL_ROOT)/build/tools/integrations/help.mk
