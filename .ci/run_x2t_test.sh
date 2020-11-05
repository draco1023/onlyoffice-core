#!/usr/bin/env bash

set -e

BASE_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." >/dev/null 2>&1 && pwd )"
X2T_BUILD=$BASE_PATH/X2tConverter/build

EXPECTED_JSON="$X2T_BUILD"/sample_fillable_fields_expected.txt
ACTUAL_JSON="$X2T_BUILD"/"$1"/result/fields_"$1".txt

# Expected arguments for pdfcompare.jar: file1 file2 [image directory] [page threshold] [pixel threshold] [kernel size]
PDFCOMPARE="java -jar pdfcompare.jar"
PDFCOMPARE_DIR="$BASE_PATH"/.artifactory
PDFCOMPARE_OPTS="$X2T_BUILD"/"$1"/result/diff

function extract_fields() {
	local pdf_file="$1"

	cat -v "$pdf_file" | grep "{\"fontFamily"
}

function compare_fields() {
	local expected="$1"
	local actual="$2"

	diff -s -B "$expected" "$actual"
}

(>&1 echo "Searching Json fields into PDF...")
extract_fields "$X2T_BUILD"/"$1"/result/output.pdf > "$X2T_BUILD"/"$1"/result/fields_"$1".txt

(>&1 echo "Fixing SDKJS mystical behaviour with pageNumber...")
# Workaround for magic behaviour of SDKJS with `pageNum` written as "BSa" or "NOa"
# On workers, if there is no pageNum, we copying "BSa" -> "pageNum" and renaming "BSa" to "NOa"
# For tests we expects always explicit behaviour when "pageNumber" and "BSa" are present
sed -i '' 's/"NOa"/"BSa"/g' "$ACTUAL_JSON"

(>&1 echo "Compare reference Json file with fields from PDF...")
compare_fields "$EXPECTED_JSON" "$ACTUAL_JSON"

(>&1 echo "Compare reference PDF file with converted PDF file...")
cd "$PDFCOMPARE_DIR" \
	&& $PDFCOMPARE \
	"$X2T_BUILD"/"$1"/result/output.pdf \
	"$X2T_BUILD"/sample_fillable_fields_expected.pdf \
	"$PDFCOMPARE_OPTS"
echo ""
