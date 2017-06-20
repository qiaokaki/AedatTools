# AedatTools
Tools for manipulating .aedat files (timestamped address-event data from neuromorphic hardware), in Matlab and Python.

## Overview

The ImportAedat function imports data from a .aedat file into a 'struct' in the matlab workspace, or equivalently, a 'dict' in the python workspace. (hereafter 'structure'). 

The .aedat file format is documented at:

https://inilabs.com/support/software/fileformat/

The resulting structures are named 'aedat' and are usually both an input and sometimes the output of functions. 

These structures contain up to four branches at the top level: importParams, exportParams, info and data. The data branch contains the actual event data, separated according to data type, following the conventions used in the aedat3 file format. info contains various meta data, including data held in the header lines of the file. Any xml contained in the header lines of a file is stored in the info.xml field. 

ExportAedat2, ExportAedat3 and ExportRosBag functions export the data in a structure to the corresponding file format. 

The Rosbag format follows the conventions used by the rpg_dvs_ros project:

https://github.com/uzh-rpg/rpg_dvs_ros 

Plot functions take a structure and plot some aspect of the data contained within.

There are various utilities for manipulating the data, such as TrimTime, TrimSpace, Reorientate etc.

Look at the provided example scripts for how to use these functions. 

## Supported devices and data types

As of 2017_06, data types 0-3 (Special, Polarity, Frame and Imu6) are almost fully supported. Device types DVS128 and DAVIS are fully supported with the possible exception of  HetDavis (I haven't tried). There is some support for other data types, for example, the ImportAedat routines recognise DAS1 / cochlear / ear events, and most other event types - no dynapse support yet.

## How to import from aedat files

ImportAedat calls ImportAedatHeaders to import the info from the header lines of a .aedat file. From this it finds out the type of aedat file (v1, 2 or 3). Then it calls the appropriate function:

- ImportAedatDataVersion1or2
- ImportAedatDataVersion3

Each function is capable of importing aspects of the data which are particular to the format. However, the default behaviour is to reduce the imported data to a set which is common to both formats. The rest of the functions in the library assume that the imported data is in this reduced form. The reductions that occur are as follows:

From aedat version 2:

- The frame signal read is subtracted form the frame reset read in order to yield a single frame. Override this by setting importParams.subtractResetRead = false.

From aedat version 3:

- The "valid" flags from each data type are applied (invalid events are not imported), and then the "valid" flags are deleted. Override this by setting importParams.validOnly = false.

- From the frames, timeStampFrameStart/End are thrown away, whilst timeStampExposureStart/End are renamed to timeStampStart/End. Override this by setting importParams.simplifyFrameTimeStamps = false. Note an implication of the decision to throw away frame timestamps is that frame timestamps imported from aedat3 reprsent the actual exposure times whereas those imported from aedat 2 represent the slightly later frame readout times. 

- From frames x/yLength/Position are kept, and reconstituted in the Aedat 2 import. This is because event in aedat2 format, there can be partial frames due to data losses. 

- I haven't yet decided on a consistent handling method for roiId, colorChannels, and colorFilter. IN the mean time these fields are retained by the import, but are not supported by all functions which manipulate the aedat structure. 
 
 ## Peculiarities
 
frame samples are held in uint16 vectors, but they are in the range 0-1023 - i.e. 10-bit values. The basic format assumes that reset frame subtraction has been performed. 

IMU units - import converts IMU samples to double precision floats in the units g (for accelation) and deg/s for angular velocity. ExportRosbag converts these to m/s^2 and rad/s respectively. 

timstamps are uint32 when imported from aedat2 and uint64 when imported from aedat3. There is as yet no intelligent handling of the timestamp wrap events in aedat2.

## Outstanding issues

Import from aedat2 currently doesn't have a good method for excluding data before any timestamp resets.

ExportAedat2 supports polarity, frames and imu6; it doesn't put xml metadata back into the file header. 

ExportRosbag not yet written in matlab, only python. 

