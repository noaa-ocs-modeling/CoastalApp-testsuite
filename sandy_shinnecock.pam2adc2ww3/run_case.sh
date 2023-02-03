#!/bin/bash

export mod_loc=${ROOTDIR:+${ROOTDIR}/}modulefiles
export bin_loc=${ROOTDIR:+${ROOTDIR}/}ALLBIN_INSTALL

DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

# run spinup
pushd ${DIRECTORY}/spinup >/dev/null 2>&1
  setup_jobid=$(sbatch model_setup.job | awk '{print $NF}')
  spinup_jobid=$(sbatch --dependency=afterok:$setup_jobid model_run.job | awk '{print $NF}')
popd >/dev/null 2>&1

# run configurations
pushd ${DIRECTORY}/run >/dev/null 2>&1
  setup_jobid=$(sbatch model_setup.job | awk '{print $NF}')
  sbatch --dependency=afterok:$setup_jobid:$spinup_jobid model_run.job
popd >/dev/null 2>&1

# display job queue with dependencies
squeue -u $USER -o "%.8i %3C %4D %16E %j" --sort i

