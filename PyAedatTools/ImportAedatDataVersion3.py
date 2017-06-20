#!/usr/bin/env python

# Federico Corradi contributed the first version of this code
"""
Import data from AEDAT version 3 format
A subfunction of ImportAedat.py 
Refer to this function for the definition of input/output variables etc

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
    if ('startPacket' in importParams):
        startPacket = importParams.startPacket
    else:    
        startPacket = 1

    if ('endPacket' in importParams):
        endPacket = importParams['endPacket']
    else:
        endPacket = np.inf
        
    if startPacket > endPacket:
        raise Exception('The startPacket parameter is %d, but the endPacket parameter is %d' % (startPacket, endPacket))
    
    if 'startEvent' in importParams:
        raise Exception('The startEvent parameter is set, but range by events is not available for .aedat version 3.x files')
    
    if 'endEvent' in importParams:
        raise Exception('The endEvent parameter is set, but range by events is not available for .aedat version 3.x files')
    
    if ('startTime' in importParams):
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
    if ('simplifyFrameTimeStamps' in importParams):
        simplifyFrameTimeStamps = importParams['simplifyFrameTimeStamps']
    else:
        simplifyFrameTimeStamps = true

    # By default, throw away the valid flags, 
    # and any events which are set as invalid.
    if ('validOnly' in importParams):
        validOnly = importParams['validOnly']
    else:
        validOnly = true

    # By default, do not skip any packets
    if ('modPacket' in importParams):
        modPacket = importParams['modPacket']
    else:
        modPacket = 1
    
    # By default, import the full data, rather than just indexing the packets
    if ('noData' in importParams): 
        noData = importParams['noData']
    else:
        noData = false

    # By default, import all data types
    if ('dataTypes' in importParams):
        allDataTypes = false
        dataTypes = importParams['dataTypes']
    else:
        allDataTypes = true
        
    packetCount = 0

    # Has this file already been indexed in a previous pass?
    if ('packetPointers' in info):
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
        
        
        REWRITE: GOT TO HERE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

    
    # Build arrays to receive data
    specialNumEvents = 0
    specialValid     = []
    specialTimeStamp = []
    specialAddress   = []

    polarityNumEvents = []
    polarityValid     = []
    polarityTimeStamp = []
    polarityY         = []
    polarityX         = []
    polarityPolarity  = []

    frameNumEvents              = []
    frameValid                  = []
    frameTimeStampFrameStart    = []
    frameTimeStampFrameEnd      = []
    frameTimeStampExposureStart = []
    frameTimeStampExposureEnd   = []
    frameColorChannels              = []
    frameColorFilter              = []
    frameRoiId                  = []
    frameXLength                = []
    frameYLength                = []
    frameXPosition              = []
    frameYPosition              = []
    frameSamples                = []
    
    imu6NumEvents   = []
    imu6Valid       = []
    imu6TimeStamp   = []
    imu6AccelX      = []
    imu6AccelY      = []
    imu6AccelZ      = []
    imu6GyroX       = []
    imu6GyroY       = []
    imu6GyroZ       = []
    imu6Temperature = []

    sampleNumEvents  = []
    sampleValid      = []
    sampleTimeStamp  = []
    sampleSampleType = []
    sampleSample         = []

    earNumEvents = []
    earValid     = []
    earTimeStamp = []
    earPosition  = []
    earChannel   = []
    earNeuron    = []
    earFilter    = []

    point1DNumEvents = []
    point1DValid     = []
    point1DTimeStamp = []
    point1DValue     = []

    point2DNumEvents = []
    point2DValid     = []
    point2DTimeStamp = []
    point2DValue1    = []
    point2DValue2    = []
    
    currentTimeStamp = 0
    
    while True : # time based and packet-counted readout not implemented yet
        # read the header of the next packet
        header = info['fileHandle'].read(28)
        if info['fileHandle'].eof :
            info['numPackets'] = packetCount
            break
        packetPointers[packetCount] = info['fileHandle'].tell - 28
        if mod(packetCount, 100) == 0 :
            print 'packet: %d; file position: %d MB' % (packetCount, math.floor(info['fileHandle'].tell / 1000000))
        if info['startPacket'] > packetCount :
            # Ignore this packet as its count is too low
            eventSize = struct.unpack('I', header[4:8])[0]
            eventNumber = struct.unpack('I', header[20:24])[0]
            info['fileHandle'].seek(eventNumber * eventSize, 1)
        else :
            eventSize = struct.unpack('I', header[4:8])[0]
            eventTsOffset = struct.unpack('I', header[8:12])[0]
            eventTsOverflow = struct.unpack('I', header[12:16])[0]
            #eventCapacity = struct.unpack('I', header[16:20])[0] # Not needed
            eventNumber = struct.unpack('I', header[20:24])[0]
            #eventValid = struct.unpack('I', header[24:28])[0] # Not needed
            # Read the full packet
            numBytesInPacket = eventNumber * eventSize
            data = info['fileHandle'].read(numBytesInPacket)
               # Find the first timestamp and check the timing constraints
            packetTimestampOffset = eventTsOverflow << 31;
            mainTimeStamp = struct.unpack('i', header[eventTsOffset \
                                                    : eventTsOffset + 4])[0] \
                                                    + packetTimestampOffset
            if info['startTime'] <= mainTimeStamp \
                and mainTimeStamp <= info['endTime']:
                eventType = struct.unpack('h', header[0:2])[0]
                packetTypes(packetCount) = eventType
                    
                #eventSource = struct.unpack('h', [header[2:4])[0] # Multiple sources not handled yet
        
                # Handle the packet types individually:

            
        
                # Checking timestamp monotonicity
                tempTimeStamp = struct.unpack('i', data[eventTsOffset : eventTsOffset + 4])[0]
                
                dataPointer = 0  # eventnumber[0]
            
                # Special events
                if(eventType == 0):
                    if not 'dataTypes' in info or 'special' in info['dataTypes'] :
                        for dataPointer in range(0, numBytesInPacket - 1, eventSize) : # This points to the first byte for each event
                            specialNumEvents = specialNumEvents + 1
                            specialAddress.append(data[dataPointer] >> 1)
                            specialTimeStamp.append(struct.unpack('I', data[dataPointer + 4:dataPointer + 8])[0])
                        specialValid(specialNumEvents) = data[dataPointer] % 2) == 1 # Pick off the first bit
                        specialTimeStamp(specialNumEvents) = packetTimestampOffset + uint64(typecast(data(dataPointer + 4 : dataPointer + 7), 'int32'));
                        specialAddress(specialNumEvents) = data[dataPointer] >> 1
                    end
                            
                # Polarity events                
                elif(eventType == 1):  
                    if not 'dataTypes' in info or 'polarity' in info['dataTypes'] :
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
                elif(eventType == 2): #aps event
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






