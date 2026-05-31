#!/bin/bash
#SBATCH --job-name=openmp
#SBATCH --partition=hype
#SBATCH --nodelist=hype1
#SBATCH --time=6:00:00
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err

rm -rf $SCRATCH/openmp
cp -r $SLURM_SUBMIT_DIR/ $SCRATCH/openmp
cd $SCRATCH/openmp

nixw nix develop .#pcad --command bash -c '
set -euo pipefail
bash exp/exp.sh
'
