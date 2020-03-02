# =================================================================
# This Makefile assemble `x2t` converter
# with support OleObject fillable fields
#
# How-to:
#   1. build Core project from sources for corresponding OS
#   2. cd ./X2tConverter
#   3. make -f x2tConverter.mk build sdkjs-branch=ovm_fillable_fields
#   4. run required build command (see Makefile help)
#   5. deploy worker
# =================================================================

.SILENT: ;               # no need for @
.ONESHELL: ;             # recipes execute in same shell
.NOTPARALLEL: ;          # wait for this target to finish
.EXPORT_ALL_VARIABLES: ; # send all vars to shell
Makefile: ;              # skip prerequisite discovery

SHELL := /bin/bash
CURL := curl -L -o

# Determine this Makefile as Main file
THIS_MAKEFILE := $(word $(words $(MAKEFILE_LIST)), $(MAKEFILE_LIST))
# Current Working Dir (Full path)
CWD := $(shell cd $(shell dirname $(THIS_MAKEFILE)); pwd)

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

TARGET := $(PLATFORM)_$(ARCH)
DEST_DIR := ./build/$(TARGET)

# Core project builds' relative dir path
CORE_DIR := $(abspath $(CWD)/..)
CORE_BIN := ./build/bin/$(TARGET)
CORE_LIB := ./build/lib/$(TARGET)
CORE_3DPARTY := ./Common/3dParty

# Core binaries
BUILT_ARTIFACT += $(CORE_BIN)/x2t
BUILT_ARTIFACT += $(CORE_BIN)/allfontsgen
BUILT_ARTIFACT += $(CORE_BIN)/allthemesgen

# Core libraries
BUILT_ARTIFACT += $(CORE_LIB)/$(LIB_PREFIX)graphics$(SHARED_EXT)
BUILT_ARTIFACT += $(CORE_LIB)/$(LIB_PREFIX)kernel$(SHARED_EXT)
BUILT_ARTIFACT += $(CORE_LIB)/$(LIB_PREFIX)DjVuFile$(SHARED_EXT)
BUILT_ARTIFACT += $(CORE_LIB)/$(LIB_PREFIX)doctrenderer$(SHARED_EXT)
BUILT_ARTIFACT += $(CORE_LIB)/$(LIB_PREFIX)HtmlFile$(SHARED_EXT)
BUILT_ARTIFACT += $(CORE_LIB)/$(LIB_PREFIX)HtmlRenderer$(SHARED_EXT)
BUILT_ARTIFACT += $(CORE_LIB)/$(LIB_PREFIX)PdfReader$(SHARED_EXT)
BUILT_ARTIFACT += $(CORE_LIB)/$(LIB_PREFIX)PdfWriter$(SHARED_EXT)
BUILT_ARTIFACT += $(CORE_LIB)/$(LIB_PREFIX)XpsFile$(SHARED_EXT)
BUILT_ARTIFACT += $(CORE_LIB)/$(LIB_PREFIX)UnicodeConverter$(SHARED_EXT)

# ICU shared library
BUILT_ARTIFACT += $(CORE_3DPARTY)/icu/$(TARGET)/build/libicudata$(SHARED_EXT)
BUILT_ARTIFACT += $(CORE_3DPARTY)/icu/$(TARGET)/build/libicuuc$(SHARED_EXT)

# Not used for X2t Converter with assemble for OleObject
# ifeq ($(PLATFORM),mac)
# BUILT_ARTIFACT += $(CORE_LIB)/$(LIB_PREFIX)HtmlFileInternal$(SHARED_EXT)
# BUILT_ARTIFACT += $(CORE_3DPARTY)/cef/$(TARGET)/build/**
# endif

# SDKJS SRC repository url
SDKJS_SRC_URL := git@github.com:airslateinc/onlyoffice-sdkjs.git
SDKJS_DIR := $(abspath $(CORE_DIR)/../onlyoffice-sdkjs)

SDKJS_VENDOR = https://raw.githubusercontent.com/ONLYOFFICE/web-apps/master/vendor
SDKJS_JQUERY = jquery/jquery.min.js
SDKJS_XREGEXP = xregexp/xregexp-all-min.js

# Core fonts SRC repository url
CORE_FONTS_SRC_URL := git@github.com:ONLYOFFICE/core-fonts.git
CORE_FONTS_DIR := $(abspath $(CORE_DIR)/../core-fonts)

# X2T Converter requred dirs
X2T_REQ_DIRS += result
X2T_REQ_DIRS += source
X2T_REQ_DIRS += fonts
X2T_REQ_DIRS += sdkjs/vendor/jquery
X2T_REQ_DIRS += sdkjs/vendor/xregexp

define DOCT_RENDERER_CONFIG
<Settings>
  <file>./sdkjs/common/Native/native.js</file>
  <file>./sdkjs/common/Native/jquery_native.js</file>
  <file>./sdkjs/vendor/xregexp/xregexp-all-min.js</file>
  <file>./AllFonts.js</file>
  <htmlfile>./sdkjs/vendor/jquery/jquery.min.js</htmlfile>
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
endef

define PARAMS_XML
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
endef

# http://patorjk.com/software/taag/#p=display&f=ANSI%20Shadow&t=X2T
define LOGO
                                                                 
██╗  ██╗██████╗ ████████╗    ██████╗ ██╗   ██╗██╗██╗     ██████╗ 
╚██╗██╔╝╚════██╗╚══██╔══╝    ██╔══██╗██║   ██║██║██║     ██╔══██╗
 ╚███╔╝  █████╔╝   ██║       ██████╔╝██║   ██║██║██║     ██║  ██║
 ██╔██╗ ██╔═══╝    ██║       ██╔══██╗██║   ██║██║██║     ██║  ██║
██╔╝ ██╗███████╗   ██║       ██████╔╝╚██████╔╝██║███████╗██████╔╝
╚═╝  ╚═╝╚══════╝   ╚═╝       ╚═════╝  ╚═════╝ ╚═╝╚══════╝╚═════╝ 
                                                                 
endef

.PHONY: help build sdkjs allfonts clean

# Run this makefile help by default
.DEFAULT_GOAL = help


.logo:
	echo "$${LOGO}"

---: ## --------------------------------------------------------------
core_fonts: ## Download Core Fonts from OnlyOffice git repository
	echo "$@: Downloading Core Fonts from $(CORE_FONTS_SRC_URL)"

	# Clone repository if it not exists
	[ -d $(CORE_FONTS_DIR) ] \
		&& echo "$@: Use existing Core Fonts project -> $(CORE_FONTS_DIR)" \
		|| git clone $(CORE_FONTS_SRC_URL) $(CORE_FONTS_DIR)

sdkjs: ## Build SDKJS from sources
	echo "$@: Building SDKJS from $(SDKJS_SRC_URL)"
	
	# Clone repository if it not exists
	[ -d $(SDKJS_DIR) ] \
		&& echo "$@: Use existing SDKJS project -> $(SDKJS_DIR)" \
		|| git clone $(SDKJS_SRC_URL) $(SDKJS_DIR)

	# Checkout to defined from input branch name
	# 'sdkjs-branch=branch-name'
	if [ "$(sdkjs-branch)" ]; then \
		cd $(SDKJS_DIR) && git checkout $(sdkjs-branch); \
	fi

	# Install grunt-cli
	if [ "$(shell command -v grunt 2>/dev/null)" = "" ]; then \
		echo "$@: Installing grunt-cli ..."; \
		npm install -g grunt-cli; \
	fi

	# Build sdkjs
	if [ ! -d $(SDKJS_DIR)/deploy ]; then \
		echo "$@: Building sdkjs from sources..."; \
		cd $(SDKJS_DIR)/build && npm install --prefix $(SDKJS_DIR)/build; \
		cd $(SDKJS_DIR) \
			&& grunt --force --level=WHITESPACE_ONLY --formatting=PRETTY_PRINT --base build --gruntfile build/Gruntfile.js; \
	fi
	echo "$@: Build successfully"

allfonts: core_fonts ## Generate Allfonts.js for converter
	# Copy all truetype fonts from Core fonts to x2t fonts directory without nested folders structure
	find $(CORE_FONTS_DIR) -type f -name *.ttf -exec cp {} $(DEST_DIR)/fonts ";"
	echo "$@: Copy Core Fonts from $(CORE_FONTS_DIR) -> $(DEST_DIR)/fonts"
	
	echo "$@: Generating Allfonts.js from $(CORE_FONTS_DIR)"
	# Generate AllFonts.js, font thumbnails and font_selection.bin
	cd $(DEST_DIR) && ./allfontsgen \
	--input="./fonts;" \
	--allfonts="./AllFonts.js" \
	--images="./sdkjs/common/Images" \
	--selection="./font_selection.bin" \
	--use-system="false"

---: ## --------------------------------------------------------------
build: sdkjs ## Assemble x2t converter from Core build artifacts
	echo "$@: Assembling x2t converter for $(PLATFORM) -> $(DEST_DIR)"

	# Creates os-specific build dir
	[ -d "$(DEST_DIR)" ] || mkdir -p $(DEST_DIR)
	
	# Creates all necessary dirs
	for required_dir in $(X2T_REQ_DIRS); do \
		[ -d "$(DEST_DIR)/$${required_dir}" ] || mkdir -p $(DEST_DIR)/$${required_dir}; \
		echo "$@: Create target dir $${required_dir} -> $(DEST_DIR)/$${required_dir}"; \
	done

	# Copy all build artifacts to assemble dir
	for current_file in $(BUILT_ARTIFACT); do \
		cp $(CORE_DIR)/$${current_file} $(CWD)/$(DEST_DIR); \
		echo "$@: Copy $${current_file} -> $(DEST_DIR)"; \
	done

	# Copy SDKJS build artifact
	for sdkjs_dir in cell common slide word; do \
		cp -R $(SDKJS_DIR)/deploy/sdkjs/$${sdkjs_dir} $(DEST_DIR)/sdkjs/$${sdkjs_dir}; \
		echo "$@: Copy ./deploy/sdkjs/$${sdkjs_dir} -> $(DEST_DIR)/sdkjs/$${sdkjs_dir}"; \
	done

	echo "$@: Download JQuery and XRegexp"
	for sdkjs_vnd in $(SDKJS_JQUERY) $(SDKJS_XREGEXP); do \
		[ -f $(DEST_DIR)/sdkjs/vendor/$${sdkjs_vnd} ] || $(CURL) $(DEST_DIR)/sdkjs/vendor/$${sdkjs_vnd} $(SDKJS_VENDOR)/$${sdkjs_vnd}; \
	done

	# Create DoctRenderer.config
	echo "$@: Write config -> $(DEST_DIR)/DoctRenderer.config"
	echo "$${DOCT_RENDERER_CONFIG}" > $(DEST_DIR)/DoctRenderer.config

	# Create params.xml
	echo "$@: Write run params -> $(DEST_DIR)/params.xml"
	echo "$${PARAMS_XML}" > $(DEST_DIR)/params.xml

	# Generate Allfonts.js
	$(MAKE) -f $(THIS_MAKEFILE) allfonts

clean: ## Cleanup x2t converter assemblies
	echo "Clear x2t assembly target dir: $(TARGET)"
	rm -rf $(DEST_DIR)

---: ## --------------------------------------------------------------
help: .logo ## Show this help and exit
	echo "Usage:"
	echo "  make -f $(THIS_MAKEFILE) <target> <sdkjs-branch>"
	echo ''
	echo "Example:"
	echo "  make -f $(THIS_MAKEFILE) build sdkjs-branch=ovm_fillable_fields"
	echo ''
	echo "SDKJS options:"
	printf "  %-15s %s\n" "sdkjs-branch" "proper branch name for build"
	printf "  %-15s %s\n" "            " "e.g. 'master'"
	echo ''
	echo "Targets:"
	echo ''
	grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(THIS_MAKEFILE) | awk 'BEGIN {FS = ":.*?## "}; \
		{printf "  %-15s %s\n", $$1, $$2}'
	echo ''
%:
	@:
