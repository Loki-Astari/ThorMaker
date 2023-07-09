#
# Standard ThorsAnvil Libraries.
#   This is a list of standard ThorLibraries.
#   We handle these differently in build files when they are included with
#       LDLIBS_EXTERN_BUILD
#   We will automatically add the normal ThorsAnvilExtension on the end.
#       ThorSerializer17D.dylib
#                     ^^            Built with std=c++17
#                       ^           Build with Debug flags (Noting for normal optimization
#
#   Note
#       LDLIBS_EXTERN_BUILD is a magic flag.
#       See tools/Makefile for details.
#
#	To set this up correctly:
#		In the following XXX is the library name after Thor (or Thors) in the list below but capitalized:
#		Int the followng YYY is the library name after Thor (or Thors) in camel case.
#			eg. ThorSerialize		XXX => SERIALIZE
#									YYY => Serialize
#
#		1: Add AX_THOR_FUNC_USE_THORS_LIB_XXX to to the configure.ac file.
#		2: Add YYY_2: Add ThorsYYY_ROOT_DIR
#						  ThorsYYY_ROOT_LIB to the Makefile.config.in
#		3: Add ThorsYYY to LDLIBS_EXTERN_BUILD in the appropriate Makefile.
#


ThorsMySQL_ISTHOR           = yes
ThorsPostgres_ISTHOR        = yes
ThorsSQL_ISTHOR             = yes
ThorSerialize_ISTHOR        = yes
ThorsDB_ISTHOR              = yes
ThorsExpress_ISTHOR         = yes
ThorsLogging_ISTHOR         = yes
ThorsSocket_ISTHOR          = yes
ThorsStorage_ISTHOR         = yes
