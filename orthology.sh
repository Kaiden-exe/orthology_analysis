#!/bin/bash

# Author: Kaiden R. Sewradj

############################
########## CHECKS ##########
############################
while [ $# -gt 0 ]; do
	case $1 in
    #TODO
		-h | --help)
			echo "Follow instructions in the template configuration file."
			echo "Then run bash orthology.sh -c config.sh"
			exit 0
        ;;
		-c | --config)
			if [ ! -f "$2" ]; then
				echo "Configuration file not found" >&2
				exit 1
			fi

			configFile=$2
			shift
		;;
		*)
			echo "Invalid option: $1" >&2
			exit 1
		;;
    esac
	shift
done

if [ ! -f "$configFile" ]; then
	echo "ERROR: Configuration file $configFile not found" >&2
	exit 1
fi

source $configFile

# Create copies to have a folder with just fasta files 
if [ ! -z "${transdecoderOut}" ] ; then
    job0=$(sbatch -J symlink -n 1 -N 1 --mem=6G -o logfiles/symlink.A%.out -e logfiles/symlink.A%.error -A tardi_genomic -p fast -t 0-23:00:00 scripts/symlink.sh $configFile)
    jobID0=${job0##* }
    echo Creating symlinks job $jobID0
else
    jobID0=-1
fi

if [ $jobID0 -eq -1 ] ; then
	job1=$(sbatch -J sonic_test -n 32 --mem=80G -o logfiles/sonicparanoid.%A.out -e logfiles/sonicparanoid.%A.error -A tardi_genomic -p long -t 2-23 scripts/sonic.sh $configFile)
else
	job1=$(sbatch -J sonic_test -n 32 --mem=80G -o logfiles/sonicparanoid.%A.out -e logfiles/sonicparanoid.%A.error -A tardi_genomic -p long -t 2-23 --dependency=afterok:${jobID0} scripts/sonic.sh $configFile)
fi
jobID1=${job1##* }
echo SonicParanoid job $jobID1
