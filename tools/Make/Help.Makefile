

GLOW_CHECK			:= $(shell  command -v glow > /dev/null 2>&1 && echo 'glow')
GLOW				:= $(if $(GLOW_CHECK),$(GLOW_CHECK),cat)

# Deliberately empty as it needs to do nothing.
command-glow:
	@true

# Tell user they should install glow for a better experience.
command-cat:
	@echo "You don't have glow installed, using cat"
	@echo "For nicer formatting: brew install glow"
	@echo
	@echo

# The help command.
help:
	@$(MAKE) help-main

# Dump the appropriate help file.
help-%:	command-$(GLOW)
	@$(GLOW) $(BUILD_ROOT)/tools/help/make-$*.md
