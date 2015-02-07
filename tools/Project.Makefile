
-include $(THORSANVIL_ROOT)/Makefile.config
-include $(THORSANVIL_ROOT)/build/tools/Colour.Makefile

.PHONY:	all test clean install %.dir

SUB_PROJECTS	= $(foreach target,$(TARGET),$(target).dir)

all:		ACTION=build
clean:		ACTION=clean
veryclean:	ACTION=veryclean
install:	ACTION=install
profile:	ACTION=profile
build:		ACTION=build

ACTION		?=all
BUILD_ROOT	?=$(THORSANVIL_ROOT)/build
PREFIX		?=$(BUILD_ROOT)


all:		$(SUB_PROJECTS)
clean:		$(SUB_PROJECTS)
veryclean:	$(SUB_PROJECTS)
install:	$(SUB_PROJECTS)
profile:	$(SUB_PROJECTS)
build:		$(SUB_PROJECTS)


%.dir:
	@echo $(call colour_text, LIGHT_PURPLE, "Buiding $* Start")
	@if test -d $*; then														\
		echo $(MAKE) -C $* $(ACTION) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER);	\
		$(MAKE) -C $* $(ACTION) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER);		\
	else																		\
		echo $(call colour_text, RED, "Sub Project $* non local ignoring");		\
	fi
	@echo $(call colour_text, LIGHT_PURPLE, "Buiding $* Finish")
	
