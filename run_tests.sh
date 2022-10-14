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

export NSEMdir='/scratch2/COASTAL/coastal/noscrub/shared/Saeed.Moghimi/coastalapp_test/temp3/CoastalApp-testsuite'
export ROOTDIR='/scratch2/COASTAL/coastal/noscrub/shared/Saeed.Moghimi/coastalapp_test/temp3/CoastalApp'

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


storms=" shinnecock florence "

for STORM in $storms ; do 
    ########
    export STORM=$STORM
    ###
    # if condition is true
    if [ $STORM == florence ];
    then
        echo "    > Prep atm forcing and wav boundary for $STORM "

        #prep atm forcing
        COMINatm=${COMROOT}/atm/para/${STORM}
        mkdir -p ${COMINatm}
        cp -fv ${NSEMdir}/fix/forcing/${STORM}/ATM/* ${COMINatm}/.
        ###
        ## prep wav bou info
        COMINwav=${COMROOT}/ww3/para/${STORM}
        mkdir -p ${COMINwav}
        cp -fv ${NSEMdir}/fix/bou/${STORM}/WAV/* ${COMINwav}/.

        spinup=spinup.ecf
        fct=fct.ecf
    else
       #shinnecock    
        spinup=spinup_shi.ecf
        fct=fct_shi.ecf  
    fi
    ###
    export  RUN_TYPE=tide_spinup
    spinup_jobid=$(sbatch ${NSEMdir}/ecf/prep_spinup.ecf | awk '{print $NF}')
    spinup_jobid=$(sbatch --dependency=afterok:$spinup_jobid ${NSEMdir}/ecf/${spinup} | awk '{print $NF}')
    echo $spinup_jobid
    ###
    ## runs depends on ocn spin up
    run_types=" atm2ocn pam2ocn atm2wav2ocn "
    for RUN_TYPE in $run_types ; do 
        export RUN_TYPE=$RUN_TYPE
        echo "RUN_TYPE $RUN_TYPE";
        jobid=$(sbatch --dependency=afterok:$spinup_jobid  ${NSEMdir}/ecf/prep.ecf      | awk '{print $NF}')
        #jobid=$(sbatch                                    ${NSEMdir}/ecf/prep.ecf      | awk '{print $NF}')
        jobid=$(sbatch --dependency=afterok:$jobid         ${NSEMdir}/ecf/${fct}        | awk '{print $NF}')
        jobid=$(sbatch --dependency=afterok:$jobid         ${NSEMdir}/ecf/post.ecf      | awk '{print $NF}')
    done

    export RUN_TYPE=atm2wav
    jobid=$(sbatch ${NSEMdir}/ecf/prep.ecf  | awk '{print $NF}')
    jobid=$(sbatch --dependency=afterok:$jobid         ${NSEMdir}/ecf/${fct}           | awk '{print $NF}')
    jobid=$(sbatch --dependency=afterok:$jobid         ${NSEMdir}/ecf/post.ecf         | awk '{print $NF}')
done
# display job queue with dependencies
squeue -u $USER -o "%.8i %3C %4D %16E %12R %j" --sort i
echo squeue -u $USER -o \"%.8i %3C %4D %16E %12R %j\" --sort i
 





# Need for ww3 run from andre video:
# see pahm-adcirc-ww3-florence_hsofs_rerun2/run
# cp -p *mod* .
# cp -p *.inp .
# cp -p *nest*
# rm rads.64.nc
# cp *rads*







##  --------  old part
#$SBATCH ${NSEMdir}/ecf/forecast_spinup.ecf
#$SBATCH ${NSEMdir}/ecf/prep.ecf
#$SBATCH ${NSEMdir}/ecf/forecast.ecf
#$SBATCH ${NSEMdir}/ecf/post.ecf

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






