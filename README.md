# AedatTools
Tools for manipulating .aedat files (timestamped address-event data from neuromorphic hardware), in Matlab and Python.

The .aedat file format is documented at:

https://inilabs.com/support/software/fileformat/

The ImportAedat function imports data from a .aedat file into a 'struct' in the matlab workspace, or equivalently, a 'dict' in the python workspace. (hereafter 'structure'). 

These structures are named 'aedat' and are usually both an input and sometimes the output of functions. 

These structures contain up to four branches at the top level: importParams, exportParams, info and data. The data branch contains the actual event data, separated according to data type, following the conventions used in the aedat3 file format. 

ExportAedat2, ExportAedat3 and ExportRosBag functions export the data in a structure to the corresponding file format. 

The Rosbag format follows the conventions used by the rpg_dvs_ros project:

https://github.com/uzh-rpg/rpg_dvs_ros 

Plot functions take a structure and plot some aspect of the data contained within.

There are various utilities for manipulating the data, such as TrimTime, TrimSpace ...

...
