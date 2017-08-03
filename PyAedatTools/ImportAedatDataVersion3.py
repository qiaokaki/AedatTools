#!/usr/bin/env python

# Federico Corradi contributed the first version of this code
"""
Import data from AEDAT version 3 format
A subfunction of ImportAedat.py 
Refer to this function for the definition of input/output variables etc

Let's just assume this code runs on little-endian processor. 

Not handled yet:
Timestamp overflow
Reading by packets
Data-type-specific read in
Frames and other data types
Multi-source read-in
Building large arrays, 
    exponentially expanding them, and cropping them at the end, in order to 
    read more efficiently - at the moment we build a list then convert to array. 


"""

import struct
import numpy as np                       

def ImportAedatDataVersion3(aedat):

    # Unpack the aedat dict
    info = aedat['info']
    importParams = aedat['importParams']
    fileHandle = importParams['fileHandle']
    
    # Check the startEvent and endEvent parameters
    if 'startPacket' in importParams:
        startPacket = importParams.startPacket
    else:    
        startPacket = 1

    if 'endPacket' in importParams:
        endPacket = importParams['endPacket']
    else:
        endPacket = np.inf
        
    if startPacket > endPacket:
        raise Exception('The startPacket parameter is %d, but the endPacket parameter is %d' % (startPacket, endPacket))
    
    if 'startEvent' in importParams:
        raise Exception('The startEvent parameter is set, but range by events is not available for .aedat version 3.x files')
    
    if 'endEvent' in importParams:
        raise Exception('The endEvent parameter is set, but range by events is not available for .aedat version 3.x files')
    
    if 'startTime' in importParams:
        startTime = inmportParams['startTime']
    else:
        startTime = 0
    
    if not ('endTime' in importParams):
        endTime = importParams['endTime']
    else:
        endTime = np.inf
    
    if startTime > endTime:
        raise Exception('The startTime parameter is %d, but the endTime parameter is %d' % (info['startTime'], info['endTime']))
    
    # By default, throw away timeStampFrameStart/End, 
    # renaming timeStampExposureStart/End to timeStampStart/End
    if 'simplifyFrameTimeStamps' in importParams:
        simplifyFrameTimeStamps = importParams['simplifyFrameTimeStamps']
    else:
        simplifyFrameTimeStamps = true

    # By default, throw away the valid flags, 
    # and any events which are set as invalid.
    if 'validOnly' in importParams:
        validOnly = importParams['validOnly']
    else:
        validOnly = true

    # By default, do not skip any packets
    if 'modPacket' in importParams:
        modPacket = importParams['modPacket']
    else:
        modPacket = 1
    
    # By default, import the full data, rather than just indexing the packets
    if 'noData' in importParams: 
        noData = importParams['noData']
    else:
        noData = false

    # By default, import all data types
    if 'dataTypes' in importParams:
        allDataTypes = false
        dataTypes = importParams['dataTypes']
    else:
        allDataTypes = true
        
    packetCount = 0

    # Has this file already been indexed in a previous pass?
    if 'packetPointers' in info:
        packetTypes = info['packetTypes']
        packetPointers = info['packetPointers']
        packetTimeStamps = info['packetTimeStamps']
    elif endPacket < np.inf:
        packetTypes = np.ones(endPacket, np.uint16)
        packetPointers = np.zeros(endPacket, np.uint64)
        packetTimeStamps = np.zeros(endPacket, np.uint64)
    else:
        packetTypes = ones(1000, np.uint16)
        packetPointers = zeros(1000, np.uint64)
        packetTimeStamps = zeros(1000, np.uint64)
        
    if noData == false:  
        specialNumEvents = 0
        specialValid = np.false(0)
          
        specialDataMask = int('0x7E')
        specialDataShiftBits = 1

        polarityNumEvents  = 0
        polarityValid      = np.false(0)
        polarityYMask      = int('0x1FFFC')
        polarityYShiftBits = 2
        polarityXMask      = int('0xFFFE0000')
        polarityXShiftBits = 17

        frameNumEvents              = 0
        frameValid                  = np.false(0)
        frameColorChannelsMask      = hex2dec('E')
        frameColorChannelsShiftBits = 1
        frameColorFilterMask        = hex2dec('70')
        frameColorFilterShiftBits   = 4
        frameRoiIdMask              = hex2dec('3F80')
        frameRoiIdShiftBits         = 7

        imu6NumEvents = 0
        imu6Valid     = np.false(0)

        sampleNumEvents = 0
        sampleValid     = np.false(0)

        earNumEvents = 0
        earValid     = np.false(0)

        point1DNumEvents = 0
        point1DValid     = np.false(0)

        point2DNumEvents = 0
        point2DValid     = np.false(0)
        # Ignore scale for now 
  
    fileHandle.seek(info['beginningOfDataPointer'])
    
    # If the file has been indexed or partially indexed, and there is a
    # startPacket or startTime parameter, then jump ahead to the right place
    if 'packetPointers' in info:
        if startPacket > 1: 
            fileHandle.seek(packetPointers(startPacket))
            packetCount = startPacket - 1
        elif (startTime > 0):
            targetPacketIndices = np.argwhere((info.packetTimeStamps) < startTime * 1e6)
            if (not targetPacketIndices): # i.e. targetPacketIndices is empty
                fileHandle.seek(packetPointers(targetPacketIndices[-1]))
                packetCount = targetPacketIndex - 1
    
    # If the file has already been indexed (PARTIAL INDEXING NOT HANDLED), and
    # we are using modPacket to skip a proportion of the data, then use this
    # flag to speed up the loop
    modSkipping = 'packetPointers' in info and modPacket > 1
    
    while True : # implement the exit conditions inside the loop - allows to distinguish between different types of exit
    # Headers
        # Read the header of the next packet
        packetCount = packetCount + 1
        if modSkipping:
            packetCount = np.ceil(packetCount / modPacket) * modPacket
            fileHandle.seek(packetPointers[packetCount])


        header = fileHandle.read(28)
        if fileHandle.eof:
            packetCount = packetCount - 1
            info['numPackets'] = packetCount
            break
        if len(packetTypes) < packetCount:
            # Double the size of packet index arrays as necessary
            packetTypes      = np.append(packetTypes,      np.ones (packetCount, 'uint16') * 32768, 0)
            packetPointers   = np.append(packetPointers,   np.zeros(packetCount, 'uint64'), 0)
            packetTimeStamps = np.append(packetTimeStamps, np.zeros(packetCount, 'uint64'), 0)
        packetPointers[packetCount] = fileHandle.tell - 28    
        if mod(packetCount, 100) == 0 :
            print 'packet: %d; file position: %d MB' % (packetCount, math.floor(info['fileHandle'].tell / 1000000))
        if startPacket > packetCount or np.mod(packetCount, modPacket) > 0:
            # Ignore this packet as its count is too low
            eventSize = struct.unpack('I', header[4:8])[0]
            eventNumber = struct.unpack('I', header[20:24])[0]
            fileHandle.seek(eventNumber * eventSize, 1)
        elif endPacket < packetCount:
            packetCount = packetCount - 1
        else:
            eventSize = struct.unpack('I', header[4:8])[0]
            eventTsOffset = struct.unpack('I', header[8:12])[0]
            eventTsOverflow = struct.unpack('I', header[12:16])[0]
            #eventCapacity = struct.unpack('I', header[16:20])[0] # Not needed
            eventNumber = struct.unpack('I', header[20:24])[0]
            #eventValid = struct.unpack('I', header[24:28])[0] # Not needed
            # Read the full packet
            numBytesInPacket = eventNumber * eventSize
            packetData = fileHandle.read(numBytesInPacket)
               # Find the first timestamp and check the timing constraints
            packetTimeStampOffset = uint64(eventTsOverflow) << 31;


            mainTimeStamp = uint64(struct.unpack('i', packetData[eventTsOffset \
                                                    : eventTsOffset + 4])[0]) \
                          + packetTimeStampOffset
            if mainTimeStamp > endTime * 1e6 \
                and mainTimeStamp ~= int('0x7FFFFFFF') # This may be a timestamp reset - don't let it stop the import
                # Naively assume that the packets are all ordered correctly and finish
                packetCount = packetCount - 1
                break
            if startTime * 1e6 <= mainTimeStamp \
                eventType = struct.unpack('h', header[0:2])[0]
                packetTypes(packetCount) = eventType
                    
                #eventSource = struct.unpack('h', [header[2:4])[0] # Multiple sources not handled yet
            if not noData:
                # Handle the packet types individually:
            
                # Special events
                if eventType == 0:
                    if allDataTypes or 'special' in info['dataTypes']:
                        # First check if the array is big enough
                        currentLength = len(specialValid)
                        if currentLength == 0:
                            specialValid     = np.false(eventNumber)
                            specialTimeStamp = np.zeros(eventNumber, 'uint64')
                            specialAddress   = np.zeros(eventNumber, 'uint32')
                        else:
                            while eventNumber > currentLength - specialNumEvents:
                                specialValid		= np.append(specialValid,     np.false(currentLength), 0)
                                specialTimeStamp	= np.append(specialTimeStamp, np.zeros(currentLength, 'uint64'), 0)
                                specialAddress	= np.append(specialAddress,   np.zeros(currentLength, 'uint32'), 0)
                                currentLength = length(specialValid);
                        # Iterate through the events, converting the data and
                        # populating the arrays
                        for dataPointer in range(0, numBytesInPacket, eventSize) : # This points to the first byte for each event
                            specialNumEvents = specialNumEvents + 1
                            specialValid(specialNumEvents) = packetData[dataPointer] % 2) == 1 # Pick off the first bit
                            specialAddress(specialNumEvents) = data[dataPointer] >> 1
                            specialTimeStamp(specialNumEvents) = packetTimeStampOffset + uint64(struct.unpack('I', packetData[dataPointer + 4 : dataPointer + 8)[0])
                            
                # Polarity events                
                elif(eventType == 1):  
                    if allDataTypes or 'polarity' in info['dataTypes']:
                        # First check if the array is big enough
                        currentLength = len(polarityValid)
                        if currentLength == 0:
                            polarityValid		= np.false(eventNumber)
                            polarityTimeStamp	= np.zeros(eventNumber, 'uint64')
                            polarityX			= np.zeros(eventNumber, 'uint16')
                            polarityY			= np.zeros(eventNumber, 'uint16')
                            polarityPolarity	= np.false(eventNumber);
                        else	
                            while eventNumber > currentLength - polarityNumEvents:
                                polarityValid     = np.append(polarityValid,     np.false(currentLength          ))
                                polarityTimeStamp = np.append(polarityTimeStamp,	 np.zeros(currentLength, 'uint16'))
                                polarityX         = np.append(polarityX,         np.zeros(currentLength, 'uint16'))
                                polarityY         = np.append(polarityY,         np.zeros(currentLength, 'uint16'))
                                polarityPolarity  = np.append(polarityPolarity,  np.false(currentLength          ))
                                currentLength = len(polarityValid)
                        packetData = struct.unpack('I', packetData)
                        dataTempAddress   = packetData[0::2]
                        dataTempTimeStamp = packetData[1::2]
                        polarityTimeStamp(polarityNumEvents + (1 : eventNumber)) = packetTimeStampOffset + uint64(typecast(dataTempTimeStamp(:), 'int32'));
                        dataTempAddress = dataMatrix(1:4, :);
                        dataTempAddress = typecast(dataTempAddress(:), 'uint32');
                        polarityValid(polarityNumEvents + (1 : eventNumber)) = mod(dataTempAddress, 2) == 1; % Pick off the first bit
                        polarityPolarity(polarityNumEvents + (1 : eventNumber)) = mod(floor(dataTempAddress / 2), 2) == 1; % Pick out the second bit
                        polarityY(polarityNumEvents + (1 : eventNumber)) = uint16(bitshift(bitand(dataTempAddress, polarityYMask), -polarityYShiftBits));
                        polarityX(polarityNumEvents + (1 : eventNumber)) = uint16(bitshift(bitand(dataTempAddress, polarityXMask), -polarityXShiftBits));
                        polarityNumEvents = polarityNumEvents + eventNumber;
OLD
                        while(data[dataPointer:dataPointer + eventSize]):  # loop over all 
                            polData = struct.unpack('I', data[dataPointer:dataPointer + 4])[0]
                            polTs = struct.unpack('I', data[dataPointer + 4:dataPointer + 8])[0]
                            polAddrX = (polData >> 17) & 0x00007FFF
                            polAddrY = (polData >> 2) & 0x00007FFF
                            polPol = (polData >> 1) & 0x00000001
                            polTsAll.append(polTs)
                            polAddrXAll.append(polAddrX)
                            polAddrYAll.append(polAddrY)
                            polPolAll.append(polPol)
                # Frames
                elif(eventType == 2): 
                    if not 'dataTypes' in info or 2 in info['dataTypes'] :
                        dataPointer = 0 #eventnumber[0]
                        while(data[dataPointer:dataPointer+eventSize]):  #loop over all 
                            infos = struct.unpack('I',data[dataPointer:dataPointer+4])[0]
                            ts_start_frame = struct.unpack('I',data[dataPointer+4:dataPointer+8])[0]
                            ts_end_frame = struct.unpack('I',data[dataPointer+8:dataPointer+12])[0]
                            ts_start_exposure = struct.unpack('I',data[dataPointer+12:dataPointer+16])[0]
                            ts_end_exposure = struct.unpack('I',data[dataPointer+16:dataPointer+20])[0]
                            length_x = struct.unpack('I',data[dataPointer+20:dataPointer+24])[0]
                            length_y = struct.unpack('I',data[dataPointer+24:dataPointer+28])[0]
                            pos_x = struct.unpack('I',data[dataPointer+28:dataPointer+32])[0]
                            pos_y = struct.unpack('I',data[dataPointer+32:dataPointer+36])[0]
                            bin_frame = data[dataPointer+36:dataPointer+36+(length_x*length_y*2)]
                            frame = struct.unpack(str(length_x*length_y)+'H',bin_frame)
                            frame = np.reshape(frame,[length_y, length_x])
                            frameAll.append(frame)
                            tsStartFrameAll.append(ts_start_frame)
                            tsEndFrameAll.append(ts_end_frame)
                            tsStartExposureAll.append(ts_start_exposure)
                            tsEndExposureAll.append(ts_end_exposure)
                            lengthXAll.append(length_x)
                            lengthYAll.append(length_y)
                            dataPointer = dataPointer + eventSize
                # Frame events and other types not handled yet
        
                # read the header of the next packet
                data = info['fileHandle'].read(28)
        
            output = {} # This will correspond to outputs.data at the higher level

    
    if specialTsAll : # Test if there are any special events
        specialTsAll = np.array(specialTsAll)
        specialAddrAll = np.array(specialAddrAll)
        output['special'] = {
            'timeStamp' : specialTsAll, 
            'address' : specialAddrAll}
    if polTsAll : # Test if there are any special events
        polTsAll = np.array(polTsAll);
        polAddrXAll = np.array(polAddrXAll)
        polAddrYAll = np.array(polAddrYAll)
        polPolAll = np.array(polPolAll)
        output['polarity'] = {
            'timeStamp' : polTsAll, 
            'x' : polAddrXAll, 
            'y' : polAddrYAll, 
            'polarity' : polPolAll}
    if frameAll : # Test if there are any special events
        polTsAll = np.array(polTsAll);
        polAddrXAll = np.array(polAddrXAll)
        polAddrYAll = np.array(polAddrYAll)
        polPolAll = np.array(polPolAll)
        output['frame'] = {
            'tsStartFrame' : np.array(tsStartFrameAll), 
            'tsEndFrame' : np.array(tsEndFrameAll), 
            'tsStartExposure' : np.array(tsStartExposureAll), 
            'tsEndExposure' : np.array(tsEndExposureAll),
            'lengthX' : np.array(lengthXAll),
            'lengthY' : np.array(lengthYAll),
            'data' : frameAll}

    return output






