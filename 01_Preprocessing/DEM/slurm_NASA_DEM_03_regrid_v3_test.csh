#! /bin/csh -f
#SBATCH --job-name=dem_regrid
#SBATCH --partition=interact
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=8:00:00
#SBATCH --mem=128g
module load r/4.4.0

Rscript NASA_DEM_03_regrid_v3.R