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

export NSEMdir=${NSEMdir:-/scratch2/COASTAL/coastal/noscrub/shared/Saeed.Moghimi/coastalapp_test/temp/CoastalApp-testsuite}
export ROOTDIR=${ROOTDIR:-/scratch2/COASTAL/coastal/noscrub/shared/Saeed.Moghimi/coastalapp_test/temp/CoastalApp}
export COMROOT=${COMROOT:-${NSEMdir}/../${USER}/com/}




############
# Clone CoastalApp-testsuite
git clone   -b feature/ww3-multi-nodes  https://github.com/noaa-ocs-modeling/CoastalApp-testsuite.git $NSEMdir
# echo 'Fetching externals...'
mkdir -p ${NSEMdir}/fix/
cp -rpv /scratch2/COASTAL/coastal/save/shared/CoastalApp_test_fix/fix ${NSEMdir}/fix/.


############
# Check out codes
git clone --recursive https://github.com/noaa-ocs-modeling/CoastalApp $ROOTDIR
cd $ROOTDIR
git checkout develop_build
git submodule sync
git submodule update --init --recursive

#copy extra files for ww3 compile
cp --fv /scratch2/COASTAL/coastal/save/shared/CoastalApp_test_fix/ww3_extra_files/ $ROOTDIR/model/esmf


#just a hack to update WW3 submodule to point to Andre for the time being
cp --fv /scratch2/COASTAL/coastal/save/shared/CoastalApp_test_fix/ww3_extra_files/gitmodules $ROOTDIR/.gitmodules  
cd $ROOTDIR
rm -rf WW3
git submodule update --init --recursive

# build on hera
./build.sh --component "ATMESH WW3 " --plat hera --compiler intel --clean -2  --thirdparty=parmetis

# point to executeable folder in CoastalApp from CoastalApp-testsuite
ln -sfv ${ROOTDIR}/ALLBIN_INSTALL  ${NSEMdir}/exec


