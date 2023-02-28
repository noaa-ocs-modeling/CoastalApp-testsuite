# CoastalApp-testsuite

### Contacts:

 * [Panagiotis.Velissariou@noaa.gov](mailto:Panagiotis.Velissariou@noaa.gov)
 * [Saeed.Moghimi@noaa.gov](mailto:Saeed.Moghimi@noaa.gov)


***SCHEDULED TO BE UPDATED  -- SCHEDULED TO BE UPDATED***

## Introduction

***CoastalApp-testsuite*** contains comprehensive tests for the different modeling
components implemented in [CoastalApp](https://github.com/noaa-ocs-modeling/CoastalApp). The test suite is used to run automated tests for the model and data components after an update in *CoastalApp*. There are two set of tests: (a) small scale tests that require very limited compute resources (e.g., the Shinnecock inlet cases) and (b) large scale tests that require extensive compute resources that can be run on a Cluster/HPC environment (e.g., the HSOFS cases). In any case, to run any of these tests the user is responsible to download and compile *CoastalApp* first.


## Downloading the *CoastalApp-testsuite*

*CoastalApp-testsuite* is hosted in NOAA's Office of Coast Survey github modeling repository: [https://github.com/noaa-ocs-modeling](https://github.com/noaa-ocs-modeling) along with other applications and models. The source code of *CoastalApp* is publicly available from the GitHub repository:
  <a href="https://github.com/noaa-ocs-modeling/CoastalApp-testsuite"
     TARGET="_BLANK" REL="NOREFERRER">https://github.com/noaa-ocs-modeling/CoastalApp-testsuite</a>.

This application can be downloaded using one of the following methods:

***(1) Clone CoastalApp-testsuite from GitHub using the command:***

        git clone --recurse-submodules  https://github.com/noaa-ocs-modeling/CoastalApp-testsuite.git

The source will be downloaded into the target directory CoastalApp-testsuite.

***(2) Download the CoastalApp-testsuite archive using the command:***

        wget https://github.com/noaa-ocs-modeling/CoastalApp-testsuite/archive/refs/heads/main.zip

and extract the sources in the CoastalApp-testsuite directory by issuing the following commands:

        unzip -o main.zip  (the data will be extracted into the CoastalApp-testsuite-main directory)

        mv CoastalApp-testsuite-main CoastalApp-testsuite  (move the extracted files to the CoastalApp-testsuite directory)

**NOTE:** *It is assumed that all subsequent operations take place inside the CoastalApp-testsuite directory* (``cd CoastalApp-testsuite``).


## Downloading and Compiling *CoastalApp*

If the application is not already downloaded and/or compiled, you may refer to *CoastalApp's* [README.md](https://github.com/noaa-ocs-modeling/CoastalApp#readme) file for detailed instructions on how to download and compile *CoastalApp*.
While, the location of the *CoastalApp* is a user's preference, it is suggested to
download the application into the CoastalApp-testsuite directory where the top level
"run" script can find CoastalApp.

## Downloading Required Data (Optional)

To run the large scale tests ("hsofs" cases) download the required data to run the tests (all shinnecock test cases are self contained) using the commands:

        cd CoastalApp-testsuite
        wget https://tacc-nos-coastalapp-testsuit.s3.amazonaws.com/hsofs-data-v2.tgz

and extract the data into the "comm" directory by issuing the command: 

        tar -zxvf hsofs-data-v2.tgz
 
 This command will extract the data into the CoastalApp-testsuite/comm directory.

## How to run the CoastalApp tests cases

Change directory into CoastalApp-testsuite.

Edit the file **regtest_list.dat** and uncomment the test cases you want to run. Next run the supplied script **run_all.sh** to run the requested test cases.

If you decided to install CoastalApp and/or the hsofs data in some location outside the CoastalApp-testsuite directory then you need to run the **run_all.sh** as:

``ROOTDIR=CoastalApp_LOCATION COMMDIR=HSOFS_DATA_LOCATION ./run_all.sh``

If your platform is not "hera", you may also pass your desired platform name to the script as:

``PLATFORM=YOUR_PLATFORM ./run_all.sh``

**NOTE:** The interface to the script "run_all.sh" it is most likely to be changed to include more commandline options to enhance the script's usage.
Please stay tuned ...
