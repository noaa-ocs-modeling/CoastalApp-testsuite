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
export BATCH_QOS=${BATCH_QOS:-}
export BATCH_RUNEXE=${BATCH_RUNEXE:-}
##########


####################
### Get the required data files and make the corresponding links to them.
error=0
if [ -d "${COM_DIR}" ]; then
  pushd ${MY_DIR}/run >/dev/null 2>&1
    ##### BEG:: ADCIRC #####
    ### (A) Mesh data
    for i in fort.13 fort.14
    do
      fname="${COM_DIR}/mesh/${i}"
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
      fname="${COM_DIR}/data/adc/${i}"
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
      fname="${COM_DIR}/data/atm/${i}"
      if [ -f ${fname} ]; then
        [ -f ${i} ] && rm -f ${i}
        ln -sf ${fname} ${i}
      else
        echo "The required atmospheric forcing file ${fname} is not found."
        echo "Exiting this run_case.sh script ..."
        error=4
        break
      fi
    done
  popd >/dev/null 2>&1
else
  echo "The required data directory COM_DIR = <${COM_DIR}> is not found."
  echo "Exiting this run_case.sh script ..."
  error=1
fi
[ ${error:-0} -gt 0 ] && exit ${error}
####################


run_jobid="$( model_run run )"

