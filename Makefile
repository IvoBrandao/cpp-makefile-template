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
CFG_BLD_OUT_DIR = build
CFG_EXT_OUT_DIR = externals
CFG_OBJ_OUT_DIR = Objects
CFG_BIN_OUT_DIR = binaries
CFG_LIB_OUT_DIR = libraries
CFG_RES_OUT_DIR = resources
CFG_INS_OUT_DIR = install
CFG_EXE_NAME = app
CFG_CXX_COMP = g++
CFG_CC_COMP = gcc
CFG_CPPFLAGS = -MMD -MP
CFG_CXXFLAGS = -std=c++2b
CFG_LDFLAGS = -Wall -Wpedantic -Wextra 
CFG_LDLIBS = -lpthread -lm
CFG_SRC_FILES = *.cpp
CFG_OS_INCLUDES =
CFG_RELEASE_FLAGS = -O3 -DNDEBUG
CFG_DEBUG_FLAGS = -O0 -g
ECHO = echo
# --------------------------------------------------------------------------------
# Project settings
# --------------------------------------------------------------------------------
CFG_PRJ_DIR = $(shell pwd)
CFG_INC_DIR = $(CFG_PRJ_DIR)/include
CFG_SRC_DIR = $(CFG_PRJ_DIR)/source
CFG_RES_DIR = $(CFG_PRJ_DIR)/resources
CFG_TST_DIR = $(CFG_PRJ_DIR)/test
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
	LDFLAGS += -static-libgcc -static-libstdc++
	OS_INCLUDES +=
	LDLIBS +=
	CXXFLAGS += -m64
	CPPFLAGS +=
else
	UNAME := $(shell uname -s)
	ifeq ($(UNAME),Darwin)
		OS = macos
		EXE_NAME = $(CFG_EXE_NAME)
		OS_INCLUDES +=
		LDFLAGS +=
		LDLIBS +=
		CXXFLAGS +=
		CPPFLAGS +=
	else ifeq ($(UNAME),Linux)
		OS = linux
		EXE_NAME = $(CFG_EXE_NAME)
		OS_INCLUDES +=
		LDFLAGS += 
		LDLIBS +=
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

# ----------------------------------------------------------
CPP_BLD_DIR = $(CFG_PRJ_DIR)/$(CFG_BLD_OUT_DIR)/$(OS)
CPP_CLS_DIR = $(CFG_PRJ_DIR)/$(CFG_BLD_OUT_DIR)
CPP_BIN_DIR = $(CPP_BLD_DIR)/$(CFG_BIN_OUT_DIR)
CPP_OBJ_DIR = $(CPP_BLD_DIR)/$(CFG_OBJ_OUT_DIR)
CPP_LIB_DIR = $(CPP_BLD_DIR)/$(CFG_LIB_OUT_DIR)
CPP_INS_DIR = $(CPP_BLD_DIR)/$(CFG_INS_OUT_DIR)
CPP_EXT_DIR = $(CPP_BLD_DIR)/$(CFG_EXT_OUT_DIR)
SRCS := $(sort $(shell find $(CFG_SRC_DIR) -name $(CFG_SRC_FILES)))
INCS := -I$(CFG_INC_DIR) -I$(CFG_SRC_DIR) $(CFG_OS_INCLUDES)
OBJS := $(SRCS:$(CFG_SRC_DIR)/%.cpp=$(CPP_OBJ_DIR)/%.o)
DEPS := $(OBJS:.o=.d)
CPPFLAGS += $(INCS)

# --------------------------------------------------------------------------------
.PHONY: all
all: setup_project compile link setup_resources
	@$(ECHO) "${GREEN} INFO:${RESET} Build Successful"
	@$(ECHO) ""

# --------------------------------------------------------------------------------
.PHONY: setup_project
setup_project:
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
	@$(ECHO) ""
	@$(ECHO) "${BLUE} INFO:${RESET} Project Details" 
	@$(ECHO) "${YELLOW} INFO:${RESET} Compiler flags: $(CPPFLAGS) $(CXXFLAGS)"
	@$(ECHO) "${YELLOW} INFO:${RESET} Linker flags  : $(LDFLAGS)"
	@$(ECHO) "${YELLOW} INFO:${RESET} Link Libraries: $(LDLIBS)"
	@$(ECHO) "${YELLOW} INFO:${RESET} project name  : $(EXE_NAME)"
	@$(ECHO) "${YELLOW} INFO:${RESET} host system   : $(OS)"
	@$(ECHO) ""

# --------------------------------------------------------------------------------
.PHONY: compile
compile: setup_project 
	@$(ECHO) "${BLUE} INFO:${RESET} Compling Sources Files"
	@mkdir -p $(CPP_OBJ_DIR)
	@$(foreach src,$(SRCS), \
		$(ECHO) "${MAGENTA} INFO:${RESET} Compiling: $(abspath $(src))"; \
		$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c $(src) -o $(CPP_OBJ_DIR)/$(notdir $(src:.cpp=.o)); \
	)
	@$(ECHO) "${GREEN} INFO:${RESET} Compilation Successful"
	@$(ECHO) ""

# --------------------------------------------------------------------------------
.PHONY: link
link: compile
	@$(ECHO) "${BLUE} INFO:${RESET} Linking object to executable"
	@$(CXX) $(LDFLAGS) $(OBJS) $(LDLIBS) -o $(CPP_BIN_DIR)/$(EXE_NAME)
	@$(ECHO) "${GREEN} INFO:${RESET} Linking Successful"
	@$(ECHO) ""

# --------------------------------------------------------------------------------
.PHONY: run
run: all
	@$(ECHO) "${BLUE} INFO:${RESET} Executing program: $(CPP_BIN_DIR)/$(EXE_NAME)"
	@cd $(CPP_BIN_DIR); ./$(EXE_NAME); cd $(CFG_PRJ_DIR)
	@$(ECHO) "${GREEN} INFO:${RESET} Program finished"
	@$(ECHO) ""

# --------------------------------------------------------------------------------
.PHONY: clean
clean:
	@$(ECHO) "${BLUE} INFO:${RESET} Try to clean up build directory $(CPP_CLS_DIR)"

	@if [ "$(shell dirname $(CPP_CLS_DIR))" = "$(CFG_PRJ_DIR)" ]; then \
		$(ECHO) "${BLUE} INFO:${RESET} Removing build directory $(CPP_CLS_DIR)"; \
		rm -rf $(CPP_CLS_DIR); \
		$(ECHO) "${GREEN} INFO:${RESET} Cleaning done."; \
	else \
		$(ECHO) "${RED} ERROR:${RESET} Invalid build directory specified: $(CPP_CLS_DIR)"; \
	fi
	@$(ECHO) ""

# --------------------------------------------------------------------------------
.PHONY: install
install: all setup_resources
	@$(ECHO) "${BLUE} INFO:${RESET} Packaging program to $(CPP_INS_DIR)"
	@mkdir -p $(CPP_INS_DIR); cp -r $(CPP_BIN_DIR)/. $(CPP_INS_DIR)
	@$(ECHO) "${GREEN} INFO:${RESET} Packaging done."
	@$(ECHO) ""

# --------------------------------------------------------------------------------
.PHONY: setup_resources
setup_resources:
	@$(ECHO) "${BLUE} INFO:${RESET} Copying resources from $(CFG_RES_DIR) to $(CPP_BIN_DIR)"
	@mkdir -p $(CPP_BIN_DIR)
	@cp -r $(CFG_RES_DIR)/. $(CPP_BIN_DIR)/
	@cp -r $(CFG_RES_DIR)/. $(CPP_BIN_DIR)/ 2> /dev/null || :	
	@$(ECHO) "${GREEN} INFO:${RESET} Resources copied."
	@$(ECHO) ""

.PHONY:
format:
	@$(ECHO) "${BLUE} INFO:${RESET} Formatting source files"
	@clang-format -i -style=Microsoft $(CFG_SRC_DIR)/*.cpp $(CFG_INC_DIR)/*.h
	@$(ECHO) "${GREEN} INFO:${RESET} Formatting done."
	@$(ECHO) ""

# --------------------------------------------------------------------------------
.PHONY: help
help: 
	@$(ECHO) " "
	@$(ECHO) "Usage: $(MAGENTA)make${RESET} ${GREEN}[target]${RESET} $(YELLOW)[options]${RESET}"
	@$(ECHO) " "
	@$(ECHO) "Targets:"
	@$(ECHO) "  ${GREEN}all     ${RESET}- (default) compiles and links the program"
	@$(ECHO) "  ${GREEN}setup   ${RESET}- creates the build directory structure"
	@$(ECHO) "  ${GREEN}compile ${RESET}- compiles the source files"
	@$(ECHO) "  ${GREEN}link    ${RESET}- links the object files"
	@$(ECHO) "  ${GREEN}run     ${RESET}- runs the program"
	@$(ECHO) "  ${GREEN}clean   ${RESET}- removes the build directory"
	@$(ECHO) "  ${GREEN}install ${RESET}- packages the program to the install directory"
	@$(ECHO) "  ${GREEN}help    ${RESET}- prints this help message"
	@$(ECHO) " "
	@$(ECHO) "Options:"
	@$(ECHO) "  $(YELLOW)release=1 ${RESET} - compiles the program in release mode"
	@$(ECHO) " "
	@$(ECHO) "Examples:"
	@$(ECHO) " $(MAGENTA)make ${RESET}"
	@$(ECHO) " $(MAGENTA)make ${RESET}${GREEN}all       ${RESET}"
	@$(ECHO) " $(MAGENTA)make ${RESET}${GREEN}release=1 ${RESET}"
	@$(ECHO) " $(MAGENTA)make ${RESET}${GREEN}clean     ${RESET}"
	@$(ECHO) " $(MAGENTA)make ${RESET}${GREEN}install   ${RESET}"
	@$(ECHO) " $(MAGENTA)make ${RESET}${GREEN}help      ${RESET}"
	@$(ECHO) " $(MAGENTA)make ${RESET}${GREEN}run       ${RESET}"
	@$(ECHO) " $(MAGENTA)make ${RESET}${GREEN}setup     ${RESET}"
	@$(ECHO) " "

# --------------------------------------------------------------------------------
