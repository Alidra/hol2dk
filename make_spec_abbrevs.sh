#!/bin/bash
set -eu
MASTER_NODE=$1
LIST_OF_FILES=$2

NB_PROC=echo $(nproc)
RW_FOLDER=/scratch
# Copy hol-light and hol2dk to a RW folder
cp -r $HOL2DK_DIR $RW_FOLDER/hol2dk
cp -r $HOLLIGHT_DIR $RW_FOLDER/hol-light
export HOL2DK_DIR=$RW_FOLDER/hol2dk
export HOLLIGHT_DIR=$RW_FOLDER/hol-light

mkdir -p $RW_FOLDER/output
cd $RW_FOLDER/output

scp MASTER_NODE:$LIST_OF_FILES .
hol2dk link $TARGET_FILE HOLLight_Real.HOLLight_Real --root-path $HOL2DK_DIR/HOLLight.v Rdefinitions Rbasic_fun Raxioms


make spec_abbrevs_vo
