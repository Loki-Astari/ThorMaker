
DOC_PACKAGE_TOOL			= $(BUILD_ROOT)/doc/buildPackage
DOC_CLASS_TOOL				= $(BUILD_ROOT)/doc/buildClass
DOC_METHOD_TOOL				= $(BUILD_ROOT)/doc/buildMethod
DOC_FUNCTION_TOOL			= $(BUILD_ROOT)/doc/buildFunction
DOC_CLASS_LIST_TOOL			= $(BUILD_ROOT)/doc/classList
DOC_METHOD_LIST_TOOL		= $(BUILD_ROOT)/doc/methodList
DOC_DIR						= $(THORSANVIL_ROOT)/docSource/source

DOC_DEST					= $(DOC_DIR)/$(1)/$(2).md

DOC_FILES					= $(DOC_PACKAGE) $(DOC_CLASSES) $(DOC_METHODS)
DOC_BASE					= $(basename $(firstword $(TARGET)))

DOC_PACKAGE					= $(if $(DOC_CLASS_FILES) $(DOC_METHOD_FILES), $(call DOC_DEST,package,$(DOC_BASE)))

DOC_CLASS_EXPAND			= $(foreach loop, $(shell $(BUILD_ROOT)/doc/$(2)List $(1)), $(call DOC_DEST,$2,$(DOC_BASE).$(basename $(1)).$(loop)))
DOC_CLASSES					= $(foreach loop, $(DOC_CLASS_FILES), $(call DOC_CLASS_EXPAND, $(loop),class) $(call DOC_CLASS_EXPAND,$(loop),function))
DOC_CLASS_FILES				= $(shell $(BUILD_ROOT)/doc/findMarksFiles class function)

DOC_METHOD_GETCLASSMETHOD_T	= $(foreach loop, $(shell $(BUILD_ROOT)/doc/methodList $(1) $(3) $(2)), $(call DOC_DEST,method,$(DOC_BASE).$(basename $(1)).$(2).$(3).$(loop)))
DOC_METHOD_GETCLASSMETHOD	= $(call DOC_METHOD_GETCLASSMETHOD_T,$(1),$(2),methods) $(call DOC_METHOD_GETCLASSMETHOD_T,$(1),$(2),virtual) $(call  DOC_METHOD_GETCLASSMETHOD_T,$(1),$(2),protected)
DOC_METHOD_GETCLASS			= $(foreach loop, $(shell $(BUILD_ROOT)/doc/classList $(1)), $(call DOC_METHOD_GETCLASSMETHOD, $(1),$(loop)))
DOC_METHODS					= $(foreach loop, $(DOC_METHOD_FILES), $(call DOC_METHOD_GETCLASS,$(loop)))
DOC_METHOD_FILES			= $(shell $(BUILD_ROOT)/doc/findMarksFiles method)

DOC_SUFFIX					= $(subst .,,$(suffix $(1)))
DOC_F1_OF_4					= $(basename $(basename $(basename $(basename $(1)))))
DOC_F2_OF_4					= $(call DOC_SUFFIX,$(basename $(basename $(basename $(1)))))
DOC_F3_OF_4					= $(call DOC_SUFFIX,$(basename $(basename $(1))))
DOC_F4_OF_4					= $(call DOC_SUFFIX,$(basename $(1)))


DOC_METHOD_SOURCE			= $(call DOC_F1_OF_4,$(1))
DOC_METHOD_CLASS			= $(call DOC_F2_OF_4,$(1))
DOC_METHOD_TYPE				= $(call DOC_F3_OF_4,$(1))
DOC_METHOD_METHOD			= $(call DOC_F4_OF_4,$(1))

doc: $(DOC_FILES)

$(DOC_DIR)/package/%.md: $(DOC_CLASS_FILES) $(wildcard docs/package1)
	@echo "Building Package $* Document"
	@$(DOC_PACKAGE_TOOL) $* $(DOC_CLASS_FILES) > $@

$(DOC_DIR)/class/$(DOC_BASE).%.md: $(DOC_CLASS_FILES) $(wildcard docs/%)
	@echo "Building Class $* Document"
	@$(DOC_CLASS_TOOL) $(DOC_BASE) $(basename $*).h $(subst .,,$(suffix $*)) > $@

$(DOC_DIR)/function/$(DOC_BASE).%.md: $(DOC_CLASS_FILES) $(wildcard docs/%)
	@echo "Building Function $* Documentation"
	@$(DOC_FUNCTION_TOOL) $(DOC_BASE) $(basename $*).h $(subst .,,$(suffix $*)) > $@

$(DOC_DIR)/method/$(DOC_BASE).%.md: $(DOC_METHOD_FILES) $(wildcard docs/%)
	@echo "Building Method $* Document"
	@$(DOC_METHOD_TOOL) $(DOC_BASE) $(call DOC_METHOD_SOURCE,$*).h $(call DOC_METHOD_TYPE,$*) $(call DOC_METHOD_CLASS,$*) $(call DOC_METHOD_METHOD,$*) > $@

