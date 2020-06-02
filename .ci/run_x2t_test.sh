#!/usr/bin/env bash

set -e

BASE_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." >/dev/null 2>&1 && pwd )"
X2T_BUILD=$BASE_PATH/X2tConverter/build/

EXPECTED_JSON="$X2T_BUILD"/sample_fillable_fields_expected.txt
ACTUAL_JSON="$X2T_BUILD"/fields_"$1".txt

# Expected arguments for pdfcompare.jar: file1 file2 [image directory] [page threshold] [pixel threshold] [kernel size]
PDFCOMPARE="java -jar pdfcompare.jar"
PDFCOMPARE_DIR="$BASE_PATH"/.artifactory
PDFCOMPARE_OPTS="$PDFCOMPARE_DIR/"

function extract_fields() {
	local pdf_file="$1"

	cat -v "$pdf_file" | grep "{"
}

function compare_fields() {
	local expected="$1"
	local actual="$2"

	colordiff -s -B "$expected" "$actual"
}

(>&1 echo "Searching Json fileds into PDF...")
extract_fields "$X2T_BUILD"/"$1"/result/output.pdf > "$X2T_BUILD"/fields_"$1".txt

(>&1 echo "Compare reference Json file with fields from PDF...")
compare_fields "$EXPECTED_JSON" "$ACTUAL_JSON"

(>&1 echo "Compare reference PDF file with converted PDF file...")
cd "$PDFCOMPARE_DIR" \
	&& $PDFCOMPARE \
	"$X2T_BUILD"/"$1"/result/output.pdf \
	"$X2T_BUILD"/sample_fillable_fields_expected.pdf \
	"$PDFCOMPARE_OPTS"
echo ""
