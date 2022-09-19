#!/bin/bash
# --------------------------------------------------------------------------- #
#                                                                             #
# Copy external fix files and binaries needed for build process and running   #
#                                                                             #
# Last Changed : 10-22-2020                                     October 2020  #
# --------------------------------------------------------------------------- #

export NSEMdir=${NSEMdir:-/scratch2/COASTAL/coastal/noscrub/shared/Saeed.Moghimi/coastalapp_test/tests/NSEM-workflow}
export ROOTDIR=${ROOTDIR:-/scratch2/COASTAL/coastal/noscrub/shared/Saeed.Moghimi/coastalapp_test/codes/CoastalApp}


if [ "${NSEMdir}" == "" ]
    then 
    echo "ERROR - Your NSEMdir variable is not set"
    exit 1
fi

echo 'Fetching externals...'
mkdir -p ${NSEMdir}/fix/
cp -rp /scratch2/COASTAL/coastal/save/shared/CoastalApp_test_fix/fix/* ${NSEMdir}/fix/*

