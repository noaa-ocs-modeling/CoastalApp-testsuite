#!/usr/bin/env bash

###########################################################################
## Author:  Panagiotis Velissariou <panagiotis.velissariou@noaa.gov>
##
## Version: 1.0
##
## Version - 1.0 Fri Feb 10 2023
###########################################################################


####################
# Make sure that the current working directory is in the PATH
[[ ! :$PATH: == *:".":* ]] && export PATH="${PATH}:."

# Get the directory where the script is located
if [[ $(uname -s) == Darwin ]]; then
  readonly MY_NAME="$( grealpath -s "${BASH_SOURCE[${#BASH_SOURCE[@]} - 1]}" )"
  readonly MY_DIR="$(cd "$(dirname "${MY_NAME}" )" && pwd -P)"
else
  readonly MY_NAME="$( realpath -s "${BASH_SOURCE[${#BASH_SOURCE[@]} - 1]}" )"
  readonly MY_DIR="$(cd "$(dirname "${MY_NAME}" )" && pwd -P)"
fi
####################


####################
# Load the utility functions
lst="functions_testcase ${MY_DIR:+${MY_DIR}/}functions_testcase ${MY_DIR:+${MY_DIR}/}scripts/functions_testcase"
funcs=
for ilst in ${lst}
do
  if [ -f "${ilst:-}" ]; then
    funcs="${ilst}"
    break
  fi
done

if [ -n "${funcs:+1}" ]; then
  source "${funcs}"
  [ $? -ne 0 ] && exit 1
else
  echo " ### ERROR :: in ${MY_NAME}"
  echo "     Cannot load the required file: functions_testcase"
  echo "     Exiting now ..."
  echo
  exit 1
fi

unset lst ilst funcs
####################


##########
### Global variables
export MOD_FILE=${MOD_FILE:-}
export BIN_DIR=${BIN_DIR:-}
export COM_DIR=${COM_DIR:-}
export BATCH_SYSTEM=${BATCH_SYSTEM:-}
export BATCH_ACCOUNT=${BATCH_ACCOUNT:-}
export BATCH_QUEUE=${BATCH_QUEUE:-}
export BATCH_RUNEXE=${BATCH_RUNEXE:-}
##########


####################
### Get the required data files and make the corresponding links to them.
error=0
if [ -d "${COM_DIR}" ]; then
  pushd ${MY_DIR}/run >/dev/null 2>&1
    ##### BEG:: FVCOM #####
    ### (A) Nest file
    finp="${COM_DIR}/data/fvc/sci_nest_20220621.nc"
    fout="input/sci_nest.nc"
    if [ -f ${finp} ]; then
      [ -f ${fout} ] && rm -f ${fout}
      ln -sf ${finp} ${fout}
    else
      echo "ERROR:: The required fvcom file ${finp} is not found."
      error=$((error + 2))
    fi

    ### (B) Restart file
    finp="${COM_DIR}/data/fvc/sci_restart_20220621.nc"
    fout="input/sci_restart_20220621.nc"
    if [ -f ${finp} ]; then
      [ -f ${fout} ] && rm -f ${fout}
      ln -sf ${finp} ${fout}
    else
      echo "ERROR:: The required fvcom file ${finp} is not found."
      error=$((error + 1))
    fi
    ##### END:: FVCOM #####

    ##### BEG:: Atmospheric data #####
    ### (C) Atmospheric forcing data file for FVCOM
    finp="${COM_DIR}/data/atm/sci_wrf_20220621.nc"
    fout="input/wrf_for.nc"
    if [ -f ${finp} ]; then
      [ -f ${fout} ] && rm -f ${fout}
      ln -sf ${finp} ${fout}
    else
      echo "ERROR:: The required fvcom file ${finp} is not found."
      error=$((error + 1))
    fi
    ##### END:: Atmospheric data #####
  popd >/dev/null 2>&1
else
  echo "ERROR:: The required data directory COM_DIR = <${COM_DIR}> is not found."
  error=1
fi

if [ ${error:-0} -gt 0 ]; then
  echo "Exiting this run_case.sh script due to errors ..."
  exit ${error}
fi
####################


run_jobid="$( model_run run )"

