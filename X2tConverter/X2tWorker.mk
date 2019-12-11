# =================================================================
# This Makefile assemble `x2t` converter with support OleObject fillable fields
#
# How-to:
#   1. build Core project from sources for corresponding OS
#   2. cd ./X2tConverter && make -f X2tWorker.mk
#   3. run required build command (see Makefile help)
#   4. deploy worker
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
PLATFORM   := $(if $(BUILD_ARGS),$(BUILD_ARGS), "")

# =================================================================
# Project definitions:
# =================================================================
# X2t converter build dir for assemble output
BUILD_DIR := $(CWD)/build
FONTS_SRC_PREFIX := core-fonts

# SDKJS SRC repository url
SDKJS_SRC_URL := git@github.com:airslateinc/onlyoffice-sdkjs.git

CORE_BUILD_DIR := $(abspath $(CWD)/../build)
CORE_COMMON_DIR := $(abspath $(CWD)/../Common)

ifeq ($(shell uname -m),x86_64)
	ARCH := 64
else
	ARCH := 32
endif

TARGET_BUILD := $(PLATFORM)_$(ARCH)

ALLOWED_OS += mac
ALLOWED_OS += linux

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
	echo "$(Cyan)Assembling x2t converter for $(PLATFORM)$(NC)"

	[ -d $(BUILD_DIR)/$(TARGET_BUILD) ] || mkdir -p $(BUILD_DIR)/$(TARGET_BUILD)
	
	# Copy all compiled libraries to assemble directory
	cp $(CORE_BUILD_DIR)/lib/$(TARGET_BUILD)/*$(SHARED_EXT) $(BUILD_DIR)/$(TARGET_BUILD) \
		&& echo "$(Green)Copy 'lib'$(NC) \t\t ./$(TARGET_BUILD)/*$(SHARED_EXT)"
	
	# Copy all compiled binaries to assemble directory
	cp $(CORE_BUILD_DIR)/bin/$(TARGET_BUILD)/* $(BUILD_DIR)/$(TARGET_BUILD) \
		&& echo "$(Green)Copy 'bin'$(NC) \t\t ./$(TARGET_BUILD)/*"

	# Copy initials empty docs binaries
	cp -r $(CORE_COMMON_DIR)/empty $(BUILD_DIR)/$(TARGET_BUILD) \
		&& echo "$(Green)Copy 'doct'$(NC) \t\t ./$(TARGET_BUILD)/empty/*.bin"

	# Copy ICU library built for corresponding OS
	cp $(CORE_COMMON_DIR)/3dParty/icu/$(TARGET_BUILD)/build/*$(SHARED_EXT) $(BUILD_DIR)/$(TARGET_BUILD) \
		&& echo "$(Green)Copy 'icu lib'$(NC) \t\t ./$(TARGET_BUILD)/*$(SHARED_EXT)"
	
	# Copy ICU default data file for corresponding OS
	cp $(CORE_COMMON_DIR)/3dParty/v8/v8/out.gn/$(TARGET_BUILD)/icudtl.dat $(BUILD_DIR)/$(TARGET_BUILD) \
		&& echo "$(Green)Copy 'icu dtl'$(NC) \t\t ./$(TARGET_BUILD)/icudtl.dat"
	
	# Copy Chromium Embedded Framework
	cp -r $(CORE_COMMON_DIR)/3dParty/cef/$(TARGET_BUILD)/build/. $(BUILD_DIR)/$(TARGET_BUILD)/HtmlFileInternal \
		&& echo "$(Green)Copy 'cef lib'$(NC) \t\t ./$(TARGET_BUILD)/HtmlFileInternal"

	# Download Fonts
	if [[ $(fonts-repo) == *"pdffiller/pdf-fonts"* ]]; then
	FONTS_SRC_PREFIX=pdf-fonts
	fi

	[ -d $(CORE_BUILD_DIR)/.cache/fonts/$$FONTS_SRC_PREFIX ] \
		&& echo "$(Green)Download fonts$(NC) \t\t $(CORE_BUILD_DIR)/.cache/fonts/$$FONTS_SRC_PREFIX" \
		|| git clone --depth 1 $(fonts-repo) $(CORE_BUILD_DIR)/.cache/fonts/$$FONTS_SRC_PREFIX

	# Copy Pdf-fonts JSEditor & Workers compatible OR copy onlyoffice core fonts (depends on provided fonts-url)
	[[ -d $(CORE_BUILD_DIR)/.cache/fonts/$$FONTS_SRC_PREFIX/trueedit && -d $(CORE_BUILD_DIR)/.cache/fonts/$$FONTS_SRC_PREFIX/workers ]] \
		&& (mkdir -p $(BUILD_DIR)/$(TARGET_BUILD)/fonts/truetype/{trueedit,workers} \
			&& cp -R $(CORE_BUILD_DIR)/.cache/fonts/$$FONTS_SRC_PREFIX/{trueedit,workers} $(BUILD_DIR)/$(TARGET_BUILD)/fonts/truetype \
			&& echo "$(Green)Copy $$FONTS_SRC_PREFIX$(NC) \t\t ./$(TARGET_BUILD)/fonts/truetype/{workers, trueedit}") \
		|| (mkdir -p $(BUILD_DIR)/$(TARGET_BUILD)/fonts/truetype \
			&& cp -nR $(CORE_BUILD_DIR)/.cache/fonts/$$FONTS_SRC_PREFIX/. $(BUILD_DIR)/$(TARGET_BUILD)/fonts/truetype; \
			rm -rf $(BUILD_DIR)/$(TARGET_BUILD)/fonts/truetype/.git \
			&& echo "$(Green)Copy $$FONTS_SRC_PREFIX$(NC) \t\t ./$(TARGET_BUILD)/fonts/truetype/*")
	
	# Clone SDKJS repository
	[ -d $(CORE_BUILD_DIR)/.cache/sdkjs_src ] \
		&& echo "$(Green)Download sdkjs$(NC) \t\t $(CORE_BUILD_DIR)/.cache/sdkjs_src" \
		|| git clone --depth 1 $(SDKJS_SRC_URL) $(CORE_BUILD_DIR)/.cache/sdkjs_src
		
	# Build SDKJS from sources
	cd $(CORE_BUILD_DIR)/.cache/sdkjs_src
	
	if [[ "$(sdkjs-branch)" ]]; then
		git checkout $(sdkjs-branch)
	fi

	if [[ -f build/package.json ]]; then
		npm install
		grunt --level=WHITESPACE_ONLY --formatting=PRETTY_PRINT --base build --gruntfile build/Gruntfile.js
	fi

	[ -d $(CORE_BUILD_DIR)/.cache/sdkjs_src/deploy/sdkjs ] \
		&& cp -nR $(CORE_BUILD_DIR)/.cache/sdkjs_src/deploy/sdkjs $(BUILD_DIR)/$(TARGET_BUILD) \
		&& echo "$(Green)Copy 'SDKJS'$(NC) \t\t ./$(TARGET_BUILD)/sdkjs/*"

	# Todo: Build these with Grunt
	[ -d $(BUILD_DIR)/$(TARGET_BUILD)/sdkjs/vendor ] || mkdir -p $(BUILD_DIR)/$(TARGET_BUILD)/sdkjs/vendor/{xregexp,jquery}
	cp -nR $(CORE_BUILD_DIR)/.cache/sdkjs_src/common/externs/xregexp-*.js $(BUILD_DIR)/$(TARGET_BUILD)/sdkjs/vendor/xregexp/xregexp-all-min.js
	cp -nR $(CORE_BUILD_DIR)/.cache/sdkjs_src/common/externs/jquery-*.js $(BUILD_DIR)/$(TARGET_BUILD)/sdkjs/vendor/jquery/jquery.min.js
	
	cd $(CWD)

	
	# Create DoctRenderer.config
	cat << EOF > $(BUILD_DIR)/$(TARGET_BUILD)/DoctRenderer.config \
		&& echo "$(Green)Created 'config'$(NC) \t ./$(TARGET_BUILD)/DoctRenderer.config"
	<Settings>
		<file>./sdkjs/vendor/xregexp/xregexp-all-min.js</file>
		<htmlfile>./sdkjs/vendor/jquery/jquery.min.js</htmlfile>
		<file>./AllFonts.js</file>

		<file>./sdkjs/common/Native/native.js</file>
		<file>./sdkjs/common/Native/jquery_native.js</file>
		<DoctSdk>
			<file>./sdkjs/word/sdk-all-min.js</file>
			<file>./sdkjs/common/libfont/js/fonts.js</file>
			<file>./sdkjs/word/sdk-all.js</file>
		</DoctSdk>
		<PpttSdk>
			<file>./sdkjs/slide/sdk-all-min.js</file>
			<file>./sdkjs/common/libfont/js/fonts.js</file>
			<file>./sdkjs/slide/sdk-all.js</file>
		</PpttSdk>
		<XlstSdk>
			<file>./sdkjs/cell/sdk-all-min.js</file>
			<file>./sdkjs/common/libfont/js/fonts.js</file>
			<file>./sdkjs/cell/sdk-all.js</file>
		</XlstSdk>
	</Settings>
	EOF

	# Create params.xml
	cat << EOF > $(BUILD_DIR)/$(TARGET_BUILD)/params.xml \
		&& echo "$(Green)Created 'params'$(NC) \t ./$(TARGET_BUILD)/params.xml"
	<?xml version="1.0" encoding="utf-8"?>
	<TaskQueueDataConvert xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
		xmlns:xsd="http://www.w3.org/2001/XMLSchema">
		<m_sKey>x2tconverter_pdf</m_sKey>
		<m_sFileFrom>./source/input.docx</m_sFileFrom>
		<m_sFileTo>./result/output.pdf</m_sFileTo>
		<m_nFormatTo>513</m_nFormatTo>
		<m_bIsPDFA xsi:nil="true" />
		<m_nCsvTxtEncoding>46</m_nCsvTxtEncoding>
		<m_nCsvDelimiter>4</m_nCsvDelimiter>
		<m_nCsvDelimiterChar xsi:nil="true" />
		<m_bPaid xsi:nil="true" />
		<m_bEmbeddedFonts>false</m_bEmbeddedFonts>
		<m_bFromChanges xsi:nil="true" />
		<m_sFontDir>./fonts</m_sFontDir>
		<m_sThemeDir>./sdkjs/slide/themes</m_sThemeDir>
		<m_nDoctParams xsi:nil="true" />
		<m_oTimestamp>2019-08-16T10:47:18.611Z</m_oTimestamp>
		<m_bIsNoBase64>true</m_bIsNoBase64>
		<m_oInputLimits>
			<m_oInputLimit type="docx;dotx;docm;dotm">
				<m_oZip uncompressed="52428800" template="*.xml"/>
			</m_oInputLimit>
			<m_oInputLimit type="xlsx;xltx;xlsm;xltm">
				<m_oZip uncompressed="314572800" template="*.xml"/>
			</m_oInputLimit>
			<m_oInputLimit type="pptx;ppsx;potx;pptm;ppsm;potm">
				<m_oZip uncompressed="52428800" template="*.xml"/>
			</m_oInputLimit>
		</m_oInputLimits>
	</TaskQueueDataConvert>
	EOF
	
	# Creates input and output dirs for converter's files
	[ -d $(BUILD_DIR)/$(TARGET_BUILD)/result ] || mkdir -p $(BUILD_DIR)/$(TARGET_BUILD)/result
	[ -d $(BUILD_DIR)/$(TARGET_BUILD)/source ] || mkdir -p $(BUILD_DIR)/$(TARGET_BUILD)/source

clean: ## Cleanup x2t converter assemblies
	for target_os in $(ALLOWED_OS); do \
		[ -d $(BUILD_DIR)/"$$target_os"_$(ARCH) ] \
			&& rm -rf $(BUILD_DIR)/"$$target_os"_$(ARCH) \
			&& echo "Deleted $(BUILD_DIR)/"$$target_os"_$(ARCH)" \
			|| echo "Build for $$target_os is not exists. Skip clean."
	done

	[ -d $(CORE_BUILD_DIR)/.cache ] \
		&& rm -rf $(CORE_BUILD_DIR)/.cache \
		|| echo "$(CORE_BUILD_DIR)/.cache is not exists. Skip clean."

---: ## --------------------------------------------------------------
help: .logo ## Show this help and exit
	@echo "$(Yellow)Usage:$(NC)\n  make -f $(THIS_MAKEFILE) <target> <target_os> <fonts-url>"
	@echo ''
	@echo "$(Yellow)Target OS:$(NC)"
	printf "  $(Green)%-15s$(NC) %s\n" "mac" "Assemble x2t converter for MacOs"
	printf "  $(Green)%-15s$(NC) %s\n" "linux" "Assemble x2t converter for Linux"
	@echo ''
	@echo "$(Yellow)Fonts URL:$(NC)"
	printf "  $(Green)%-15s$(NC) %s\n" "fonts-url" "ssh url to proper github fonts repository. See example bellow:"
	printf "  $(Green)%-15s$(NC) $(Cyan)%s$(NC)\n" "" "git@github.com:pdffiller/pdf-fonts.git"
	@echo ''
	@echo "$(Yellow)Targets:$(NC)"
	@echo ''
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(THIS_MAKEFILE) | awk 'BEGIN {FS = ":.*?## "}; \
		{printf "  $(Cyan)%-15s$(NC) %s\n", $$1, $$2}'
	@echo ''
%:
	@:
