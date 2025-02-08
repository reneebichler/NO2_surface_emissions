#! /bin/csh -f
#SBATCH --job-name=shp_extract
#SBATCH --mail-user=rbichler@email.unc.edu
#SBATCH --mail-type=all         # Send email at begin and end of job
#SBATCH --partition=interact
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=8:00:00
#SBATCH --mem=128g

Rscript 01_extract_grid_TROPOMI.R