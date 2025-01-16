#!/bin/bash
# This script is executed by the slave `thishostname`
set -eu

listOfFiles=$(cat $1)
string=$(echo "$listOfFiles" | tr ' ' '\n' | sort | tr '\n' ' ')
#echo inside make_spec_abbrevs_sharedFolder : $string
IFS=' ' read -ra LIST_OF_FILES <<< $string
echo First v file is ${LIST_OF_FILES[1]}

export NB_PROC=$(nproc)
# RW_FOLDER=/tmp
export HOL2DK_DIR=$RW_FOLDER/hol2dk
export HOLLIGHT_DIR=$RW_FOLDER/hol-light

cd $RW_FOLDER/$OUTPUT_FOLDER_NAME

# env SPEC_ABBREVS_FILES is exported for each slave and needed by make entry spec_abbrevs_vo
export SPEC_ABBREVS_FILES=${LIST_OF_FILES[@]}
# echo list of files : ${LIST_OF_FILES[@]}
# echo list of spec files : $SPEC_ABBREVS_FILES
make -j$NB_PROC vo # -f distributed.mk spec_abbrevs_vo
