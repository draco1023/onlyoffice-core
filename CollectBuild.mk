# =================================================================
# This Makefile collect OnlyOffice compiled artifacts to ZIP
# =================================================================

.SILENT: ;               # no need for @
.ONESHELL: ;             # recipes execute in same shell
.NOTPARALLEL: ;          # wait for this target to finish
.EXPORT_ALL_VARIABLES: ; # send all vars to shell
Makefile: ;              # skip prerequisite discovery

SHELL := /bin/bash

# Detect OS
OS := $(shell uname -s)

ifeq ($(OS),Linux)
	PLATFORM := linux
	SHARED_EXT := .so*
	LIB_EXT := .a
	LIB_PREFIX := lib
else
	ifeq ($(OS),Darwin)
		PLATFORM = mac
		SHARED_EXT := .dylib
		LIB_EXT := .a
		LIB_PREFIX := lib
	endif
endif

ifeq ($(shell uname -m),x86_64)
	ARCH := 64
else
	ARCH := 32
endif


# Determine this Makefile as Main file
THIS_MAKEFILE := $(word $(words $(MAKEFILE_LIST)), $(MAKEFILE_LIST))

# Current Working Dir (Full path)
CWD := $(shell cd $(shell dirname $(THIS_MAKEFILE)); pwd)

TARGET := $(PLATFORM)_$(ARCH)

# http://patorjk.com/software/taag/#p=display&f=Bloody&t=Core%20build
define LOGO
                                                                          
 ▄████▄   ▒█████   ██▀███  ▓█████     ▄▄▄▄    █    ██  ██▓ ██▓    ▓█████▄ 
▒██▀ ▀█  ▒██▒  ██▒▓██ ▒ ██▒▓█   ▀    ▓█████▄  ██  ▓██▒▓██▒▓██▒    ▒██▀ ██▌
▒▓█    ▄ ▒██░  ██▒▓██ ░▄█ ▒▒███      ▒██▒ ▄██▓██  ▒██░▒██▒▒██░    ░██   █▌
▒▓▓▄ ▄██▒▒██   ██░▒██▀▀█▄  ▒▓█  ▄    ▒██░█▀  ▓▓█  ░██░░██░▒██░    ░▓█▄   ▌
▒ ▓███▀ ░░ ████▓▒░░██▓ ▒██▒░▒████▒   ░▓█  ▀█▓▒▒█████▓ ░██░░██████▒░▒████▓ 
░ ░▒ ▒  ░░ ▒░▒░▒░ ░ ▒▓ ░▒▓░░░ ▒░ ░   ░▒▓███▀▒░▒▓▒ ▒ ▒ ░▓  ░ ▒░▓  ░ ▒▒▓  ▒ 
  ░  ▒     ░ ▒ ▒░   ░▒ ░ ▒░ ░ ░  ░   ▒░▒   ░ ░░▒░ ░ ░  ▒ ░░ ░ ▒  ░ ░ ▒  ▒ 
░        ░ ░ ░ ▒    ░░   ░    ░       ░    ░  ░░░ ░ ░  ▒ ░  ░ ░    ░ ░  ░ 
░ ░          ░ ░     ░        ░  ░    ░         ░      ░      ░  ░   ░    
░                                          ░                       ░      
endef

# Core project builds' relative dir path
CORE_DIR := $(abspath $(CWD))
CORE_BIN := ./build/bin/$(TARGET)
CORE_LIB := ./build/lib/$(TARGET)
CORE_3DPARTY := ./Common/3dParty

BUILDS += $(CORE_BIN)
BUILDS += $(CORE_LIB)

BUILDS += $(CORE_3DPARTY)/*/$(TARGET)/build/*
BUILDS += $(CORE_3DPARTY)/boost/boost_*/build/$(TARGET)
BUILDS += $(CORE_3DPARTY)/cryptopp/project/core_build/$(TARGET)
BUILDS += $(CORE_3DPARTY)/v8/v8/out.gn/$(TARGET)

BUILDS += ./*/core_build/$(TARGET)
BUILDS += ./*/*/core_build/$(TARGET)
BUILDS += ./*/*/*/core_build/$(TARGET)

BUILDS += ./X2tConverter/build/Qt/core_build/$(TARGET)

ZIP_SPLIT    := -s 500m
ZIP_EXCLUDES := -x ".*" -x "__MACOSX" -x "*.DS_Store"

.DEFAULT_GOAL = help
.PHONY: help zip

---: ## --------------------------------------------------------------
zip: ## Collect all build artifacts as ZIP archive
	$(info $@: Creating ZIP archive from $(PLATFORM) build artifacts)
	zip -rv $(SPLIT) ./build/$(PLATFORM)_build.zip $(BUILDS) $(ZIP_EXCLUDES)

.logo:
	echo "$${LOGO}"

---: ## --------------------------------------------------------------
help: .logo ## Show this help and exit
	echo "This Makefile collect OnlyOffice compiled artifacts to ZIP"
	echo ''
	echo "Usage:"
	echo "  make -f $(THIS_MAKEFILE) <target>"
	echo ''
	echo "Example:"
	echo "  make -f $(THIS_MAKEFILE) zip"
	echo ''
	echo "Targets:"
	echo ''
	grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(THIS_MAKEFILE) | awk 'BEGIN {FS = ":.*?## "}; \
		{printf "  %-15s %s\n", $$1, $$2}'
	echo ''
%:
	@:
