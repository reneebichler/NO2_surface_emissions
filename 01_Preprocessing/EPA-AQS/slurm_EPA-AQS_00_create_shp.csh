#! /bin/csh -f
#SBATCH --job-name=epa_shpp
#SBATCH --mail-user=rbichler@email.unc.edu
#SBATCH --mail-type=all         # Send email at begin and end of job
#SBATCH --nodes=1
#SBATCH --time=240:00:00
#SBATCH --ntasks-per-node=128
#SBATCH --nodelist=c1306ie02
#SBATCH --mem=256g
#SBATCH -p   cempd
#SBATCH -A rc_sarav_pi

Rscript EPA-AQS_00_create_shp_p.R