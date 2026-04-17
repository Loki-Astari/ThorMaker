# =============================================================================
# core/thors-anvil-libs.mk — data table of "our" ThorsAnvil libraries
#
# Libraries listed here get the ThorsAnvil build-extension appended
# automatically when referenced via LDLIBS_EXTERN_BUILD.
#
# Requires: (nothing)
# Defines:  <LibName>_ISTHOR = yes   for each ThorsAnvil-owned library
# Goals:    (none)
#
# To add a new library:
#   1) Add AX_THOR_FUNC_USE_THORS_LIB_XXX to configure.ac
#   2) Add ThorsYYY_ROOT_DIR and ThorsYYY_ROOT_LIB to Makefile.config.in
#   3) Add ThorsYYY to LDLIBS_EXTERN_BUILD in the relevant project Makefile
#   4) Add a line here: ThorsYYY_ISTHOR = yes
# =============================================================================

ThorsMySQL_ISTHOR           = yes
ThorsPostgres_ISTHOR        = yes
ThorsSQL_ISTHOR             = yes
ThorSerialize_ISTHOR        = yes
ThorsDB_ISTHOR              = yes
ThorsExpress_ISTHOR         = yes
ThorsLogging_ISTHOR         = yes
ThorsSocket_ISTHOR          = yes
ThorsStorage_ISTHOR         = yes
Nisse_ISTHOR				= yes
