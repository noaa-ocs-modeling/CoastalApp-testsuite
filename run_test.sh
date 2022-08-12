#!/usr/bin/env bash

###########################################################################
### Author:  Panagiotis Velissariou <panagiotis.velissariou@noaa.gov>
###
### Version - 1.0
###
###   1.0 Fri 05 Aug 2022
###########################################################################


###==================== BEG:: SCRIPT INITIALIZATION SECTION  ====================
### For variable configuration of script calculations see after this section

####################
# Make sure that the current working directory is in the PATH
[[ ! :$PATH: == *:".":* ]] && export PATH="${PATH}:."
####################


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


if [ $# -lt 3 ] ; then
    echo "ERROR: ${scrNAME}: requires 2 arguments with folder containing executables and path to case which will be run."
    exit 1
fi

bin_dir="${1}"
mod_file="${2}"
case_name="${3}"

#...Maximum Error
err=0.00001

# Check if bin_dir exists
if [ ! -d "${bin_dir}" ] ; then
  echo "ERROR: ${scrNAME}: You must provide a valid directory where the model executables are located."
  exit 1
fi

# Check if mod_file exists
if [ ! -f "${mod_file}" ] ; then
  echo "ERROR: ${scrNAME}: You must provide a valid module file. This regression test system depends upon environment modules."
  exit 1
fi

# Check if case/run.sh exists
if [ ! -f "${case_name}/run.sh" ] ; then
  echo "ERROR: ${scrNAME}: Case directory does not exist or does not contain run.sh."
  exit 1
fi

pushd ${case_name} >/dev/null 2>&1
  ./run.sh --bin=${bin_dir} --mod=${mod_file} --tol=${err:-0.00001}
popd >/dev/null 2>&1

exit 0
