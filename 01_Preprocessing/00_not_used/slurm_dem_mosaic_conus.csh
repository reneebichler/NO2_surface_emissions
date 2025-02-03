#! /bin/csh -f
#SBATCH --job-name=dem_mosaic
#SBATCH --mail-type=all         # Send email at begin and end of job
#SBATCH --nodes=1
#SBATCH --time=120:00:00
#SBATCH --ntasks-per-node=128
#SBATCH --nodelist=c1306ie06
#SBATCH --mem=256g
#SBATCH -p   cempd
#SBATCH -A rc_sarav_pi
module load r/4.4.0

Rscript NASA_DEM_02_mosaic_conus.R
