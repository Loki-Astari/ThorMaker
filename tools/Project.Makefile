
.PHONY:	all test clean install %.dir

SUB_PROJECTS	= $(foreach target,$(TARGET),$(target).dir)

all:		ACTION=install
clean:		ACTION=clean
veryclean:	ACTION=veryclean
install:	ACTION=install

ACTION		?=all
PREFIX		?=$(THORSANVIL_ROOT)/build


all:		$(SUB_PROJECTS)
clean:		$(SUB_PROJECTS)
veryclean:	$(SUB_PROJECTS)
install:	$(SUB_PROJECTS)


%.dir:
	$(MAKE) -C $* $(ACTION) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER)
	
