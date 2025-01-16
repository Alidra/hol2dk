#!/bin/bash

export MARGARET_HOME=$1
export listOfFiles=$2
$MARGARET_HOME/hol2dk/singularity.v1.sh "$MARGARET_HOME/hol2dk/make_spec_abbrevs_sharedFolder.sh $listOfFiles" /scratch/abdelghani
