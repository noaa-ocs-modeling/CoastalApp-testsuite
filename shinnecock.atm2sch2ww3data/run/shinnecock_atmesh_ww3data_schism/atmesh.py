#! /usr/bin/env python
from datetime import datetime, timedelta

from nemspy import ModelingSystem
from nemspy.model import SCHISMEntry, AtmosphericMeshEntry, WaveWatch3MeshEntry

if __name__ == '__main__':
    # model run time
    start_time = datetime(2020, 6, 1)
    duration = timedelta(days=1)
    end_time = start_time + duration

    # returning interval of main run sequence
    interval = timedelta(hours=1)

    # directory to which configuration files should be written
    output_directory = './nems_configuration/'

    # model entries
    ocean_model = SCHISMEntry(processors=1, Verbosity='max', DumpFields=False)
    atmospheric_mesh = AtmosphericMeshEntry(
        filename='wind_atm_fin_ch_time_vec.nc', processors=1
    )
    wave_mesh = WaveWatch3MeshEntry(
        filename='ww3.Constant.20151214_sxy_ike_date.nc', processors=1
    )

    # instantiate model system with model entries
    nems = ModelingSystem(
        start_time=start_time,
        end_time=end_time,
        interval=interval,
        #ocn=ocean_model,
        atm=atmospheric_mesh,
        #wav=wave_mesh,
    )

    # form connections between models
    #nems.connect('ATM', 'OCN')
#    nems.connect('WAV', 'OCN')

    # define execution order
    
    nems.sequence = [
        'ATM',
    ]

    # write configuration files to the given directory
    nems.write(directory=output_directory, overwrite=True, include_version=True)
