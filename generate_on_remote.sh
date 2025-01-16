#!/bin/bash

export MARGARET_HOME=$1
export listOfFiles=$2
echo in generate on remote liste of file is : $listOfFiles
$MARGARET_HOME/hol2dk/singularity.v1.sh "$MARGARET_HOME/hol2dk/make_spec_abbrevs_sharedFolder.sh $listOfFiles" /scratch/abdelghani
