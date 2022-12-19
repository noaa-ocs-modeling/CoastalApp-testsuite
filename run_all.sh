#!/usr/bin/env bash

###########################################################################
### Author:        Panagiotis Velissariou <panagiotis.velissariou@noaa.gov>
### Contributions: Saeed Moghimi <saeed.moghimi@noaa.gov>
###
### Version - 1.0
###
###   1.0 Fri Dec 09 2022
###########################################################################


###====================
# Make sure that the current working directory is in the PATH
[[ ! :$PATH: == *:".":* ]] && export PATH="${PATH}:."


####################
# Get the directory where the script is located
if [[ $(uname -s) == Darwin ]]; then
  readonly scrNAME="$( grealpath -s "${BASH_SOURCE[${#BASH_SOURCE[@]} - 1]}" )"
  readonly scrDIR="$(cd "$(dirname "${scrNAME}" )" && pwd -P)"
else
  readonly scrNAME="$( realpath -s "${BASH_SOURCE[${#BASH_SOURCE[@]} - 1]}" )"
  readonly scrDIR="$(cd "$(dirname "${scrNAME}" )" && pwd -P)"
fi
####################


#################################
### Script configuration
#################################
### This is the work directory where the tests are being run
tmpVAL=${scrDIR:+${scrDIR}/}work
WORKdir=${WORKdir:-${tmpVAL}}

### This is the COMM directory where large input files are stored (e.g., HSOFS data files)
tmpVAL=${scrDIR:+${scrDIR}/}comm
COMMDIR=${1:-${COMMDIR}}
COMMDIR=${COMMDIR:-${tmpVAL}}
if [ -d "${COMMDIR}" ]; then
  export COMMDIR="$(cd "${COMMDIR}" && pwd -P)"
else
  echo "The COMMDIR = ${COMMDIR} is not found."
fi

### This is the CoastalApp root directory
tmpVAL=${scrDIR:+${scrDIR}/}../CoastalApp
ROOTDIR=${1:-${ROOTDIR}}
ROOTDIR=${ROOTDIR:-${tmpVAL}}
if [ -d "${ROOTDIR}" ]; then
  export ROOTDIR="$(cd "${ROOTDIR}" && pwd -P)"
else
  echo "The ROOTDIR = ${ROOTDIR} is not found."
fi

echo "ROOTDIR = ${ROOTDIR}"
echo "COMMDIR = ${COMMDIR}"

### This is not needed, it will be deleted
export EXECnsem=${ROOTDIR}/ALLBIN_INSTALL
exit 1
### This is the file that contains all the test cases to run.
### If a case is commented out, it is not run
TESTLIST=regtest_list.dat
#################################


#################################
### Start the calculations
#################################
echo "$(basename "${scrNAME}"): Running all tests in: ${TESTLIST}"

if [ -f "${TESTLIST}" ]; then
  while read regtest      
  do
    if [ -n "${regtest:+1}" ]; then
      case "${regtest}" in \#*) continue ;; esac

      echo "> Running case: ${regtest}"

     work_dir=${WORKdir:-work}/${regtest}
     if [ -d "${work_dir}" ]; then
       mv -f ${work_dir} ${work_dir}_$(date +"%d%m%Y-%H%M%S")
     fi
     mkdir -p ${work_dir}

     cp -rp ${regtest}/* ${work_dir}/
     ${work_dir}/run_case.sh
    fi
  done < ${TESTLIST}
else
  echo "${TESTLIST}: File not found"
fi

exit $?
