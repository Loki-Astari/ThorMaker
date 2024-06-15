
LOCAL_ROOT		?= $(shell pwd)
BASE			?= .

REALATIVEPATH=$(shell 	currentWorkingRealPath="$(realpath $(LOCAL_ROOT))";\
						thorsAbsPath="$(abspath $(THORSANVIL_ROOT)/)";\
						count=$$(echo $${currentWorkingRealPath\#"$${thorsAbsPath}"}/ | awk -F/ '{print NF-2}');\
						yes '../' | head -n $${count} | tr -d '\n';\
				)

-include $(LOCAL_ROOT)/$(REALATIVEPATH)/Makefile.config

BUILD_ROOT		?= $(THORSANVIL_ROOT)/build
include $(BUILD_ROOT)/tools/main.Makefile


