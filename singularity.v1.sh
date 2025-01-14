#!/bin/bash
set -eu
scriptName="$1"
# Nom de l'instance
INSTANCE_NAME="hol2dk"
SIF_FILE=hol2dk.0.2.1.sif
SINGULARITY_IMAGE=alidra/alidra/dedukti-hol2dk.0.2.1:latest
TARGET_DIR="$2"

# Charger le module singularity
module load singularity/3.7.1 

mkdir -p $TARGET_DIR
cd $TARGET_DIR

# Vérifie si l'instance existe déjà
if ! singularity instance list | grep -q "$INSTANCE_NAME"; then
    # Si l'instance n'existe pas, crée-la
    if [ ! -f "$HOME/$SIF_FILE" ]; then
	echo "image not found locally. Pulling..."
	singularity pull --dir "$HOME" --arch amd64 "$SIF_FILE" library://"$SINGULARITY_IMAGE"
    else
	echo "$HOME/$SIF_FILE already exists locally. skipping pull"
    fi
    singularity instance start -B ~/hol-light:/tmp/hol-light -B ~/hol2dk:/home/opam/hol2dk -B $PWD:/tmp "$HOME/$SIF_FILE" "$INSTANCE_NAME"
else
    # Si l'instance existe déjà, ne rien faire
    echo "L'instance '$INSTANCE_NAME' existe déjà."
fi

echo starting script $scriptName with file 

singularity exec --no-home instance://"$INSTANCE_NAME" $scriptName
