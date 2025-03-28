#!/bin/bash

module load sonicparanoid
source $1

# Check if input directory exists
if [ ! -d $sonicIn ] ; then
    echo "ERROR: $sonicIn NOT FOUND"
    exit 1
fi

# Check if there are files in the directory
fileCount=$(ls $sonicIn | wc -l)
if [ $fileCount -lt 2 ] ; then
    echo "ERROR: NOT ENOUGH INPUT FILES (minimum 2)"
    exit 1
fi

suffix=$(date "+%Y%m%d%H%M%S")

# Check if updating run or running new one
if [ -d "$sonicOut/runs/" ] && [ ! -z "$( ls -A "$sonicOut/runs")" ]; then
    sonicparanoid -i $sonicIn -o $sonicOut -p "tardi_genomic_$suffix" -t 32 -m sensitive -ot
else
    sonicparanoid -i $sonicIn -o $sonicOut -p "tardi_genomic_$suffix" -t 32 -m sensitive
fi
echo "DONE"

sstat -j $SLURM_JOB_ID.batch --format=JobID,MaxVMSize
