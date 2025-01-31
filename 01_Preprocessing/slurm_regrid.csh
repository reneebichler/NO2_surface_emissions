#! /bin/csh -f
#SBATCH --job-name=cr_shp
#SBATCH --partition=interact
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=8:00:00
#SBATCH --mem=128g
module load r/4.4.0

Rscript create_shp_grid.R
