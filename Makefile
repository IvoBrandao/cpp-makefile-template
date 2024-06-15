# --------------------------------------------------------------------------------
# constants
# --------------------------------------------------------------------------------
RED=\033[0;31m
GREEN=\033[0;32m
YELLOW=\033[0;33m
BLUE=\033[0;34m
MAGENTA=\033[0;35m
ORANGE=\033[0;38;5;166m
RESET=\033[0m
# --------------------------------------------------------------------------------
# Configuration
# --------------------------------------------------------------------------------

# Configures the build directory location
CFG_BLD_OUT_DIR = build
# Configures the directory for external projects
CFG_EXT_OUT_DIR = externals
# Configures the output directories for objects 
CFG_OBJ_OUT_DIR = objects
# Configures the output directories for binaries
CFG_BIN_OUT_DIR = binaries
# Configures the output directories for libraries
CFG_LIB_OUT_DIR = libraries
# Configures the output directories for resources
CFG_RES_OUT_DIR = resources
# Configures the output directories where the instalation will happen
CFG_INS_OUT_DIR = install
# Configures the test directory
CFG_TST_DIR = tests
# Configures the executable name
CFG_EXE_NAME = app
# Configures the test executable name
CFG_TST_EXE_PREFIX = $(CFG_EXE_NAME)_test_
# Configures the compiler
CFG_CXX_COMP = g++
# Configures the preprocessor flags
CFG_CC_COMP = gcc

# Configures the compiler flags (--MMD - generate dependencies, --MP - add phony target for each dependency)
CFG_CPPFLAGS = -MMD -MP

# Configures the compiler flags for C++ standard (C++2b is the default standard)
CFG_CXXFLAGS = -std=c++2b

# Configures the linker flags (Wall - enable all warnings, Wpedantic - enable pedantic warnings, Wextra - enable extra warnings)
CFG_LDFLAGS = -Wall -Wpedantic -Wextra 

# Configures the linker flags for the libraries 
CFG_LDLIBS = 

# Configures the source files
CFG_SRC_FILES = *.cpp

# Configures the includes for the OS
CFG_OS_INCLUDES =

# Configures the release and debug flags (O3 - optimize for speed, NDEBUG - disable assertions)
CFG_RELEASE_FLAGS = -O3 -DNDEBUG

# Configures the debug flags (O0 - disable optimizations, g - generate debug information)
CFG_DEBUG_FLAGS = -O0 -g

# Configures the echo command
ECHO = echo
# --------------------------------------------------------------------------------
# Project settings
# --------------------------------------------------------------------------------
CFG_PRJ_DIR = $(shell pwd)
CFG_INC_DIR = $(CFG_PRJ_DIR)/include
CFG_SRC_DIR = $(CFG_PRJ_DIR)/source
CFG_RES_DIR = $(CFG_PRJ_DIR)/resources

CFG_COMP = $(CFG_CXX_COMP)
CPPFLAGS += $(CFG_CPPFLAGS)
CXXFLAGS += $(CFG_CXXFLAGS)
LDFLAGS += $(CFG_LDFLAGS)
LDLIBS += $(CFG_LDLIBS)
COMPILER = $(CFG_COMP)

# Target OS detection
ifeq ($(OS),Windows_NT)
	OS = windows
	EXE_NAME = $(CFG_EXE_NAME).exe
	TST_EXE_EXT = .exe
	# Windows specific settings (static linking for GCC on Windows)
	LDFLAGS += -static-libgcc -static-libstdc++
	OS_INCLUDES +=
	LDLIBS +=
	# 64-bit build settings
	CXXFLAGS += -m64
	CPPFLAGS +=
else
	UNAME := $(shell uname -s)
	ifeq ($(UNAME),Darwin)
		OS = macos
		EXE_NAME = $(CFG_EXE_NAME)
		TST_EXE_EXT =
		OS_INCLUDES +=
		LDFLAGS +=
		# (pthread - POSIX threads, m - math library)
		LDLIBS += -lpthread -lm
		CXXFLAGS +=
		CPPFLAGS +=
	else ifeq ($(UNAME),Linux)
		OS = linux
		EXE_NAME = $(CFG_EXE_NAME)
		TST_EXE_EXT =
		OS_INCLUDES +=
		LDFLAGS += 
		# (pthread - POSIX threads, m - math library)
		LDLIBS += -lpthread -lm
		CXXFLAGS +=
		CPPFLAGS +=
	else
    	$(error OS not supported by this Makefile)
	endif
endif

# Debug (default) and release modes settings
ifeq ($(release),1)
	BLD_DIR := $(BLD_DIR)/release
	CXXFLAGS += $(CFG_RELEASE_FLAGS)
else
	BLD_DIR := $(BLD_DIR)/debug
	CXXFLAGS += $(CFG_DEBUG_FLAGS)
endif

# --------------------------------------------------------------------------------
# main app settings
# --------------------------------------------------------------------------------

CPP_BLD_DIR = $(CFG_PRJ_DIR)/$(CFG_BLD_OUT_DIR)/$(OS)
CPP_CLS_DIR = $(CFG_PRJ_DIR)/$(CFG_BLD_OUT_DIR)/$(OS)
CPP_BIN_DIR = $(CPP_BLD_DIR)/$(CFG_BIN_OUT_DIR)/app
CPP_OBJ_DIR = $(CPP_BLD_DIR)/$(CFG_OBJ_OUT_DIR)/app
CPP_LIB_DIR = $(CPP_BLD_DIR)/$(CFG_LIB_OUT_DIR)/app
CPP_INS_DIR = $(CPP_BLD_DIR)/$(CFG_INS_OUT_DIR)/app
CPP_EXT_DIR = $(CPP_BLD_DIR)/$(CFG_EXT_OUT_DIR)/app

SRCS := $(sort $(shell find $(CFG_SRC_DIR) -name $(CFG_SRC_FILES)))
INCS := -I$(CFG_INC_DIR) -I$(CFG_SRC_DIR) -I$(CFG_OS_INCLUDES)
OBJS := $(SRCS:$(CFG_SRC_DIR)/%.cpp=$(CPP_OBJ_DIR)/%.o)
DEPS := $(OBJS:.o=.d)
CPPFLAGS += $(INCS)

# --------------------------------------------------------------------------------
# Test settings
# --------------------------------------------------------------------------------
# Define directories
TST_BLD_DIR := $(CFG_PRJ_DIR)/$(CFG_BLD_OUT_DIR)/$(OS)
TST_BIN_DIR := $(TST_BLD_DIR)/$(CFG_BIN_OUT_DIR)/tests
TST_OBJ_DIR := $(TST_BLD_DIR)/$(CFG_OBJ_OUT_DIR)/tests
TST_LIB_DIR := $(TST_BLD_DIR)/$(CFG_LIB_OUT_DIR)/tests
TST_INS_DIR := $(TST_BLD_DIR)/$(CFG_INS_OUT_DIR)/tests
TST_EXT_DIR := $(TST_BLD_DIR)/$(CFG_EXT_OUT_DIR)/tests
TST_SRC_DIR := $(CFG_PRJ_DIR)/$(CFG_TST_DIR)
TST_INC_DIR := $(TST_SRC_DIR)/include

# Directory for Google Test framework
GTEST_DIR := $(TST_EXT_DIR)/googletest
# Google Test include directory
GTEST_INCLUDE := $(GTEST_DIR)/googletest/include
# Google Test libraries
GTEST_LIB := $(GTEST_DIR)/build/lib/libgtest.a $(GTEST_DIR)/build/lib/libgtest_main.a
GMOCK_LIB := $(GTEST_DIR)/build/lib/libgmock.a $(GTEST_DIR)/build/lib/libgmock_main.a

# Source files and objects
TST_SRCS := $(sort $(shell find $(TST_SRC_DIR) -name *.cpp))
TST_OBJS := $(TST_SRCS:$(TST_SRC_DIR)/%.cpp=$(TST_OBJ_DIR)/%.o)
TST_DEPS := $(TST_OBJS:.o=.d)
TST_BINS := $(TST_SRCS:$(TST_SRC_DIR)/%.cpp=$(TST_BIN_DIR)/$(CFG_TST_EXE_PREFIX)%)

# Compiler and linker flags
TST_COMPILER := $(CFG_CXX_COMP)
TST_CPPFLAGS := -MMD -MP -I$(TST_INC_DIR) -I$(GTEST_INCLUDE)
TST_CXXFLAGS := -std=c++2b -O0 -g
TST_LDFLAGS := -pthread -L$(TST_LIB_DIR)
TST_LDLIBS := $(GTEST_LIB) -lgtest -lgtest_main -lgmock -lgmock_main


# --------------------------------------------------------------------------------
# all Targets
# --------------------------------------------------------------------------------

.PHONY: all
all: resources format build test_build
	@$(ECHO) " --------------------------------------------------------------------------------"
	@$(ECHO) "${GREEN} INFO:${RESET} Build Successful"
# --------------------------------------------------------------------------------
# Setting up the project directories
# --------------------------------------------------------------------------------
.PHONY: setup_app
setup_app: 
	@$(ECHO) " --------------------------------------------------------------------------------"
	@$(ECHO) "${BLUE} INFO:${RESET} Setting up the project."
	@$(ECHO) "${YELLOW} INFO:${RESET} Create dir: $(CPP_BIN_DIR)"
	@mkdir -p $(CPP_BIN_DIR)
	@$(ECHO) "${YELLOW} INFO:${RESET} Create dir: $(CPP_OBJ_DIR)"
	@mkdir -p $(CPP_OBJ_DIR)
	@$(ECHO) "${YELLOW} INFO:${RESET} Create dir: $(CPP_LIB_DIR)"
	@mkdir -p $(CPP_LIB_DIR)
	@$(ECHO) "${YELLOW} INFO:${RESET} Create dir: $(CPP_INS_DIR)"
	@mkdir -p $(CPP_INS_DIR)
	@$(ECHO) "${YELLOW} INFO:${RESET} Create dir: $(CPP_EXT_DIR)"
	@mkdir -p $(CPP_EXT_DIR)
	@$(ECHO) "${GREEN} INFO:${RESET} Setup Successful"
	@$(ECHO) "${BLUE} INFO:${RESET} Setting up build directory permissions"
	@chmod -R u+w $(CFG_BLD_OUT_DIR)
	@$(ECHO) "${GREEN} INFO:${RESET} Permissions set"

# --------------------------------------------------------------------------------
# Compiling the source files
# --------------------------------------------------------------------------------

.PHONY: compile
compile:  
	@$(ECHO) " --------------------------------------------------------------------------------"
	@$(ECHO) "${BLUE} INFO:${RESET} Compling Sources Files"
	@mkdir -p $(CPP_OBJ_DIR)
	@$(foreach src,$(SRCS), \
		$(ECHO) "${MAGENTA} INFO:${RESET} Compiling: $(abspath $(src))"; \
		$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c $(src) -o $(CPP_OBJ_DIR)/$(notdir $(src:.cpp=.o)); \
	)
	@$(ECHO) "${GREEN} INFO:${RESET} Compilation Successful"

# --------------------------------------------------------------------------------
# Linking the object files
# --------------------------------------------------------------------------------

.PHONY: link
link: compile
	@$(ECHO) " --------------------------------------------------------------------------------"
	@$(ECHO) "${BLUE} INFO:${RESET} Linking object to executable"
	@$(CXX) $(LDFLAGS) $(OBJS) $(LDLIBS) -o $(CPP_BIN_DIR)/$(EXE_NAME)
	@$(ECHO) "${GREEN} INFO:${RESET} Linking Successful"


# --------------------------------------------------------------------------------
# build the program
# --------------------------------------------------------------------------------
.phony: build
build: setup_app link
	@$(ECHO) " --------------------------------------------------------------------------------"
	@$(ECHO) "${GREEN} INFO:${RESET} Build Successful"

# --------------------------------------------------------------------------------
# Running the program
# --------------------------------------------------------------------------------

.PHONY: run
run: all
	@$(ECHO) " --------------------------------------------------------------------------------"
	@$(ECHO) "${BLUE} INFO:${RESET} Executing program: $(CPP_BIN_DIR)/$(EXE_NAME)"
	@cd $(CPP_BIN_DIR); ./$(EXE_NAME); cd $(CFG_PRJ_DIR)
	@$(ECHO) "${GREEN} INFO:${RESET} Program finished"

# --------------------------------------------------------------------------------
# Cleaning up the build directory
# --------------------------------------------------------------------------------

.PHONY: clean
clean:
	@$(ECHO) " --------------------------------------------------------------------------------"
	@$(ECHO) "${BLUE} INFO:${RESET} Try to clean up build directory $(CPP_CLS_DIR)"
	@rm -rf $(CPP_CLS_DIR)
	@if [ ! -d "$(CPP_CLS_DIR)" ]; then \
		$(ECHO) "${GREEN} INFO:${RESET} Clean up successful"; \
	else \
		$(ECHO) "${RED} ERROR:${RESET} Clean up failed"; \
	fi

# --------------------------------------------------------------------------------
# Packaging the program to the install directory
# --------------------------------------------------------------------------------

.PHONY: install
install: all resources
	@$(ECHO) " --------------------------------------------------------------------------------"
	@$(ECHO) "${BLUE} INFO:${RESET} Packaging program to $(CPP_INS_DIR)"
	@mkdir -p $(CPP_INS_DIR); cp -r $(CPP_BIN_DIR)/. $(CPP_INS_DIR)
	@$(ECHO) "${GREEN} INFO:${RESET} Packaging done."

# --------------------------------------------------------------------------------
# Copying resources to the binary directory
# --------------------------------------------------------------------------------

.PHONY: resources
resources:
	@$(ECHO) " --------------------------------------------------------------------------------"
	@$(ECHO) "${BLUE} INFO:${RESET} Copying resources from $(CFG_RES_DIR) to $(CPP_BIN_DIR)"
	@mkdir -p $(CPP_BIN_DIR)
	@cp -r $(CFG_RES_DIR)/. $(CPP_BIN_DIR)/
	@cp -r $(CFG_RES_DIR)/. $(CPP_BIN_DIR)/ 2> /dev/null || :	
	@$(ECHO) "${GREEN} INFO:${RESET} Resources copied."

# --------------------------------------------------------------------------------
# Formatting files
# --------------------------------------------------------------------------------

.PHONY: format
format:
	@$(ECHO) " --------------------------------------------------------------------------------"
	@$(ECHO) "${BLUE} INFO:${RESET} Formatting source files"
	@if [ ! -f ".clang-format" ]; then \
		echo "${BLUE} INFO:${RESET} Creating .clang-format file"; \
		clang-format -style=google -dump-config > .clang-format; \
		echo "${GREEN} INFO:${RESET} .clang-format file created"; \
	fi

	@if [ -d "$(CFG_SRC_DIR)" ]; then \
		clang-format -i $(CFG_SRC_DIR)/*.cpp; \
	fi

	@if [ -d "$(CFG_INC_DIR)" ]; then \
		clang-format -i $(CFG_INC_DIR)/*.hpp; \
	fi

	@if [ -d "$(CFG_TST_DIR)" ]; then \
		clang-format -i $(CFG_TST_DIR)/*.cpp; \
	fi

	@if [ -d "$(CFG_TST_DIR)/include" ]; then \
		clang-format -i $(CFG_TST_DIR)/include/*.hpp; \
	fi
	@$(ECHO) "${GREEN} INFO:${RESET} Formatting done."

# --------------------------------------------------------------------------------
# test setup framework
# --------------------------------------------------------------------------------
.PHONY: test_setup
test_setup:
	@$(ECHO) " --------------------------------------------------------------------------------"
	@$(ECHO) "${BLUE} INFO:${RESET} Setting up test project."
	@mkdir -p $(TST_BIN_DIR) $(TST_OBJ_DIR) $(TST_LIB_DIR) $(TST_INS_DIR) $(TST_EXT_DIR)
	@$(ECHO) "${GREEN} INFO:${RESET} Setup Successful"
	@$(ECHO) "${BLUE} INFO:${RESET} Setting up build directory permissions"
	@chmod -R u+w $(TST_BLD_DIR)
	@$(ECHO) "${GREEN} INFO:${RESET} Permissions set"
	@$(ECHO) "${BLUE} INFO:${RESET} Project Details"
	@$(ECHO) "${YELLOW} INFO:${RESET} Host system   : $(OS)"
	@$(ECHO) "${GREEN} INFO:${RESET} Test project setup complete"
	@$(ECHO) "${BLUE} INFO:${RESET} Setting up Google Test framework"
	@if [ ! -d "$(GTEST_DIR)" ]; then \
		echo "${YELLOW} INFO:${RESET} Cloning Google Test"; \
		git clone https://github.com/google/googletest.git $(GTEST_DIR); \
	else \
		echo "${GREEN} INFO:${RESET} Google Test already exists"; \
	fi

	@$(ECHO) "${BLUE} INFO:${RESET} Building Google Test"
	@mkdir -p $(GTEST_DIR)/build
	@cd $(GTEST_DIR)/build && cmake .. && make > /dev/null
	@$(ECHO) "${YELLOW} INFO:${RESET} Copying Google Test/Google Mock libraries"
	@cp $(GTEST_LIB) $(TST_LIB_DIR)
	@cp $(GMOCK_LIB) $(TST_LIB_DIR)
	@$(ECHO) "${GREEN} INFO:${RESET} Google Test/Google Mock libraries copied"
	@$(ECHO) "${GREEN} INFO:${RESET} Google Test setup complete"


# --------------------------------------------------------------------------------
# test compile
# --------------------------------------------------------------------------------
.PHONY: test_compile
test_compile: test_setup $(TST_OBJS)
	@$(ECHO) " --------------------------------------------------------------------------------"
	@$(ECHO) "${GREEN} INFO:${RESET} Compilation Successful"
$(TST_OBJ_DIR)/%.o: $(TST_SRC_DIR)/%.cpp
	@$(ECHO) "${YELLOW} INFO:${RESET} Compiling $<"
	@mkdir -p $(dir $@)
	$(TST_COMPILER) $(TST_CPPFLAGS) $(TST_CXXFLAGS) -c $< -o $@

-include $(DEPS)


# --------------------------------------------------------------------------------
# test link
# --------------------------------------------------------------------------------
.PHONY: test_link
test_link: test_compile $(TST_BINS)
	@$(ECHO) " --------------------------------------------------------------------------------"
	@$(ECHO) "${GREEN} INFO:${RESET} Linking Successful"

$(TST_BIN_DIR)/$(CFG_TST_EXE_PREFIX)%: $(TST_OBJ_DIR)/%.o
	@$(ECHO) "${YELLOW} INFO:${RESET} Linking $@"
	@mkdir -p $(dir $@)
	$(TST_COMPILER) $< $(TST_LDFLAGS) $(TST_LDLIBS) -o $@

# --------------------------------------------------------------------------------
# test build
# --------------------------------------------------------------------------------
.PHONY: test_build
test_build: test_setup test_compile test_link
	@$(ECHO) " --------------------------------------------------------------------------------"
	@$(ECHO) "${GREEN} INFO:${RESET} Build Successful"
	@$(ECHO) ""

# --------------------------------------------------------------------------------
# test run
# --------------------------------------------------------------------------------
.PHONY: test
test: test_link
	@$(ECHO) " --------------------------------------------------------------------------------"
	@$(ECHO) "${GREEN} INFO:${RESET} Running all tests"

	@for test_bin in $(TST_BINS); do \
		echo "${YELLOW} INFO:${RESET} Running $$test_bin"; \
		$$test_bin; \
	done

	@$(ECHO) "${GREEN} INFO:${RESET} All tests Executed"

# --------------------------------------------------------------------------------
# test clean
# --------------------------------------------------------------------------------
.PHONY: test_clean
test_clean:
	@$(ECHO) " --------------------------------------------------------------------------------"
	@$(ECHO) "${BLUE} INFO:${RESET} Cleaning up"
	@rm -rf $(TST_BIN_DIR) $(TST_OBJ_DIR) $(TST_LIB_DIR) $(TST_INS_DIR) $(TST_EXT_DIR)
	@$(ECHO) "${GREEN} INFO:${RESET} Clean complete"

# --------------------------------------------------------------------------------
.PHONY: help
help: 
	@$(ECHO) " "
	@$(ECHO) "Usage: $(MAGENTA)make${RESET} ${GREEN}[target]${RESET} $(YELLOW)[options]${RESET}"
	@$(ECHO) " "
	@$(ECHO) "Application Targets:"
	@$(ECHO) "  ${GREEN}all          ${RESET}- (default) compiles and links the program and tests"
	@$(ECHO) "  ${GREEN}setup_app    ${RESET}- creates the build directory structure"
	@$(ECHO) "  ${GREEN}compile      ${RESET}- compiles the source files"
	@$(ECHO) "  ${GREEN}link         ${RESET}- links the object files"
	@$(ECHO) "  ${GREEN}build        ${RESET}- compiles and links the program"
	@$(ECHO) "  ${GREEN}run          ${RESET}- runs the program"
	@$(ECHO) "  ${GREEN}clean        ${RESET}- removes the build directory"
	@$(ECHO) "  ${GREEN}install      ${RESET}- packages the program to the install directory"
	@$(ECHO) "  ${GREEN}resources    ${RESET}- copies the resources to the binary directory"
	@$(ECHO) "  ${GREEN}format       ${RESET}- formats the source files"
	@$(ECHO) " "
	@$(ECHO) "Test Targets: "
	@$(ECHO) "  ${GREEN}test_setup   ${RESET}- sets up the test project"
	@$(ECHO) "  ${GREEN}test_compile ${RESET}- compiles the test source files"
	@$(ECHO) "  ${GREEN}test_link    ${RESET}- links the test object files"
	@$(ECHO) "  ${GREEN}test_clean   ${RESET}- removes the test build directory"
	@$(ECHO) "  ${GREEN}test         ${RESET}- builds and runs the tests"
	@$(ECHO) "  ${GREEN}help         ${RESET}- prints this help message"
	@$(ECHO) " "
	@$(ECHO) "Options:"
	@$(ECHO) "  $(YELLOW)release=1 ${RESET} - compiles the program in release mode"
	@$(ECHO) " "
	@$(ECHO) "Examples:"
	@$(ECHO) " $(MAGENTA)make ${RESET}"
	@$(ECHO) " $(MAGENTA)make ${RESET}${GREEN}help      ${RESET}"
	@$(ECHO) " $(MAGENTA)make ${RESET}${GREEN}all       ${RESET}"
	@$(ECHO) " $(MAGENTA)make ${RESET}${GREEN}release=1 ${RESET}"
	@$(ECHO) " $(MAGENTA)make ${RESET}${GREEN}compile   ${RESET}"
	@$(ECHO) " $(MAGENTA)make ${RESET}${GREEN}link      ${RESET}"
	@$(ECHO) " $(MAGENTA)make ${RESET}${GREEN}build     ${RESET}"
	@$(ECHO) " $(MAGENTA)make ${RESET}${GREEN}clean     ${RESET}"
	@$(ECHO) " $(MAGENTA)make ${RESET}${GREEN}install   ${RESET}"
	@$(ECHO) " $(MAGENTA)make ${RESET}${GREEN}run       ${RESET}"
	@$(ECHO) " $(MAGENTA)make ${RESET}${GREEN}resources ${RESET}"
	@$(ECHO) " $(MAGENTA)make ${RESET}${GREEN}format    ${RESET}"
	@$(ECHO) " $(MAGENTA)make ${RESET}${GREEN}test_setup${RESET}"
	@$(ECHO) " $(MAGENTA)make ${RESET}${GREEN}test_compile${RESET}"
	@$(ECHO) " $(MAGENTA)make ${RESET}${GREEN}test_link${RESET}"
	@$(ECHO) " $(MAGENTA)make ${RESET}${GREEN}test_clean${RESET}"
	@$(ECHO) " $(MAGENTA)make ${RESET}${GREEN}test      ${RESET}"
	@$(ECHO) " "

