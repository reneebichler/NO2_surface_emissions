#! /bin/csh -f
#SBATCH --job-name=lcz_regrid
#SBATCH --partition=interact
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=8:00:00
#SBATCH --mem=128g
module load r/4.4.0

Rscript LCZ_01_regrid_v2.R