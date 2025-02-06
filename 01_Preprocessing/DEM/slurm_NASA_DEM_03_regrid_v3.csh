#! /bin/csh -f
#SBATCH --job-name=dem_regrid
#SBATCH --mail-type=all         # Send email at begin and end of job
#SBATCH --nodes=1
#SBATCH --time=240:00:00
#SBATCH --ntasks-per-node=128
#SBATCH --nodelist=c1306ie05
#SBATCH --mem=256g
#SBATCH -p   cempd
#SBATCH -A rc_sarav_pi
module load r/4.4.0

Rscript NASA_DEM_03_regrid_v3.R