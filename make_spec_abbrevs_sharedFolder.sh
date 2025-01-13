#!/bin/bash
# This script is executed by the slave `thishostname`
set -eu
MASTER_NODE=$1
string=$(echo "$2" | tr ' ' '\n' | sort | tr '\n' ' ')
IFS=' ' read -ra LIST_OF_FILES <<< $string
echo ${LIST_OF_FILES[1]}

NB_PROC=echo $(nproc)
RW_FOLDER=/tmp
export HOL2DK_DIR=$RW_FOLDER/hol2dk
export HOLLIGHT_DIR=$RW_FOLDER/hol-light

cd $RW_FOLDER/output

# env SPEC_ABBREVS_FILES is exported for each slave and needed by make entry spec_abbrevs_vo
export SPEC_ABBREVS_FILES=$LIST_OF_FILES
make spec_abbrevs_vo
