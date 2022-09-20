#!/bin/bash --login
# ----------------------------------------------------------- 
# UNIX Shell Script File
# Tested Operating System(s): RHEL 7
# Tested Run Level(s): 
# Shell Used: BASH shell
# Original Author(s): Saeed Moghimi
# File Creation Date: 09/17/2022
# Date Last Modified:
#
# Version control: 1.00
#
# Support Team:
#
# Contributors:   
#
# ----------------------------------------------------------- 
# ------------- Program Description and Details ------------- 
# ----------------------------------------------------------- 
#
# Execute script to perform CoastalApp test runs 
#
# ----------------------------------------------------------- 

# Saeed next steps on 09/17/2022
#TODO add clone the code and compile CoastalApp
#TODO add tide_fac to ALLBIN folder
#TODO automated copy of the atmesh input to com folder
#TODO add ww3 to netcdf conversion
#TODO add py env yaml file
#TODO add plot basic mesh and timeseries
#

export PS4=' $SECONDS + '
set -x

export NSEMdir=${NSEMdir:-/scratch2/COASTAL/coastal/noscrub/shared/Saeed.Moghimi/coastalapp_test/tests/NSEM-workflow}
export ROOTDIR=${ROOTDIR:-/scratch2/COASTAL/coastal/noscrub/shared/Saeed.Moghimi/coastalapp_test/codes/CoastalApp}

############
#echo 'Fetching externals...'
#mkdir -p ${NSEMdir}/fix/
#cp -rp /scratch2/COASTAL/coastal/save/shared/CoastalApp_test_fix/fix/* ${NSEMdir}/fix/*
############

# load python env
# for now using the one on hera
#TODO add py env env file to repo

# set COMROOT
export COMROOT=${COMROOT:-${NSEMdir}/../${USER}/com/}

# set exec folder
ln -sfv ${ROOTDIR}/ALLBIN_INSTALL  ${NSEMdir}/exec

########
export STORM=shinnecock
#prep COMin
COMINatm=${COMROOT}/atm/para/${STORM}


###
export  RUN_TYPE=tide_spinup
spinup_jobid=$(sbatch ecf/jnsem_prep_spinup.ecf | awk '{print $NF}')
spinup_jobid=$(sbatch --dependency=afterok:$spinup_jobid ecf/jnsem_forecast_spinup.ecf | awk '{print $NF}')
echo $spinup_jobid
###
export RUN_TYPE=atm2ocn
jobid=$(sbatch --dependency=afterok:$spinup_jobid  ecf/jnsem_prep.ecf      | awk '{print $NF}')
jobid=$(sbatch --dependency=afterok:$jobid         ecf/jnsem_forecast.ecf  | awk '{print $NF}')
jobid=$(sbatch --dependency=afterok:$jobid         ecf/jnsem_post.ecf      | awk '{print $NF}')
###
export RUN_TYPE=atm2wav2ocn
#jobid=$(sbatch --dependency=afterok:$spinup_jobid  ecf/jnsem_prep.ecf      | awk '{print $NF}')
#jobid=$(sbatch --dependency=afterok:$jobid         ecf/jnsem_forecast.ecf  | awk '{print $NF}')
#jobid=$(sbatch --dependency=afterok:$jobid         ecf/jnsem_post.ecf      | awk '{print $NF}')
###
export RUN_TYPE=atm2wav
#jobid=$(sbatch ecf/jnsem_prep.ecf  | awk '{print $NF}')
#jobid=$(sbatch --dependency=afterok:$jobid         ecf/jnsem_forecast.ecf  | awk '{print $NF}')
#jobid=$(sbatch --dependency=afterok:$jobid         ecf/jnsem_post.ecf      | awk '{print $NF}')


# display job queue with dependencies
squeue -u $USER -o "%.8i %3C %4D %16E %12R %j" --sort i
echo squeue -u $USER -o \"%.8i %3C %4D %16E %12R %j\" --sort i
 


##  --------  old part
#$SBATCH ecf/jnsem_forecast_spinup.ecf
#$SBATCH ecf/jnsem_prep.ecf
#$SBATCH ecf/jnsem_forecast.ecf
#$SBATCH ecf/jnsem_post.ecf



### from Zach
#echo deleting previous ADCIRC output
#sh cleanup.sh
#DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

# run spinup
#pushd ${DIRECTORY}/spinup >/dev/null 2>&1
#setup_jobid=$(sbatch setup.job | awk '{print $NF}')
#spinup_jobid=$(sbatch --dependency=afterok:$setup_jobid adcirc.job | awk '{print $NF}')
#popd >/dev/null 2>&1

# run configurations
#for hotstart in ${DIRECTORY}/runs/*/; do
#    pushd ${hotstart} >/dev/null 2>&1
#    setup_jobid=$(sbatch setup.job | awk '{print $NF}')
#    sbatch --dependency=afterok:$setup_jobid:$spinup_jobid adcirc.job
#    popd >/dev/null 2>&1
#done

# display job queue with dependencies
#squeue -u $USER -o "%.8i %3C %4D %16E %12R %j" --sort i
#echo squeue -u $USER -o \"%.8i %3C %4D %16E %12R %j\" --sort i
