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
# suggest to use interactive node to perform this:
# > srun -N 1 -A coastal --ntasks-per-node=8  -t 0-06:00 --pty bash

export PS4=' $SECONDS + '
set -x

export NSEMdir=${NSEMdir:-/scratch2/COASTAL/coastal/noscrub/shared/Saeed.Moghimi/coastalapp_test/temp/CoastalApp-testsuite}
export ROOTDIR=${ROOTDIR:-/scratch2/COASTAL/coastal/noscrub/shared/Saeed.Moghimi/coastalapp_test/temp/CoastalApp}
export COMROOT=${COMROOT:-${NSEMdir}/../${USER}/com/}

############
### Clone CoastalApp-testsuite
##If not already done 
# git clone   -b feature/ww3-multi-nodes  https://github.com/noaa-ocs-modeling/CoastalApp-testsuite.git $NSEMdir
## echo 'Fetching externals...'
# mkdir -p ${NSEMdir}/fix/
# cp -rpv /scratch2/COASTAL/coastal/save/shared/CoastalApp_test_fix/fix ${NSEMdir}


############
# Check out codes
git clone --recursive https://github.com/noaa-ocs-modeling/CoastalApp $ROOTDIR
cd $ROOTDIR
git checkout develop_build
git submodule sync
git submodule update --init --recursive

#just a hack to update WW3 submodule to point to Andre for the time being
cp -fv /scratch2/COASTAL/coastal/save/shared/CoastalApp_test_fix/ww3_extra_files/gitmodules $ROOTDIR/.gitmodules  
rm -rf WW3
git submodule update --init --recursive

#copy extra files for ww3 compile
cp -fv /scratch2/COASTAL/coastal/save/shared/CoastalApp_test_fix/ww3_extra_files/* $ROOTDIR/WW3/model/esmf/.
#cp -fv /scratch2/COASTAL/coastal/save/shared/CoastalApp_test_fix/ww3_extra_files/switch $ROOTDIR/WW3/model/bin/switch

# download parmatis
#TODO add a error message to perform below if not yet for ww3 compilation
#TODO or export the vars ...
sh $ROOTDIR/scripts/download_parmetis.sh

# build on hera
./build.sh --component "ATMESH WW3 ADCIRC WW3DATA " --plat hera --compiler intel --clean -2  --thirdparty=parmetis



## Tide_fac
### TODO we need to include this in build.sh
### This is a hack for now
source ${ROOTDIR}/modulefiles/envmodules_intel.hera
cd ${NSEMdir}/sorc/estofs_tide_fac
make 
cp -fv ${NSEMdir}/sorc/estofs_tide_fac/tide_fac $ROOTDIR/ALLBIN_INSTALL

# point to executeable folder in CoastalApp from CoastalApp-testsuite
ln -sfv ${ROOTDIR}/ALLBIN_INSTALL  ${NSEMdir}/exec


