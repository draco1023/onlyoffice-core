# =================================================================
# This Makefile assemble `x2t` converter with support OleObject fillable fields
#
# How-to:
#   1. build Core project from sources for corresponding OS
#   2. cd ./X2tConverter && make -f X2tWorker.mk
#   3. deploy worker
# =================================================================

.SILENT: ;               # no need for @
.ONESHELL: ;             # recipes execute in same shell
.NOTPARALLEL: ;          # wait for this target to finish
.EXPORT_ALL_VARIABLES: ; # send all vars to shell
Makefile: ;              # skip prerequisite discovery

SHELL ?= /bin/bash
# Determine this Makefile as Main file
THIS_MAKEFILE := $(word $(words $(MAKEFILE_LIST)), $(MAKEFILE_LIST))

.PHONY: help build

# Run this makefile help by default
.DEFAULT_GOAL = help

# =================================================================
# Definitions:
# =================================================================
# Regular Colors
NC         = \033[0m
Black      = \033[0;30m
Red        = \033[1;31m
Green      = \033[1;32m
Yellow     = \033[1;33m
Blue       = \033[1;34m
Purple     = \033[1;35m
Cyan       = \033[1;36m
White      = \033[1;37m
Gray       = \033[1;90m

# Current Working Dir (Full path)
CWD       := $(shell cd $(shell dirname $(THIS_MAKEFILE)); pwd)
# Filter Makefile Input params to use they as target input params
ARGS      := $(filter-out $@, $(MAKECMDGOALS))

# =================================================================
# Target filters:
# =================================================================
BUILD_ARGS := $(filter-out build, $(MAKECMDGOALS))
CLEAN_ARGS := $(filter-out clean, $(MAKECMDGOALS))
PLATFORM  = $(if $(BUILD_ARGS),$(BUILD_ARGS), "")

# =================================================================
# Project definitions:
# =================================================================
# X2t converter build dir for assemble output
BUILD_DIR := $(CWD)/build

CORE_BUILD_DIR := $(abspath $(CWD)/../build)

ifeq ($(shell uname -m),x86_64)
	ARCH := 64
else
	ARCH := 32
endif

TARGET_BUILD := $(PLATFORM)_$(ARCH)

ifeq ($(PLATFORM),mac)
	SHARED_EXT := .dylib
	LIB_EXT := .a
	LIB_PREFIX := lib
else
	ifeq ($(PLATFORM),linux)
		SHARED_EXT := .so*
		LIB_EXT := .a
		LIB_PREFIX := lib
	endif
endif


# =================================================================
# Makefile Targets:
# =================================================================

---: ## --------------------------------------------------------------
build: ## Assemble x2t converter from Core build artifacts
	echo "$(Cyan)Assemble x2t converter for $(PLATFORM)$(NC)"

	[ -d $(BUILD_DIR)/$(TARGET_BUILD) ] || mkdir -p $(BUILD_DIR)/$(TARGET_BUILD)
	cp $(CORE_BUILD_DIR)/lib/$(TARGET_BUILD)/*$(SHARED_EXT) $(BUILD_DIR)/$(TARGET_BUILD)

clean: ## Cleanup x2t converter assemblies
	[ -d $(BUILD_DIR)/$(TARGET_BUILD)) ] && (rm -rf $(BUILD_DIR)/$(TARGET_BUILD)) && echo "Deleted $(BUILD_DIR)/$(TARGET_BUILD))")
	exit 0

---: ## --------------------------------------------------------------
help: .logo ## Show this help and exit
	@echo "$(Yellow)Usage:$(NC)\n  make -f $(THIS_MAKEFILE) <target> <target_os>"
	@echo ''
	@echo "$(Yellow)Target OS:$(NC)"
	printf "  $(Green)%-15s$(NC) %s\n" "mac" "Assemble x2t converter for MacOs"
	printf "  $(Green)%-15s$(NC) %s\n" "linux" "Assemble x2t converter for Linux"
	@echo ''
	@echo "$(Yellow)Targets:$(NC)"
	@echo ''
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(THIS_MAKEFILE) | awk 'BEGIN {FS = ":.*?## "}; \
		{printf "  $(Cyan)%-15s$(NC) %s\n", $$1, $$2}'
	@echo ''
%:
	@:
