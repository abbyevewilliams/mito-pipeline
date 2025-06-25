#!/bin/bash
#SBATCH --job-name=dodo
#SBATCH --partition=short
#SBATCH --time=12:00:00
#SBATCH --output=slurm_%j.log
#SBATCH --error=slurm_%j.error

# Load necessary modules
ml Mamba/23.11.0-0

# Load environment with snakemake, new conda and dedup
source activate ./snakemake-env
conda config --set channel_priority strict

# Run the pipeline
snakemake --unlock
snakemake --workflow-profile profiles/slurm \
	--use-conda --use-singularity