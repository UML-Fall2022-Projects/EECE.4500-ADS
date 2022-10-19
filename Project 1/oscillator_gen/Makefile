#---------------------------------
# Progress bar defs
#--------------------------------
#  words = count the number of words
ifneq ($(words $(MAKECMDGOALS)),1) # if no argument was given to make...
.DEFAULT_GOAL = all # set the default goal to all
#  http://www.gnu.org/software/make/manual/make.html
#  $@ = target name
#  %: = last resort recipe
#  --no-print-directory = don't print enter/leave messages for each output grouping
#  MAKEFILE_LIST = has a list of all the parsed Makefiles that can be found *.mk, Makefile, etc
#  -n = dry run, just print the recipes
#  -r = no builtin rules, disables implicit rules
#  -R = no builtin variables, disables implicit variables
#  -f = specify the name of the Makefile
%:                   # define a last resort default rule
	@$(MAKE) $@ --no-print-directory -rRf $(firstword $(MAKEFILE_LIST)) # recursive make call, 
else
ifndef ECHO
#  execute a dry run of make, defining echo beforehand, and count all the instances of "COUNTTHIS"
T := $(shell $(MAKE) $(MAKECMDGOALS) --no-print-directory \
    -nrRf $(firstword $(MAKEFILE_LIST)) \
    ECHO="COUNTTHIS" | grep -c "COUNTTHIS")
#  eval = evaluate the text and read the results as makefile commands
N := x
#  Recursively expand C for each instance of ECHO to count more x's
C = $(words $N)$(eval N := x $N)
#  Multipy the count of x's by 100, and divide by the count of "COUNTTHIS"
#  Followed by a percent sign
#  And wrap it all in square brackets
ECHO = echo -e "[`expr $C '*' 100 / $T`%]"
endif
#------------------
# end progress bar
#------------------

SHELL = /bin/sh

config ?= debug
platform ?= linux
arch ?= x86_64

TARGETROOTDIR ?= bin
OBJROOTDIR ?= bin-int

ifndef verbose
    SILENT = @
endif

OUTDIR := $(config)-$(platform)-$(arch)

OBJDIR := $(OBJROOTDIR)/$(OUTDIR)
TARGETDIR := $(TARGETROOTDIR)/$(OUTDIR)

ASSEMBLY := oscillator-gen
TARGET := $(TARGETDIR)/$(ASSEMBLY)

CXX := clang++
INCLUDES := -Isrc
WARNINGFLAGS := -Wall -Werror
CXXFLAGS := -std=c++17 $(INCLUDES) $(WARNINGFLAGS)
LDFLAGS := -fuse-ld=lld
DEFINES :=

ifeq ($(config),debug)
    ALL_DEFINES := $(DEFINES) -D_DEBUG
    ALL_CXXFLAGS := $(CXXFLAGS) $(ALL_DEFINES) -g -O0
    ALL_LDFLAGS := $(LDFLAGS) -g
else ifeq ($(config),release)
    ALL_DEFINES := $(DEFINES) -D_RELEASE
    ALL_CXXFLAGS := $(CXXFLAGS) $(ALL_DEFINES) -O2
    ALL_LDFLAGS := $(LDFLAGS) -s
endif

SRCDIR := src

SRCS := $(shell find $(SRCDIR)/ -type f -name '*.cpp')
OBJS := $(patsubst $(SRCDIR)/%.cpp, \
	$(OBJDIR)/%.o, $(SRCS))
DEPS := $(patsubst $(OBJDIR)/%.o, \
	$(OBJDIR)/%.d, $(OBJS))

.PHONY: all clean run

all: $(TARGET)

-include $(DEPS)

clean:
	@echo "Cleaning RingOscillator Generator"
	$(SILENT) rm -rf $(OBJROOTDIR)
	$(SILENT) rm -rf $(TARGETROOTDIR)

run: $(TARGET)
	@./$(TARGET)

$(TARGET): $(OBJS) | $(TARGETDIR)
	@$(ECHO) "\033[0;36mGenerating $@\033[0m"
	$(SILENT) $(CXX) -o $@ $(OBJS) $(ALL_LDFLAGS)

$(OBJDIR)/%.o: $(SRCDIR)/%.cpp | $(OBJDIR)
	@$(ECHO) "\033[0;32mBuilding CXX object $@\033[0m"
	$(SILENT) mkdir -p $(shell dirname $@)
	$(SILENT) $(CXX) -c -o $@ $< $(ALL_CXXFLAGS)

$(TARGETDIR):
	@$(ECHO) "\033[0;36mCreating $@\033[0m"
	$(SILENT) mkdir -p $@

$(OBJDIR):
	@$(ECHO) "\033[0;36mCreating $@\033[0m"
	$(SILENT) mkdir -p $@

endif
