#!/bin/bash

source $1
mkdir -p $sonicIn

for speciesDir in $transdecoderOut/*/; do
    species=$(basename $speciesDir)
    pepFile=$transdecoderOut/$species/${species}.Trinity-GG.fasta.transdecoder.pep

    ln -s $pepFile $sonicIn/${species}.fasta
done

echo "DONE"

sstat -j $SLURM_JOB_ID.batch --format=JobID,MaxVMSize