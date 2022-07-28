#!/usr/bin/env bash

###########################################################################
### Author:  Panagiotis Velissariou <panagiotis.velissariou@noaa.gov>
###
### Version - 1.0
###
###   1.0 Sun 15 July 2028
###########################################################################


### The values of the default environment variables for this script are defined
### at the top of the "functions_run" file
### The default variables are: defBinDir, defTolerance, defNProcs, defModFile, defCompiler
###
### Test case related configurations are in the "TEST CASE SECTION" below


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


####################
# Load the utility functions
lst="${scrDIR:+${scrDIR}/}functions_run ${scrDIR:+${scrDIR}/}scripts/functions_run functions_run"
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
  echo "     Cannot load the required file: functions_run"
  echo "     Exiting now ..."
  echo
  exit 1
fi

unset ilst funcs
####################

###==================== END:: SCRIPT INITIALIZATION SECTION  ====================


###==================== BEG:: SCRIPT CONFIGURATION SECTION  ====================
### Here we set the script environment and variables to be used in the subsequent calculations.

# Call ParseArgs to get the user input.
# Call the script with the -h|--h|-help|--help option to see
# all available options that might be passed to the script.
ParseArgs "${@}"


####################
### Get the "bin" directory where the model executables are located.
binDir=
for iCnt in "${MY_BINDIR}" "${defBinDir}" "."
do
  checkDIR -r "${iCnt}"
  if [ $? -eq 0 ]; then
    binDir="${iCnt}"
    break
  fi
done
unset iCnt
####################


####################
### Get the "tolerance" to be used in the data comparison.
tolerance=${defTolerance:-1.0E-3}
if $( isPosNumber "${MY_TOLERANCE}" ); then
  tolerance="${MY_TOLERANCE}"
fi
####################


####################
### The following is for the module system (if it is used)
# (1) Check if the module command exists in the host system by calling
#     checkModuleCmd (exports the modulecmd_ok variable).
#     If modulecmd_ok >= 1, then the module command is available to this script.
checkModuleCmd

# (2) Get the module file to source. The module file file should contain
#     all the module commands to load the required modules.
modFile=
for iCnt in "${MY_MODFILE}" "${defModFile}"
do
  checkFILE -r "${iCnt}"
  if [ $? -eq 0 ]; then
    modFile="${iCnt}"
    break
  fi
done
unset iCnt
####################

###==================== END:: SCRIPT CONFIGURATION SECTION  ====================


###==================== BEG:: TEST CASE SECTION  ====================

####################
### Set the test case name
caseName="$( basename ${scrDIR} )"

### Load the required modules per user request
if [ ${modulecmd_ok:-0} -ge 1 ] && [ -n "${modFile:+1}" ]; then
  source ${modFile}
  if [ $? -ne 0 ]; then
    procError "Sourcing the module file ${modFile}" \
              "produced errors"
  fi
fi
####################


####################
### Check for the required executables

# (1) System wide programs. These should be in the user's PATH or built-in commands
prog_name=nccmp
  progNCCMP="$( getPROG ${prog_name} "${binDir} ${defBinDir}" )"
  errstat=$?
  if [ ${errstat} -ne 0 ]; then
    procError "The executable \"${prog_name}\" is not found" \
              "This is a required program for this test."
  fi

# (2) Test case programs (models). These are pre-built and shoule be located in the 
#     "binDIr" directory.
prog_name=pahm
  progEXE="$( getPROG ${prog_name} "${binDir} ${defBinDir}" )"
  errstat=$?
  if [ ${errstat} -ne 0 ]; then
    procError "The executable \"${prog_name}\" is not found" \
              "This is a required program for this test."
  fi
####################


### Files to compare upon model run completion
chkFiles=( pahm_windout-sandy.nc4 )
nFiles=${#chkFiles[@]}


echo ""
echo "|---------------------------------------------|"
echo "    TEST CASE: ${caseName}"
echo ""


#----------
echo -n "    Runnning case..."

${progEXE} pahm_control-sandy.in > pahm_run.log 2>&1
errstat=$?
if [ ${errstat} -ne 0 ] ; then
  echo "    PaHM exit code: ${errstat}"
  procError "error in running pahm" \
            "see the log file pahm_run.log"
fi

echo "Finished"
echo ""


#----------
echo -n "    Running the comparison..."

echo "" > comparison.log
for ((i=0; i<${nFiles}; i++))
do
  echo "${chkFiles[${i}]}" >> comparison.log

  ${progNCCMP} -d -t ${tolerance} ${chkFiles[${i}]} control/${chkFiles[${i}]} >>comparison.log 2>&1
  error[${i}]=$?

  echo "" >> comparison.log
done

echo "Finished"

# Check the number of failed steps
fail=0
for ((i=0; i<${nFiles}; i++))
do
  echo -n "      "${chkFiles[${i}]}": "

  if [ ${error[${i}]} -ne 0 ] ; then
    echo "Failed"
    fail=$(( ${fail} + 1 ))
  else
      echo "Passed"
  fi
done

if [ ${fail} -gt 0 ] ; then
  echo "    Comparison Failed!"
else
  echo "    Comparison Passed!"
fi

echo "|---------------------------------------------|"
echo ""

if [ ${fail} -ge 1 ] ; then
  procError "The data comparison between the control and generated output files failed" \
            "For details see the log file comparison.log"
else
  exit 0
fi

###==================== END:: TEST CASE SECTION  ====================
