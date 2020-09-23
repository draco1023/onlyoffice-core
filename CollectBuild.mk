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

# Use version of OnlyOffice Core from version file as defaults for Core builds
ifneq ("$(wildcard ./CORE_VERSION)","")
CORE_VERSION ?= $(shell cat ./CORE_VERSION | head -n 1)
else
CORE_VERSION ?= 0.0.0
endif

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

# Core builds for Core Libraries
BUILDS += $(CORE_BIN)
BUILDS += $(CORE_LIB)

BUILDS += ./*/core_build/$(TARGET)
BUILDS += ./*/*/core_build/$(TARGET)
BUILDS += ./*/*/*/core_build/$(TARGET)

# Core third party components (V8 Engine, CEF, Boost...)
BUILDS_VENDORS += $(CORE_3DPARTY)/*/$(TARGET)/build/*
BUILDS_VENDORS += $(CORE_3DPARTY)/boost/boost_*/build/$(TARGET)
BUILDS_VENDORS += $(CORE_3DPARTY)/cryptopp/project/core_build/$(TARGET)
BUILDS_VENDORS += $(CORE_3DPARTY)/v8/v8/out.gn/$(TARGET)

# X2T Converter binary
BUILDS += ./X2tConverter/build/Qt/core_build/$(TARGET)

# Artifactory max file size is 1000 Mb
ZIP_SPLIT    := -s 500m
ZIP_EXCLUDES := -x ".*" -x "__MACOSX" -x "*.DS_Store"
DEST_DIR := ./.artifactory/$(TARGET)/$(CORE_VERSION)

.DEFAULT_GOAL = help
.PHONY: help zip vendors libs

---: ## --------------------------------------------------------------
all: vendors libs ## Collect all Core and Vendors build artifacts as ZIP archive

vendors: ## Collect Core `Common/3dParty` build artifacts as ZIP
	$(info $@: Creating ZIP archive for $(TARGET) -> $(DEST_DIR))
	# 	Creates OS-specific destination dir
	[ -d "$(DEST_DIR)" ] || mkdir -p $(DEST_DIR)
	zip -rv $(ZIP_SPLIT) $(DEST_DIR)/common_3dparty.zip $(BUILDS_VENDORS) $(ZIP_EXCLUDES)

libs: ## Collect all Core component builds artifacts as ZIP
	$(info $@: Creating ZIP archive for $(TARGET) -> $(DEST_DIR))
	# 	Creates os-specific destination dir
	[ -d "$(DEST_DIR)" ] || mkdir -p $(DEST_DIR)
	zip -rv $(DEST_DIR)/core_builds.zip $(BUILDS) $(ZIP_EXCLUDES)

.logo:
	echo "$${LOGO}"

---: ## --------------------------------------------------------------
help: .logo ## Show this help and exit
	echo "This Makefile collect OnlyOffice compiled artifacts as ZIP"
	echo CORE_VERSION: $(CORE_VERSION), OS: $(OS)
	echo ''
	echo "Usage:"
	echo "  make -f $(THIS_MAKEFILE) <target>"
	echo ''
	echo "Example:"
	echo "  make -f $(THIS_MAKEFILE) all"
	echo "  make -f $(THIS_MAKEFILE) libs"
	echo ''
	echo "Targets:"
	echo ''
	echo "  All collected build artifacts will be placed into: $(DEST_DIR)"
	grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(THIS_MAKEFILE) | awk 'BEGIN {FS = ":.*?## "}; \
		{printf "  %-15s %s\n", $$1, $$2}'
	echo ''
%:
	@:
