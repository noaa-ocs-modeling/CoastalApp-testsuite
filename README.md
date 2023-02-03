# CoastalApp-testsuite

Contacts:

Panagiotis.Velissariou@noaa.gov

Saeed.Moghimi@noaa.gov

## Download the CoastalApp-testsuite


**First** download the test suite for CoastalApp using git:

``
git clone https://github.com/noaa-ocs-modeling/CoastalApp-testsuite.git
``

***Change directory to:***
``cd CoastalApp-testsuite``

**NOTE:** *It is assumed that all subsequent operations take place inside the CoastalApp-testsuite directory.*

**Second** download the CoastalApp itself:

``
git clone --recurse-submodules https://github.com/noaa-ocs-modeling/CoastalApp -b develop
``

The above command will download the CoastalApp codes into CoastalApp-testsuite/CoastalApp

**Third** download the required data to run the "hsofs" tests cases (the shinnecock test cases are self contained):

``
wget https://tacc-nos-coastalapp-testsuit.s3.amazonaws.com/hsofs-data-v2.tgz
``

Extract the data into the comm directory by issuing the command: 
``tar -zxvf hsofs-data-v2.tgz``
 
 This command will extract the data into the CoastalApp-testsuite/comm directory

## Compile CoastalApp

Change directory to CoastalApp-testsuite/CoastalApp:

``cd CoastalApp``

and run the build.sh script to fit your organization's configuration:

`` ./build.sh --compiler intel --platform hera --component "atmesh pahm adcirc ww3"  -y``

In the case of ww3, the ParMETIS library is required to build ww3. To use ParMETIS within CoastalApp, you need to first download ParMETIS by running the script: ``scripts/download_parametis.sh``

This command will install the ParMETIS codes into CoastalApp/thirdparty_open.

In this case you need to run the build.sh script as:

`` ./build.sh --compiler intel --platform hera --component "atmesh pahm adcirc ww3" --tp parmetis  -y``

If you want to use a pre-build ParMETIS library in your system, you may run the build script as:

``PARMETISHOME=YOUR_INSTALLED_PARMETIS_LOCATION ./build.sh --compiler intel --platform hera --component "atmesh pahm adcirc ww3"  -y``

To get the full list of options that the build script accepts with brief explanations, you may run the script as: ``./build.sh --help``

## How to run the CoastalApp tests cases

Change directory into CoastalApp-testsuite.

Edit the file **regtest_list.dat** and uncomment the test cases you want to run. Next run the supplied script **run_all.sh** to run the requested test cases.

If you decided to install CoastalApp and/or the hsofs data in some location outside the CoastalApp-testsuite directory then you need to run the **run_all.sh** as:

``ROOTDIR=CoastalApp_LOCATION COMMDIR=HSOFS_DATA_LOCATION ./run_all.sh``

If your platform is not "hera", you may also pass your desired platform name to the script as:

``PLATFORM=YOUR_PLATFORM ./run_all.sh``

**NOTE:** The interface to the script "run_all.sh" it is most likely to be changed to include more commandline options to enhance the script's usage.
Please stay tuned ...
