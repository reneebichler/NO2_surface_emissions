#! /bin/csh -f
#SBATCH --job-name=lcz_regrid
#SBATCH --mail-user=rbichler@email.unc.edu
#SBATCH --mail-type=all
#SBATCH --nodes=1
#SBATCH --time=192:00:00
#SBATCH --ntasks-per-node=128
#SBATCH --nodelist=c1306ie01
#SBATCH --mem=256g
#SBATCH -p   cempd
#SBATCH -A rc_sarav_pi

Rscript LCZ_01_regrid_v3.R