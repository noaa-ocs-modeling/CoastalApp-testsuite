#!/bin/bash

export mod_loc=${ROOTDIR:+${ROOTDIR}/}modulefiles
export bin_loc=${ROOTDIR:+${ROOTDIR}/}ALLBIN_INSTALL

DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"


####################
### Get the required data files and make the corresponding links to them.
error=0
if [ -d "${COMMDIR}" ]; then
  pushd ${DIRECTORY}/run >/dev/null 2>&1
    ##### BEG:: ADCIRC #####
    ### (A) Mesh data
    for i in fort.13 fort.14
    do
      fname="${COMMDIR}/mesh/${i}"
      if [ -f ${fname} ]; then
        [ -f ${i} ] && rm -f ${i}
        ln -sf ${fname} ${i}
      else
        echo "The required adcirc file ${fname} is not found."
        echo "Exiting this run_case.sh script ..."
        error=2
        break
      fi
    done

    ### (B) Spinup data
    for i in fort.67.nc
    do
      fname="${COMMDIR}/data/adc/${i}"
      if [ -f ${fname} ]; then
        [ -f ${i} ] && rm -f ${i}
        ln -sf ${fname} ${i}
      else
        echo "The required adcirc file ${fname} is not found."
        echo "Exiting this run_case.sh script ..."
        error=3
        break
      fi
    done
    ##### END:: ADCIRC #####

    ### (C) Atmospheric data
    for i in Florence_HWRF_HRRR_HSOFS.nc
    do
      fname="${COMMDIR}/data/atm/${i}"
      if [ -f ${fname} ]; then
        [ -f ${i} ] && rm -f ${i}
        ln -sf ${fname} atm_forcing.nc
      else
        echo "The required atmospheric forcing file ${fname} is not found."
        echo "Exiting this run_case.sh script ..."
        error=4
        break
      fi
    done
  popd >/dev/null 2>&1
else
  echo "The required data directory COMMDIR = <${COMMDIR}> is not found."
  echo "Exiting this run_case.sh script ..."
  error=1
fi
[ ${error:-0} -gt 0 ] && exit ${error}
####################


# run configurations
pushd ${DIRECTORY}/run >/dev/null 2>&1
  setup_jobid=$(sbatch model_setup.job | awk '{print $NF}')
  sbatch --dependency=afterok:$setup_jobid model_run.job
popd >/dev/null 2>&1

# display job queue with dependencies
squeue -u $USER -o "%.8i %3C %4D %16E %j" --sort i
