#! /bin/csh -f
#SBATCH --job-name=shp_grid
#SBATCH --mail-user=rbichler@email.unc.edu
#SBATCH --mail-type=all         # Send email at begin and end of job
#SBATCH --nodes=1
#SBATCH --time=240:00:00
#SBATCH --ntasks-per-node=128
#SBATCH --nodelist=c1306ie01
#SBATCH --mem=256g
#SBATCH -p   cempd
#SBATCH -A rc_sarav_pi
module load r/4.4.0

Rscript create_shp_grid.R