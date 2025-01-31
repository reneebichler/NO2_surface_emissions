#! /bin/csh -f
#SBATCH --job-name=cr_shp
#SBATCH --partition=interact
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=8:00:00
#SBATCH --mem=96g

python3 TROPOMI_00_L2_L3.py