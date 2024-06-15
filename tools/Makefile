
LOCAL_ROOT		?= $(shell pwd)
# TODO: Remove the need for BASE
BASE			?= .

REALATIVEPATH=$(shell 	currentWorkingRealPath="$(realpath $(LOCAL_ROOT))";\
						thorsAbsPath="$(abspath $(THORSANVIL_ROOT)/)";\
						count=$$(echo $${currentWorkingRealPath\#"$${thorsAbsPath}"}/ | awk -F/ '{print NF-2}');\
						yes '../' | head -n $${count} | tr -d '\n';\
				)

-include $(THORSANVIL_ROOT)/Makefile.config

BUILD_ROOT		?= $(abspath $(LOCAL_ROOT)/$(REALATIVEPATH))/build
include $(BUILD_ROOT)/tools/main.Makefile


check:
	@echo "LOCAL_ROOT:      $(LOCAL_ROOT)"
	@echo "REALATIVEPATH:   $(REALATIVEPATH)"
	@echo "THORSANVIL_ROOT: $(THORSANVIL_ROOT)"
	@echo "BUILD_ROOT:      $(BUILD_ROOT)"


