# --------------------------------------------------------------------------------
# constants for colored output
# --------------------------------------------------------------------------------
RED      := \033[0;31m
GREEN    := \033[0;32m
YELLOW   := \033[0;33m
BLUE     := \033[0;34m
MAGENTA  := \033[0;35m
ORANGE   := \033[0;38;5;166m
RESET    := \033[0;0m

# --------------------------------------------------------------------------------
# Configuration
# --------------------------------------------------------------------------------
CFG_BLD_OUT_DIR     := build
CFG_EXT_OUT_DIR     := externals
CFG_OBJ_OUT_DIR     := Objects
CFG_BIN_OUT_DIR     := binaries
CFG_LIB_OUT_DIR     := libraries
CFG_RES_OUT_DIR     := resources
CFG_INS_OUT_DIR     := install
CFG_EXE_NAME        := app
CFG_CXX_COMP        := g++
CFG_CC_COMP         := gcc
CFG_CPPFLAGS        := -MMD -MP
CFG_CXXFLAGS        := -std=c++2b
CFG_LDFLAGS         := -Wall -Wpedantic -Wextra
CFG_LDLIBS          := -lpthread -lm

# --------------------------------------------------------------------------------
# Directories & Platform Detection
# --------------------------------------------------------------------------------
ifeq ($(OS),Windows_NT)
	PLATFORM    := windows
	EXE_SUFFIX  := .exe
else
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S),Darwin)
		PLATFORM   := macos
		EXE_SUFFIX :=
	else ifeq ($(UNAME_S),Linux)
		PLATFORM   := linux
		EXE_SUFFIX :=
	else
		$(error Unsupported platform: $(UNAME_S))
	endif
endif

CFG_PRJ_DIR  := $(CURDIR)
CFG_INC_DIR  := $(CFG_PRJ_DIR)/include
CFG_SRC_DIR  := $(CFG_PRJ_DIR)/source
CFG_RES_DIR  := $(CFG_PRJ_DIR)/resources
CFG_TEST_DIR := $(CFG_PRJ_DIR)/tests

BUILD_BASE := $(CFG_PRJ_DIR)/$(CFG_BLD_OUT_DIR)

# Release vs Debug
ifeq ($(release),1)
	BUILD_TYPE := release
	CXXFLAGS  += -O3 -DNDEBUG
else
	BUILD_TYPE := debug
	CXXFLAGS  += -O0 -g
endif

# GTest paths per platform
ifeq ($(PLATFORM),macos)
	GTEST_DIR ?= /opt/homebrew/opt/googletest
	GTEST_LIB := -L$(GTEST_DIR)/lib -lgtest -lgtest_main
	GTEST_INC := -I$(GTEST_DIR)/include
	ifeq ("$(wildcard $(GTEST_DIR)/lib/libgtest.a)","")
		$(error GTest not found at $(GTEST_DIR). Please run `brew install googletest`.)
	endif
else ifeq ($(PLATFORM),windows)
	GTEST_LIB := -lgtest -lgtest_main
	GTEST_INC :=
else
	GTEST_LIB := -lgtest -lgtest_main
	GTEST_INC := $(shell pkg-config --cflags gtest 2>/dev/null)
endif

# --------------------------------------------------------------------------------
# Output directories
# --------------------------------------------------------------------------------
OBJ_DIR      := $(BUILD_BASE)/$(PLATFORM)/$(CFG_OBJ_OUT_DIR)/$(BUILD_TYPE)
BIN_DIR      := $(BUILD_BASE)/$(PLATFORM)/$(CFG_BIN_OUT_DIR)/$(BUILD_TYPE)
LIB_DIR      := $(BUILD_BASE)/$(PLATFORM)/$(CFG_LIB_OUT_DIR)/$(BUILD_TYPE)
INS_DIR      := $(BUILD_BASE)/$(PLATFORM)/$(CFG_INS_OUT_DIR)/$(BUILD_TYPE)
EXT_DIR      := $(BUILD_BASE)/$(PLATFORM)/$(CFG_EXT_OUT_DIR)/$(BUILD_TYPE)
RES_COPY_DIR := $(BIN_DIR)

COMPILER := $(CFG_CXX_COMP)
CPPFLAGS  := $(CFG_CPPFLAGS) -I$(CFG_INC_DIR) -I$(CFG_SRC_DIR) $(GTEST_INC)
CXXFLAGS += $(CFG_CXXFLAGS)
LDFLAGS  += $(CFG_LDFLAGS)
LDLIBS   += $(CFG_LDLIBS)

# --------------------------------------------------------------------------------
# Sources, objects, dependencies (flat directories only)
# --------------------------------------------------------------------------------
SRCS_RELATIVE := $(wildcard $(CFG_SRC_DIR)/*.cpp)
SRCS_RELATIVE := $(patsubst $(CFG_SRC_DIR)/%,source/%,$(SRCS_RELATIVE))
MAIN_SRC     := source/main.cpp
SRCS_NO_MAIN := $(filter-out $(MAIN_SRC),$(SRCS_RELATIVE))

OBJS         := $(patsubst source/%.cpp,$(OBJ_DIR)/%.o,$(SRCS_RELATIVE))
OBJS_NO_MAIN := $(patsubst source/%.cpp,$(OBJ_DIR)/%.o,$(SRCS_NO_MAIN))
DEPS         := $(OBJS:.o=.d)

TEST_SRCS    := $(wildcard $(CFG_TEST_DIR)/*.cpp)
TEST_SRCS    := $(patsubst $(CFG_TEST_DIR)/%,tests/%,$(TEST_SRCS))
TEST_OBJS    := $(patsubst tests/%.cpp,$(OBJ_DIR)/tests/%.o,$(TEST_SRCS))
TEST_EXES    := $(patsubst tests/%.cpp,$(BIN_DIR)/tests/%$(EXE_SUFFIX),$(TEST_SRCS))

#----------------------------------------------------------------------------------
# Process arguments
#----------------------------------------------------------------------------------

ifeq ($(strip $(ARGS)),)
	ARGS :=
endif
# --------------------------------------------------------------------------------
# Targets
# --------------------------------------------------------------------------------
.PHONY: all
all: setup_dirs compile link setup_resources
	@printf "${GREEN}INFO:${RESET} Build Successful\n"

.PHONY: setup_dirs
setup_dirs:
	@printf "${BLUE}INFO:${RESET} Setting up directories\n"
	@mkdir -p $(OBJ_DIR) $(BIN_DIR) $(LIB_DIR) $(INS_DIR) $(EXT_DIR)
	@mkdir -p $(OBJ_DIR)/tests $(BIN_DIR)/tests
	@printf "${BLUE}INFO:${RESET} Setup complete\n"

# compile sources
$(OBJ_DIR)/%.o: source/%.cpp | setup_dirs
	@printf "${MAGENTA}INFO:${RESET} Compiling $<\n"
	@$(COMPILER) $(CPPFLAGS) $(CXXFLAGS) -c $< -o $@

.PHONY: compile
compile: $(OBJS)
	@printf "${GREEN}INFO:${RESET} Compilation Successful\n"

# link main
.PHONY: link
link: setup_dirs compile
	@printf "${BLUE}INFO:${RESET} Linking main executable\n"
	@$(COMPILER) $(LDFLAGS) $(OBJS) $(LDLIBS) -o $(BIN_DIR)/$(CFG_EXE_NAME)$(EXE_SUFFIX)
	@printf "${GREEN}INFO:${RESET} Linking Successful\n"

# build tests
.PHONY: test
test: setup_dirs $(TEST_EXES)
	@printf "${BLUE}INFO:${RESET} All tests built\n"

$(OBJ_DIR)/tests/%.o: tests/%.cpp | setup_dirs
	@printf "${MAGENTA}INFO:${RESET} Compiling test $<\n"
	@$(COMPILER) $(CPPFLAGS) $(CXXFLAGS) -c $< -o $@

$(BIN_DIR)/tests/%$(EXE_SUFFIX): $(OBJ_DIR)/tests/%.o $(OBJS_NO_MAIN) | setup_dirs
	@printf "${BLUE}INFO:${RESET} Linking test $@\n"
	@$(COMPILER) $(LDFLAGS) $^ $(GTEST_LIB) $(LDLIBS) -o $@
	@printf "${GREEN}INFO:${RESET} Linking Successful\n"

.PHONY: run_tests
run_tests: test
	@printf "${BLUE}INFO:${RESET} Running tests\n"
	@for t in $(TEST_EXES); do $$t; done

.PHONY: run_test
run_test:
	@printf "${BLUE}INFO:${RESET} Running test binary: $(TEST)\n"
	@$(BIN_DIR)/tests/$(TEST)$(EXE_SUFFIX)

.PHONY: test_clean
test_clean:
	@printf "${BLUE}INFO:${RESET} Cleaning test files\n"
	@rm -rf $(OBJ_DIR)/tests $(BIN_DIR)/tests
	@printf "${GREEN}INFO:${RESET} Test cleanup complete\n"

.PHONY: setup_resources
setup_resources:
	@printf "${BLUE}INFO:${RESET} Copying resources\n"
	@cp -r $(CFG_RES_DIR)/. $(RES_COPY_DIR)/ 2>/dev/null || :
	@printf "${GREEN}INFO:${RESET} Resources copied\n"

.PHONY: run
run: all
	@printf "${BLUE}INFO:${RESET} Executing program: $(BIN_DIR)/$(CFG_EXE_NAME)$(EXE_SUFFIX) $(ARGS)\n"
	@$(BIN_DIR)/$(CFG_EXE_NAME)$(EXE_SUFFIX) $(ARGS)
	@printf "${GREEN}INFO:${RESET} Program finished\n"

.PHONY: install
install: all setup_resources
	@printf "${BLUE}INFO:${RESET} Installing to $(INS_DIR)\n"
	@cp -r $(BIN_DIR)/. $(INS_DIR)/
	@printf "${GREEN}INFO:${RESET} Install complete\n"

.PHONY: clean
clean:
	@printf "${BLUE}INFO:${RESET} Cleaning build artifacts\n"
	@rm -rf $(BUILD_BASE)
	@printf "${GREEN}INFO:${RESET} Clean complete\n"

.PHONY: help
help:
	@printf "Usage: make [target] [release=1]\n\n"
	@printf "Targets:\n"
	@printf "  all         : build everything\n"
	@printf "  compile     : compile only\n"
	@printf "  link        : link executable\n"
	@printf "  run         : run program\n"
	@printf "  test        : build test executables\n"
	@printf "  run_tests   : build and run all tests\n"
	@printf "  run_test    : run a specific test: TEST=name\n"
	@printf "  test_clean  : clean only test files\n"
	@printf "  install     : copy to install folder\n"
	@printf "  clean       : full cleanup\n"
	@printf "  help        : show this help\n"

-include $(DEPS)