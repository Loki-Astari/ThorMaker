# =============================================================================
# targets/build.mk — top-level user-facing goals
#
# Wires up all / install / uninstall / build / release-only / veryclean /
# debug / release / clean / test / testonly / covonly / veraonly / item /
# buildDir and the generic Note_% / %.Dir pattern rules.
#
# Requires: variables from core/variables.mk, colour helpers from core/colour.mk
#           target rules from targets/install.mk (ActionInstall / ActionUInstall)
#           target rules from targets/test.mk / coverage.mk / vera.mk
#           rules/link.mk (%.prog %.slib %.a %.head %.defer %.test)
#           rules/parallel.mk (makeDep)
# Defines:  TARGET_ITEM already in core/variables.mk
# Goals:    all install uninstall build release-only veryclean debug release
#           lint item buildDir testonly covonly test tools coverage veraonly
#           makeDep clean done Note_% %.Dir
# =============================================================================

#
# For reference the default rules are
#	$(CXX) -c $(CPPFLAGS) $(CXXFLAGS)
#	$(CC) $(LDFLAGS) N.o $(LOADLIBES) $(LDLIBS)

.PHONY:	all install uninstall build veryclean debug release lint item
.PHONY: buildDir
.PHONY:	testonly covonly
.PHONY:	test
.PHONY:	tools
.PHONY:	coverage coveragetest veraonly
.PHONY:	makeDep


.PRECIOUS: %.Dir


all:					build
install:				test debug release
	@$(MAKE) INSTALL_ACTIVE=YES	ActionInstall
uninstall:
	@$(MAKE) INSTALL_ACTIVE=YES	ActionUInstall
build:					test debug release
	@$(MAKE) INSTALL_ACTIVE=NO	ActionInstall
	@$(MAKE) done
release-only:			release
	@$(MAKE) INSTALL_ACTIVE=NO	ActionDoInstallHead ActionDoInstallRelease
veryclean:				clean
	@$(MAKE) INSTALL_ACTIVE=NO	ActionUInstall
debug:					makeDep
	@$(MAKE) TARGET_MODE=debug	item
release:				makeDep
	@$(MAKE) TARGET_MODE=release	item
lint:					doLint
item:					PrintDebug buildDir Note_Building_$(TARGET_MODE) $(TARGET_ITEM)
buildDir:	| $(TARGET_MODE).Dir coverage.Dir
%.Dir:
	@$(MKDIR) -p $*
testonly:				ActionRunUnitTest
covonly:				ActionRunCoverage
veraonly:				ActionRunVera
test:					makeDep ActionRunUnitTest ActionRunCoverage ActionRunVera
done:

clean: Note_Start_Local_Clean
	$(RM) -rf debug release coverage report makedependency $(META) test/coverage test/makedependency test/$(META) $(TMP_SRC) $(TMP_HDR) location.hh  position.hh  stack.hh *.gcov test/*.gcov stamp-h2


Note_%:
	@$(ECHO) $(call section_title, $(subst _, ,$*))
