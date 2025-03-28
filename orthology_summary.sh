#!/bin/bash

# Author: Kaiden R. Sewradj

############################
########## CHECKS ##########
############################
OGfile=$1

if [ ! -f "$OGfile" ]; then
	echo "ERROR: ortholog_groups.tsv not found" >&2
    echo "USAGE: bash orthology_summary.sh <path to ortholog_groups.tsv>"
	exit 1
fi

mkdir -p summary

module load r

Rscript --vanilla scripts/orthology_summary.R $OGfile summary
