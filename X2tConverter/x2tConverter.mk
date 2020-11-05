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

ZIP_EXCLUDES := -x ".*" -x "__MACOSX" -x "*.DS_Store"

# Use version of SDKJS from version file as defaults for SDKJS builds
ifneq ("$(wildcard ./SDKJS_VERSION)","")
SDKJS_VERSION ?= $(shell cat ./SDKJS_VERSION | head -n 1)
else
# Use the first version of SDKJS with supporting of extract fillable fields
SDKJS_VERSION ?= ovm_fillable_fields_old
endif

SDKJS_TAG  := $(if $(sdkjs-branch),$(sdkjs-branch),$(SDKJS_VERSION))
# Replace '/' from tag name to avoid errors when use the tag as part of file name
SDKJS_TAG_PATH := $(subst /,_,$(SDKJS_TAG))
TARGET     := $(PLATFORM)_$(ARCH)
DEST_DIR   := ./build/$(TARGET)_$(SDKJS_TAG_PATH)

# Core project builds' relative dir path
CORE_DIR := $(abspath $(CWD)/..)
CORE_BIN := ./build/bin/$(TARGET)
CORE_LIB := ./build/lib/$(TARGET)
CORE_3DPARTY := ./Common/3dParty

ARTIFACTORY_DIR := $(abspath $(CORE_DIR)/.artifactory)

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
BUILT_ARTIFACT += $(CORE_3DPARTY)/icu/$(TARGET)/build/libicu*

# Not used for X2t Converter with assemble for OleObject
# ifeq ($(PLATFORM),mac)
# BUILT_ARTIFACT += $(CORE_LIB)/$(LIB_PREFIX)HtmlFileInternal$(SHARED_EXT)
# BUILT_ARTIFACT += $(CORE_3DPARTY)/cef/$(TARGET)/build/**
# endif

# SDKJS SRC repository url
SDKJS_SRC_URL := git@github.com:airslateinc/onlyoffice-sdkjs.git
SDKJS_DIR     := $(ARTIFACTORY_DIR)/onlyoffice-sdkjs
SDK_BUILD_NUMBER := 0
SDK_PRODUCT_VERSION := 0

# Application Metadata
ifneq ("$(wildcard $(SDKJS_DIR)/.git/config)","")
SDK_PRODUCT_VERSION := "$(shell cd $(SDKJS_DIR) && git describe --abbrev=0 --tags)"
SDK_BUILD_NUMBER    := "$(shell cd $(SDKJS_DIR) && git rev-parse --short HEAD)"
endif

SDKJS_VENDOR  = https://raw.githubusercontent.com/ONLYOFFICE/web-apps/master/vendor
SDKJS_JQUERY  = jquery/jquery.min.js
SDKJS_XREGEXP = xregexp/xregexp-all-min.js
SDKJS_PARAMS  = --force --base build --gruntfile build/Gruntfile.js

# Core fonts SRC repository url
CORE_FONTS_SRC_URL := git@github.com:airslateinc/onlyoffice-core-fonts.git
CORE_FONTS_DIR := $(ARTIFACTORY_DIR)/onlyoffice-core-fonts


# All additional fonts must be into this directory
ADDITIONAL_FONTS_DIR := $(ARTIFACTORY_DIR)/additional_fonts

# All test documents and supplied files must be into this directory
TEST_SRC_DIR := $(ARTIFACTORY_DIR)/test_documents

# X2T Converter requred dirs
X2T_REQ_DIRS += result
X2T_REQ_DIRS += source
X2T_REQ_DIRS += fonts
X2T_REQ_DIRS += sdkjs/vendor/jquery
X2T_REQ_DIRS += sdkjs/vendor/xregexp

define check_jfrog
	if test ! "$(shell jfrog --version 2>/dev/null)"; then \
		>&2 printf "jFrog does not exist. Can not working with Artifactory.\n"; \
		>&2 printf "Please install 'jfrog-cli' from: https://jfrog.com/getcli\n"; \
		>&2 printf "Aborting.\n"; \
		exit 1; \
	fi
endef

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

.PHONY: help build sdkjs allfonts clean test

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
		|| git clone --depth 1 $(CORE_FONTS_SRC_URL) $(CORE_FONTS_DIR)

sdkjs: ## Build SDKJS from sources
	echo "$@: Building SDKJS from $(SDKJS_SRC_URL)"

	# Clone repository if it not exists
	[ -d $(SDKJS_DIR) ] \
		&& echo "$@: Use existing SDKJS project -> $(SDKJS_DIR)" \
		|| git clone -b $(SDKJS_TAG) $(SDKJS_SRC_URL) $(SDKJS_DIR)

	# Checkout to defined from input branch name or use TAG from SDKJS_VERSION
	# 'sdkjs-branch=branch-name'
	cd $(SDKJS_DIR) && git checkout $(SDKJS_TAG)

	# Install grunt-cli
	if [ "$(shell command -v grunt 2>/dev/null)" = "" ]; then \
		echo "$@: Installing grunt-cli ..."; \
		npm install -g grunt-cli; \
	fi

	# Always cleanup previous sdkjs builds to avoid using wrong builds
	[ ! -d $(SDKJS_DIR)/deploy ] || rm -rf $(SDKJS_DIR)/deploy

	# # Build sdkjs
	echo "$@: Building sdkjs $(SDK_PRODUCT_VERSION).$(SDK_BUILD_NUMBER) from sources..."
	cd $(SDKJS_DIR)/build && npm install --prefix $(SDKJS_DIR)/build
	cd $(SDKJS_DIR) \
		&& COMPANY_NAME=airSlate \
		PRODUCT_NAME=onlyoffice-converter \
		PRODUCT_VERSION="$(SDK_PRODUCT_VERSION)" \
		BUILD_NUMBER="$(SDK_BUILD_NUMBER)" \
		PUBLISHER_NAME="airSlate Inc." \
		APP_COPYRIGHT="Copyright (C) airSlate Inc. 2019-$(shell date +%Y). All rights reserved" \
		PUBLISHER_URL="https://airslate.com" \
		grunt $(SDKJS_PARAMS)
	echo "$(SDKJS_TAG) (build: $(SDK_PRODUCT_VERSION).$(SDK_BUILD_NUMBER))" > $(SDKJS_DIR)/deploy/sdkjs/.VERSION
	echo "$@: Build successfully $(SDKJS_TAG) $(SDK_PRODUCT_VERSION).$(SDK_BUILD_NUMBER)"

allfonts: core_fonts ## Generate Allfonts.js for converter
	# Copy all truetype fonts from Core fonts to x2t fonts directory without nested folders structure
	find $(CORE_FONTS_DIR)/ -type f -name *.ttf -exec cp {} $(DEST_DIR)/fonts/ ";"
	echo "$@: Copy Core Fonts from $(CORE_FONTS_DIR) -> $(DEST_DIR)/fonts"

	# Copy additional fonts if exists
	[ -d $(ADDITIONAL_FONTS_DIR) ] \
		&& find $(ADDITIONAL_FONTS_DIR)/ -type f -name *.ttf -exec cp {} $(DEST_DIR)/fonts/ ";" \
		&& echo "$@: Copy Additional Fonts from $(ADDITIONAL_FONTS_DIR) -> $(DEST_DIR)/fonts" \
		|| echo "$@: No Additional Fonts... Skip copy step"

	echo "$@: Generating Allfonts.js from $(DEST_DIR)/fonts"
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

	# Copy SDKJS VERSION file
	[ ! -f $(SDKJS_DIR)/deploy/sdkjs/.VERSION ] || cp $(SDKJS_DIR)/deploy/sdkjs/.VERSION $(DEST_DIR)/sdkjs/

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

	# Create zip archive from Converters files
	cd $(DEST_DIR) && zip -r $(CWD)/build/x2t_$(TARGET)_$(SDKJS_TAG_PATH).zip . $(ZIP_EXCLUDES)

clean: ## Cleanup x2t converter assemblies
	echo "Clear x2t assembly target dir: $(TARGET)_$(SDKJS_TAG_PATH)"
	rm -rf $(SDKJS_DIR)/deploy
	echo "Clear sdkjs build target dir: $(SDKJS_DIR)/deploy/sdkjs/"
	rm -rf ./build/$(TARGET)_$(SDKJS_TAG_PATH)

test: ## Run xt2 converter acceptance test
	echo "$@: Runs x2t converter for DOCX file with OLE fillable fields"

	# Download test files from Artifactory if not exists
	if [ ! -f "$(TEST_SRC_DIR)"/sample_fillable_fields.docx ]; then \
		$(call check_jfrog)
		jfrog rt dl --flat --recursive \
			onlyoffice-core/core/test_documents/all_fields_sample/* $(TEST_SRC_DIR)/
	fi

	# Download PDFComparer
	if [ ! -f "$(ARTIFACTORY_DIR)"/pdfcompare.jar ]; then \
		$(call check_jfrog)
			jfrog rt dl --flat --recursive onlyoffice-core/core/pdfcompare/* $(ARTIFACTORY_DIR)/
	fi

	cp $(TEST_SRC_DIR)/sample_fillable_fields.docx $(DEST_DIR)/source/sample_fillable_fields.docx

	# Create test.xml
	echo "$@: Write test run params -> $(DEST_DIR)/test.xml"
	echo "$${PARAMS_XML}" > $(DEST_DIR)/test.xml
	
	sed -i '' 's/input.docx/sample_fillable_fields.docx/g' $(DEST_DIR)/test.xml
	sed -i '' 's/output.pdf/sample_fillable_fields.pdf/g' $(DEST_DIR)/test.xml

	echo "$@: Run converer test: DOCX -> PDF"
	cd $(DEST_DIR) && ./x2t ./test.xml
	
	# Extract fields from PDF
	cat -v ./result/sample_fillable_fields.pdf | grep -E '{\"fontFamily' > ./result/sample_fillable_fields.txt

	# Workaround for magic behaviour of SDKJS with `pageNum` written as "BSa" or "NOa"
	# On workers, if there is no pageNum, we copying "BSa" -> "pageNum" and renaming "BSa" to "NOa"
	# For tests we expects always explicit behaviour when "pageNumber" and "BSa" are present
	sed -i '' 's/"NOa"/"BSa"/g' ./result/sample_fillable_fields.txt
	
	echo "$@: Compare extracted fillable fields with expected -> $(DEST_DIR)/result/sample_fillable_fields.txt"
	git --no-pager diff --no-index $(TEST_SRC_DIR)/sample_fillable_fields_expected.txt ./result/sample_fillable_fields.txt

---: ## --------------------------------------------------------------
help: .logo ## Show this help and exit
	echo SDKJS_VERSION: $(SDKJS_TAG)
	echo ''
	echo Build path:
	echo "  $(DEST_DIR)"
	echo ''
	echo "Usage:"
	echo "  make -f $(THIS_MAKEFILE) <target> <sdkjs-branch>"
	echo ''
	echo "Example:"
	echo "  make -f $(THIS_MAKEFILE) build sdkjs-branch=ovm_fillable_fields"
	echo ''
	echo "SDKJS options:"
	printf "  %-15s %s\n" "sdkjs-branch" "branch name which you want to use for build"
	printf "  %-15s %s\n" "            " "if not specified - use version from SDKJS_VERSION file"
	echo ''
	echo "Targets:"
	echo ''
	grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(THIS_MAKEFILE) | awk 'BEGIN {FS = ":.*?## "}; \
		{printf "  %-15s %s\n", $$1, $$2}'
	echo ''
%:
	@:
