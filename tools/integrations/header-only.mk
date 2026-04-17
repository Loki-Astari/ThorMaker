# =============================================================================
# integrations/header-only.mk — convert project to header-only
#
# Walks a project through the `build-honly` / `build-hcont` flow, which
# rewrites a source library as header-only and re-runs the test suite
# against the generated headers.
#
# Requires: PREFIX NAMESPACE TARGET FILEDIR DISABLE_CONTROL_CODES
#           THORSANVIL_ROOT LDLIBS_FILTER
#           build script at $(BUILD_ROOT)/tools/headeronly/convert_project
# Defines:  HEADER_ONLY_PACKAGE
# Goals:    build-honly build-hcont build-honly-head
#           build-honly-convert build-honly-tail
# =============================================================================

HEADER_ONLY_PACKAGE		= $(basename $(firstword $(TARGET)))
build-honly: 	build-honly-head	build-honly-convert		build-honly-tail
build-hcont: 	build-honly-head							build-honly-tail

build-honly-head:
	@echo "Converting project"
	@echo "PREFIX:              $(PREFIX)"
	@echo "HEADER_ONLY_PACKAGE: $(HEADER_ONLY_PACKAGE)"
	@echo "NAMESPACE:           $(NAMESPACE)"
	@echo

build-honly-convert:
	@$(BUILD_ROOT)/tools/headeronly/convert_project $(PREFIX) $(HEADER_ONLY_PACKAGE) $(NAMESPACE)

build-honly-tail:
	@echo
	@echo
	@echo "Manual Steps about to be performed"
	@echo "cd $(PREFIX)/$(HEADER_ONLY_PACKAGE)"
	@echo "HEADER_ONLY=1 THORSANVIL_ROOT=\"$(THORSANVIL_ROOT)\" CXXFLAGS=\"-I$(PREFIX)\" LDLIBS_FILTER=\"$(patsubst $(PREFIX)/%,%,$(wildcard $(PREFIX)/*))\" $(MAKE) FILEDIR=$(FILEDIR) DISABLE_CONTROL_CODES=$(DISABLE_CONTROL_CODES) test"
	@echo
	@echo
	@CWD="$$(pwd)";	\
	cd "$(PREFIX)/$(HEADER_ONLY_PACKAGE)";	\
	HEADER_ONLY=1 THORSANVIL_ROOT="$(THORSANVIL_ROOT)" CXXFLAGS="-I$(PREFIX)" LDLIBS_FILTER="$(patsubst $(PREFIX)/%,%,$(wildcard $(PREFIX)/*))" $(MAKE) FILEDIR=$(FILEDIR) DISABLE_CONTROL_CODES=$(DISABLE_CONTROL_CODES) test
	@$(BUILD_ROOT)/tools/headeronly/commit_project $(PREFIX) $(HEADER_ONLY_PACKAGE) $(NAMESPACE)
