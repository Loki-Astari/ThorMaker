

COLOUR_STATE					?= ON


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

GREEN_OK						= $(call colour_text, GREEN, OK)
RED_ERROR						= $(call colour_text, RED, ERROR)
section_title					= $(call colour_text, BLUE, $(1))
subsection_title				= $(call colour_text, CYAN, "  $(1)")


toInt							= $(shell echo "$(1)" | awk -F. '{print $$1+0}')
getPercentColour				= $(call colour_text, $(call GOOD_COLOUR_TEST, $(call toInt,$(1))), $(call toInt, $(1)))

GOOD_COLOUR_TEST				= $(shell if [ $(1) -ge 95 ]; then echo "GREEN"; else if [ $(1) -ge 75 ]; then echo "YELLOW"; else if [ $(1) -ge 50 ]; then echo "PURPLE"; else echo "RED"; fi fi fi)
GOOD_COLOUR_TEST1				= if [ $(1) -ge 95 ]; then echo "GREEN"; else if [ $(1) -ge 75 ]; then echo "YELLOW"; else if [ $(1) -ge 50 ]; then echo "PURPLE"; else echo "RED"; fi fi fi

