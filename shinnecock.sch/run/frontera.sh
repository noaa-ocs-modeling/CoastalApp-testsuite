#!/bin/bash
#----------------------------------------------------
# Sample Slurm job script
#   for TACC Frontera CLX nodes
#
#   *** MPI Job in Normal Queue ***
# 
# Last revised: 20 May 2019
#
# Notes:
#
#   -- Launch this script by executing
#      "sbatch clx.mpi.slurm" on a Frontera login node.
#
#   -- Use ibrun to launch MPI codes on TACC systems.
#      Do NOT use mpirun or mpiexec.
#
#   -- Max recommended MPI ranks per CLX node: 56
#      (start small, increase gradually).
#
#   -- If you're running out of memory, try running
#      fewer tasks per node to give each task more memory.
#
#----------------------------------------------------

#SBATCH -J CoAppSch    # Job name
#SBATCH -o myjob.o%j       # Name of stdout output file
#SBATCH -e myjob.e%j       # Name of stderr error file
##Available partitions and limits in q_limits.txt. 'flex' is great for back filling jobs
##flex: lower priority, max 128 nodes, preempt_time=1hr; max time=2days. 0.8SU charge rate.
##'development': max 40 nodes, 2hrs. Max 1 job
##'small': 1-2 node for up to 48 hrs
##'normal': up to 512 nodes, 48 hrs
#SBATCH -p small   # Queue (partition) name
#SBATCH -N 1               # Total # of nodes (up to 56 cores/node)
#SBATCH -n 4              # Total # of mpi tasks
#SBATCH -t 01:00:00        # Run time (hh:mm:ss)
#SBATCH --mail-type=none    # Send email at begin and end of job
#SBATCH -A EAR21010      # Project/Allocation name (req'd if you have more than 1)
#SBATCH --mail-user=carsten.lemmen@hereon.de
###Can add dependency (e.g. only execute this after another job is done)
###SBATCH --dependency 

# Any other commands must follow all #SBATCH directives...
module list
pwd
date

##Can do pre-proc first on same resource
##./pre_proc.pl

# Launch MPI code... 
#ibrun ./pschism_FRONTERA_TVD-VL  5
ibrun ./NEMS-schism.x
##Can launch >1 MPI jobs one after another
##ibrun ./

##Also can launch >1 MPI jobs in parallel using wait; see manual
