#!/usr/bin/env bash

###########################################################################
### Author:        Panagiotis Velissariou <panagiotis.velissariou@noaa.gov>
### Contributions: Saeed Moghimi <saeed.moghimi@noaa.gov>
###
### Version - 1.2
###
###   1.2 Fri Feb 24 2023
###   1.1 Tue Dec 20 2022
###   1.0 Fri Dec 09 2022
###########################################################################


####################
# Make sure that the current working directory is in the PATH
[[ ! :$PATH: == *:".":* ]] && export PATH="${PATH}:."

# Get the directory where the script is located
if [[ $(uname -s) == Darwin ]]; then
  readonly scrNAME="$( grealpath -s "${BASH_SOURCE[${#BASH_SOURCE[@]} - 1]}" )"
  readonly scrDIR="$(cd "$(dirname "${scrNAME}" )" && pwd -P)"
else
  readonly scrNAME="$( realpath -s "${BASH_SOURCE[${#BASH_SOURCE[@]} - 1]}" )"
  readonly scrDIR="$(cd "$(dirname "${scrNAME}" )" && pwd -P)"
fi
####################


####################
# Load the utility functions
lst="functions_tests ${scrDIR:+${scrDIR}/}functions_tests ${scrDIR:+${scrDIR}/}scripts/functions_tests"
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
  echo " ### ERROR :: in ${scrNAME}"
  echo "     Cannot load the required file: functions_tests"
  echo "     Exiting now ..."
  echo
  exit 1
fi

unset lst ilst funcs
####################


####################
# Source the file pointed by the TESTS_ENV_FILE environment variable
# (if it is set) to get any user defined values. If TESTS_ENV_FILE is
# not set try a file called "env_tests" next. We source
# these files before calling ParseArgsBuild below in case the user has
# already set some variables in these files.
if [ -z "${TESTS_ENV_FILE:-}" ]; then
  srchPATH="./ ${scrDIR} ${scrDIR}/scripts"
  for spath in ${srchPATH}
  do
    if [ -e ${spath}/env_tests ]; then
      source ${spath}/env_tests
      break
    fi
  done
else
  if [ -e "${TESTS_ENV_FILE}" ]; then
    source "${TESTS_ENV_FILE}"
  fi
fi
unset spath srchPATH
####################


#################################
### Script configuration
#################################

### This is for the module file to source. There is no a default
### value for this variable. The user is responsible to supply
### (or not) a valid module file to source (ususly from the CoastalApp/modulefiles directory).
export MOD_FILE=${MOD_FILE:-}

### This is for the location of the CoastalApp generated executables.
### The default value is: CoastalApp/ALLBIN_INSTALL.
### This script checks if the location of the BIN_DIR is valid (can be found and it is readable).
tmpVAL=${scrDIR:+${scrDIR}/}CoastalApp/ALLBIN_INSTALL
tmpVAL=${BIN_DIR:-${tmpVAL}}

if [ ! -d "${tmpVAL}" ]; then
  export BIN_DIR="${tmpVAL:-}"
#  echo "ERROR :: In ${scrNAME}"
#  echo "         The bin directory where the CoastalApp executables are located is not found."
#  echo "         Supplied value was: BIN_DIR = <${tmpVAL}>."
#  echo "Exiting ..."
#  exit 1
else
  export BIN_DIR="$(cd "${tmpVAL}" && pwd -P)"
fi

### This is for the location of the "common" directory where the large data used in the
### extended test cases are located. value for this variable. The user is responsible to supply
### The default value is: comm.
### This script doe not check if the location of the COM_DIR is valid, the check is performed
### by the individual "run_case.sh" scripts.
tmpVAL=${scrDIR:+${scrDIR}/}comm
tmpVAL=${COM_DIR:-${tmpVAL}}
if [ ! -d "${tmpVAL}" ]; then
  export COM_DIR="${tmpVAL:-}"
else
  export COM_DIR="$(cd "${tmpVAL}" && pwd -P)"
fi

### This is for the batch system to use when running jobs on a cluster environment.
### The default value is "slurm".
export BATCH_SYSTEM=${BATCH_SYSTEM:-slurm}

### This is for project account to use for the batch job.
### The default value is "coastal".
export BATCH_ACCOUNT=${BATCH_ACCOUNT:-coastal}

### This is for the HPC/BATCH_SYSTEM queue to use for the batch job.
### The default value is "batch".
export BATCH_QUEUE=${BATCH_QUEUE:-batch}

### This is for the HPC/BATCH_SYSTEM run executable to use.
### The default value is "srun".
export BATCH_RUNEXE=${BATCH_RUNEXE:-srun}


### This is the work directory where the individual tests are being run.
### The default value is: work.
tmpVAL=${scrDIR:+${scrDIR}/}work
export WORK_DIR=${WORK_DIR:-${tmpVAL}}

wdir=${WORK_DIR:-${tmpVAL}}

### This is the file that contains all the test cases to run.
### If a case is commented out, it won't submitted to run.
tmpVAL=${scrDIR:+${scrDIR}/}regtest_list.dat
TESTS_FILE=${TESTS_FILE:-${tmpVAL}}
#################################


#################################
### Call ParseArgs to get the user input.
### We use this function to allow to change on the fly any of the previously
### defined values for the environment variables.
ParseArgsTests "${@}"

export ACCEPT_ALL="${MY_ACCEPT_ALL}"
export MOD_FILE="${MY_MOD_FILE}"
export BIN_DIR="${MY_BIN_DIR}"
export COM_DIR="${MY_COM_DIR}"
export WORK_DIR="${MY_WORK_DIR}"
export TESTS_FILE="${MY_TESTS_FILE}"
export BATCH_SYSTEM="${MY_BATCH_SYSTEM}"
export BATCH_ACCOUNT="${MY_BATCH_ACCOUNT}"
export BATCH_QUEUE="${MY_BATCH_QUEUE}"
export BATCH_RUNEXE="${MY_BATCH_RUNEXE}"
#################################


#################################
# Get a final user response for the variables
echo
echo "The following variables are defined:"
echo "    ACCEPT_ALL    = ${ACCEPT_ALL}"
echo "    MOD_FILE      = ${MOD_FILE}"
echo "    BIN_DIR       = ${BIN_DIR}"
echo "    COM_DIR       = ${COM_DIR}"
echo "    WORK_DIR      = ${WORK_DIR}"
echo "    TESTS_FILE    = ${TESTS_FILE}"
echo "    BATCH_SYSTEM  = ${BATCH_SYSTEM}"
echo "    BATCH_ACCOUNT = ${BATCH_ACCOUNT}"
echo "    BATCH_QUEUE   = ${BATCH_QUEUE}"
echo "    BATCH_RUNEXE  = ${BATCH_RUNEXE}"


if [ "$( getYesNo "${ACCEPT_ALL:-0}" )" = "no" ]; then
  echo_response=
  while [ -z "${echo_response}" ] ; do
    echo -n "Are these values correct? [y/n]: "
    read echo_response
    echo_response="$( getYesNo "${echo_response}" )"
  done

  if [ "${echo_response:-no}" = "no" ]; then
    echo
    echo "User responded: ${echo_response}"
    echo "Exiting now ..."
    echo
    exit 1
  fi

  unset echo_response
else
  echo "User accepted all settings."
  sleep 2
fi
#################################


#################################
### Start the calculations
#################################
echo "$(basename "${scrNAME}"): Running all tests in: ${TESTS_FILE}"

if [ -f "${TESTS_FILE}" ]; then
  while read regtest      
  do
    if [ -n "${regtest:+1}" ]; then
      case "${regtest}" in \#*) continue ;; esac

      echo "> Running case: ${regtest}"

     wdir=${WORK_DIR:-work}/${regtest}
     if [ -d "${wdir}" ]; then
       mv -f ${wdir} ${wdir}_$(date +"%d%m%Y-%H%M%S")
     fi
     mkdir -p ${wdir}

     cp -rp ${regtest}/* ${wdir}/
     ${wdir}/run_case.sh
    fi
  done < ${TESTS_FILE}
else
  echo "${TESTS_FILE}: File not found"
fi

exit $?
