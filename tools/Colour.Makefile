
#
# Also check out echo in the Platform.Makefile

DEFAULT_GTEST_COLOUR			= $(DEFAULT_GTEST_COLOUR_NV$(NEOVIM))
DEFAULT_GTEST_COLOUR_NVTRUE		= no
DEFAULT_GTEST_COLOUR_NVFALSE	= yes

DEFAULT_COLOUR					= $(DEFAULT_COLOUR_NV$(NEOVIM))
DEFAULT_COLOUR_NVFALSE			= ON
DEFAULT_COLOUR_NVTRUE			= OFF

COLOUR_STATE					?= $(DEFAULT_COLOUR)
MODE_TEXT_COLOR=$(if $(DARK_MODE), YELLOW, GRAY)



COLOUR_TERMINAL_NONE			= "\\033[0m"
COLOUR_TERMINAL_BLACK			= "\\033[0;30m"
COLOUR_TERMINAL_GRAY			= "\\033[1;30m"
COLOUR_TERMINAL_RED				= "\\033[0;31m"
COLOUR_TERMINAL_LIGHT_RED		= "\\033[1;31m"
COLOUR_TERMINAL_GREEN			= "\\033[0;32m"
COLOUR_TERMINAL_LIGHT_GREEN		= "\\033[1;32m"
COLOUR_TERMINAL_YELLOW			= "\\033[0;33m"
COLOUR_TERMINAL_LIGHT_YELLOW	= "\\033[1;33m"
COLOUR_TERMINAL_BLUE			= "\\033[0;34m"
COLOUR_TERMINAL_LIGTH_BLUE		= "\\033[1;34m"
COLOUR_TERMINAL_PURPLE			= "\\033[0;35m"
COLOUR_TERMINAL_LIGHT_PURPLE	= "\\033[1;35m"
COLOUR_TERMINAL_CYAN			= "\\033[0;36m"
COLOUR_TERMINAL_LIGHT_CYAN		= "\\033[1;36m"
COLOUR_TERMINAL_WHITE			= "\\033[1;37m"
COLOUR_TERMINAL_LIGHT_GRAY		= "\\033[0;37m"


colour_text						= $(call COLOUR_TEXT_$(COLOUR_STATE),$(1),$(2))
color_text						= $(call COLOUR_TEXT_$(COLOUR_STATE),$(1),$(2))
COLOUR_TEXT_ON					= $(COLOUR_TERMINAL_$(strip $(1)))$(strip $(2))$(COLOUR_TERMINAL_NONE)
COLOUR_TEXT_OFF					= $(2)

NEOVIM_COLOR_MARKER				= $(NEOVIM_COLOR_MARKER_NV$(NEOVIM))
NEOVIM_COLOR_MARKER_NVTRUE		= ":   "
NEOVIM_COLOR_MARKER_NVFALS		=

GREEN_OK						= $(call colour_text, GREEN, OK)$(NEOVIM_COLOR_MARKER)
RED_ERROR						= $(call colour_text, RED, ERROR)$(NEOVIM_COLOR_MARKER)
section_title					= $(call colour_text, BLUE, $(1))
subsection_title				= $(call colour_text, CYAN, "  $(1)")
paragraph						= $(call colour_text, $(MODE_TEXT_COLOR), "      $(1)")


toInt							= $(shell $(ECHO) "$(1)" | awk -F. '{print $$1+0}')
getPercentColour				= $(call colour_text, $(call GOOD_COLOUR_TEST, $(call toInt,$(1))), $(call toInt, $(1)))

GOOD_COLOUR_TEST				= $(shell if [ $(1) -ge 95 ]; then $(ECHO) "GREEN"; else if [ $(1) -ge 75 ]; then $(ECHO) "YELLOW"; else if [ $(1) -ge 50 ]; then $(ECHO) "PURPLE"; else $(ECHO) "RED"; fi fi fi)
GOOD_COLOUR_TEST1				= if [ $(1) -ge 95 ]; then $(ECHO) "GREEN"; else if [ $(1) -ge 75 ]; then $(ECHO) "YELLOW"; else if [ $(1) -ge 50 ]; then $(ECHO) "PURPLE"; else $(ECHO) "RED"; fi fi fi

