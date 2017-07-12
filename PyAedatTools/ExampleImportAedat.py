# -*- coding: utf-8 -*-
"""
Example script for how to invoke the ImportAedat function
"""

import sys
from pyAedatTools.ImportAedat import ImportAedat

# Create a dict with which to pass in the input parameters.
aedat = {}

# Put the filename, including full path, in the 'filePath' field.

aedat['filePath'] = 'C:\project\example3.aedat' # Windows
aedat['filePath'] = '/home/project/example3.aedat' # Linux

# Alternatively, make sure the file is already on the python path.
sys.path.append('/home/project/')

# Add any restrictions on what to read out. 
# This example limits readout to the first 1M events (aedat fileFormat 1 or 2 only):
aedat['endEvent'] = 1e6;

# This example ignores the first 1M events (aedat fileFormat 1 or 2 only):
aedat['startEvent'] = 1e6;

# This example limits readout to a time window between 48.0 and 48.1 s:
aedat['startTime'] = 48;
aedat['endTime'] = 48.1;

# This example only reads out from packets 1000 to 2000 (aedat3.x only)
aedat['startPacket'] = 1000;
aedat['endPacket'] = 2000;

#These examples limit the read out to certain types of event only
aedat['dataTypes'] = {'polarity', 'special'};
aedat['dataTypes'] = {'special'};
aedat['dataTypes'] = {'frame'};

# Setting the dataTypes empty tells the function to not import any data;
# You get the header info, plus packet indices info for Aedat3.x

# Working with a file where the source hasn't been declared - do this explicitly:
aedat['source'] = 'Davis240b';

# Invoke the function
aedat = ImportAedat(aedat)

