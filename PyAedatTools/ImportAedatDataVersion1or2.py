# -*- coding: utf-8 -*-

"""
Import aedat version 1 or 2.
"""

import numpy as np


def ImportAedatDataVersion1or2(info):
    """
    Later ;)
    """

    # The formatVersion dictates whether there are 6 or 8 bytes per event.
    if info['fileFormat'] == 1:
        numBytesPerEvent = 6
        addrPrecision = np.dtype([('addr', '>u2'), ('ts', '>u4')])
    else:
        numBytesPerEvent = 8
        addrPrecision = np.dtype([('addr', '>u4'), ('ts', '>u4')])

    fileHandle = info['fileHandle']

    # Find the number of events, assuming that the file position is just at the
    # end of the headers.
    fileHandle.seek(0, 2)
    numEventsInFile = int(np.floor(
        (fileHandle.tell() - info['beginningOfDataPointer']) /
        numBytesPerEvent))
    info['numEventsInFile'] = numEventsInFile

    # Check the startEvent and endEvent parameters
    if 'startEvent' not in info:
        info['startEvent'] = 0
    assert info['startEvent'] <= numEventsInFile
    if 'endEvent' not in info:
        info['endEvent'] = numEventsInFile
    if 'startPacket' in info:
        print("The startPacket parameter is set, but range by packets is not "
              "available for .aedat version < 3 files")
    if 'endPacket' in info:
        print("The endPacket parameter is set, but range by events is not "
              "available for .aedat version < 3 files")
    if info['endEvent'] > numEventsInFile:
        print("The file contains {}  the endEvent parameter is {}  reducing "
              "the endEvent parameter accordingly.".format(numEventsInFile,
                                                           info['endEvents']))
        info['endEvent'] = numEventsInFile
    assert info['startEvent'] <= info['endEvent']

    numEventsToRead = int(info['endEvent'] - info['startEvent'] + 1)

    # Read events
    print 'Reading events ...'
    fileHandle.seek(info['beginningOfDataPointer'] + numBytesPerEvent *
                     info['startEvent'])
    allEvents = np.fromfile(fileHandle, addrPrecision, numEventsToRead)

    allAddr = np.array(allEvents['addr'])
    allTs = np.array(allEvents['ts'])

    # Trim events outside time window.
    # This is an inefficent implementation, which allows for non-monotonic
    # timestamps.

    if 'startTime' in info:
        print 'Cropping events by time ...'
        tempIndex = np.nonzero(allTs >= info['startTime'] * 1e6)
        allAddr = allAddr[tempIndex]
        allTs = allTs[tempIndex]

    if 'endTime' in info:
        print 'Cropping events by time ...'
        tempIndex = np.nonzero(allTs <= info['endTime'] * 1e6)
        allAddr = allAddr[tempIndex]
        allTs = allTs[tempIndex]

    # Interpret the addresses
    
    """
    Split between DVS/DAVIS and DAS.
        For DAS1:
            - Special events - external injected events has never been
            implemented for DAS
            - Split between Address events and ADC samples
            - Intepret address events
            - Interpret ADC samples
        For DVS128:
            - Special events - external injected events are on bit 15 = 1 
            there is a more general label for special events which is bit 31 =
            1, but this has ambiguous interpretations  it is also overloaded
            for the stereo pair encoding - ignore this. 
            - Intepret address events
        For DAVIS:
            - Special events
                - Interpret IMU events from special events
            - Interpret DVS events according to chip class
            - Interpret APS events according to chip class
    """
    
    """
        # DAVIS. In the 32-bit address:
        # bit 32 (1-based) being 1 indicates an APS sample
        # bit 11 (1-based) being 1 indicates a special event
        # bits 11 and 32 (1-based) both being zero signals a polarity event
    """

    # Create a structure to put all the data in 
    output = {'data': {}}

    if info['source'] == 'Das1':

        # To do: DAS
        pass
    
    elif info['source'] == 'Dvs128':
    
        # To do: Dvs128
        pass
    
    else: # DAVIS
    
        """ 
        In the 32-bit address:
        bit 32 (1-based) being 1 indicates an APS sample
        bit 11 (1-based) being 1 indicates a special event 
        bits 11 and 32 (1-based) both being zero signals a polarity event
        """

        print 'Building logical indices by type ...'        
        apsOrImuMask = int('80000000', 16)
        apsOrImuLogical = np.bitwise_and(allAddr, apsOrImuMask)
        apsOrImuLogical = apsOrImuLogical.astype(bool)
        signalOrSpecialMask = int('400', 16)
        signalOrSpecialLogical = np.bitwise_and(allAddr, signalOrSpecialMask)
        signalOrSpecialLogical = signalOrSpecialLogical.astype(bool)

        # These masks are used for both frames and polarity events, so are defined
        # outside of the following if statement
        yMask = int('7FC00000', 16)
        yShiftBits = 22
        xMask = int('003FF000', 16)
        xShiftBits = 12        
        polarityMask = int('00000800', 16)
        
        specialLogical = np.logical_and(signalOrSpecialLogical,
                                       np.logical_not(apsOrImuLogical))
    # Special events
        if ('dataTypes' not in info or 'special' in info['dataTypes']) \
                 and any(specialLogical):
            print 'Processing special events ...'
            output['data']['special'] = {}
            output['data']['special']['timeStamp'] = allTs(specialLogical) 
            # No need to create address field, since there is only one type of special event
        del specialLogical
        
        polarityLogical = np.logical_and(np.logical_not(apsOrImuLogical),
                                      np.logical_not(signalOrSpecialLogical))
        # Polarity(DVS) events
        if ('dataTypes' not in info or 'polarity' in info['dataTypes']) \
                and any(polarityLogical):
            print 'Processing polarity events ...'
            polarityData = allAddr[polarityLogical]         
            output['data']['polarity'] = {}
            output['data']['polarity']['timeStamp'] = allTs[polarityLogical]
            # Y addresses
            output['data']['polarity']['y'] = np.array(np.right_shift( \
                np.bitwise_and(polarityData, yMask), yShiftBits), 'uint16')
            # X addresses
            output['data']['polarity']['x'] = np.array(np.right_shift( \
                np.bitwise_and(polarityData, xMask), xShiftBits), 'uint16')
            # Polarity bit
            
            # Note: no need for a bitshift here, since its converted to boolean anyway
            output['data']['polarity']['polarity'] = np.array( \
            np.bitwise_and(polarityData, polarityMask), 'bool')
            del polarityData
        del polarityLogical


        ImuOrPolarityMask = int('800', 16)
        ImuOrPolarityLogical = np.bitwise_and(allAddr, ImuOrPolarityMask)
        ImuOrPolarityLogical = ImuOrPolarityLogical.astype(bool)
        frameLogical = np.logical_and(apsOrImuLogical,
                                     np.logical_not(ImuOrPolarityLogical))
       # Frame events
        if ('dataTypes' not in info or 'frame' in info['dataTypes']) \
                and any(frameLogical):
            print 'Processing frames ...'
            frameSampleMask = int('1111111111', 2) 
            
            frameData = allAddr[frameLogical] 
            frameTs = allTs[frameLogical] 
    
            # Note: uses int16 instead of uint16 to allow for a subtraction operation below to look for discontinuities
            frameX = np.array(np.right_shift(np.bitwise_and(frameData, xMask), xShiftBits), 'int16') 
            frameY = np.array(np.right_shift(np.bitwise_and(frameData, yMask), yShiftBits), 'int16') 
            frameSample = np.array(np.bitwise_and(frameData, frameSampleMask), 'uint16') 
            # Note: no need for a bitshift here, since it's converted to boolean anyway
            frameSignal = np.array(np.bitwise_and(frameData, signalOrSpecialMask), 'bool') 
            
             # In general the ramp of address values could be in either
             # direction and either x or y could be the outer(inner) loop
             # Search for a discontinuity in both x and y simultaneously
            frameXDiscont = abs(frameX[1 : ] - frameX[0 : -1]) > 1 
            frameYDiscont = abs(frameY[1 : ] - frameY[0 : -1]) > 1
            frameDiscontIndex = np.where(np.logical_and(frameXDiscont, frameYDiscont))
            frameDiscontIndex = frameDiscontIndex[0] # The last line produces a tuple - we only want the array
            frameStarts = np.concatenate([[0], frameDiscontIndex  + 1, [frameData.size]])
             # Now we have the indices of the first sample in each frame, plus
             # an additional index just beyond the end of the array
            numFrames = frameStarts.size - 1 
            output['data']['frame'] = {}
            output['data']['frame']['reset']            = np.zeros(numFrames, 'bool') 
            output['data']['frame']['timeStampStart']   = np.zeros(numFrames, 'uint32') 
            output['data']['frame']['timeStampEnd']     = np.zeros(numFrames, 'uint32')
            output['data']['frame']['samples']          = np.empty(numFrames, 'object') 
            output['data']['frame']['xLength']          = np.zeros(numFrames, 'uint16') 
            output['data']['frame']['yLength']          = np.zeros(numFrames, 'uint16') 
            output['data']['frame']['xPosition']        = np.zeros(numFrames, 'uint16') 
            output['data']['frame']['yPosition']        = np.zeros(numFrames, 'uint16') 
            
            for frameIndex in range(0, numFrames) :
                if frameIndex % 10 == 9:
                    print 'Processing frame ', frameIndex + 1, ' of ', numFrames
                # All within a frame should be either reset or signal. I could
                # implement a check here to see that that's true, but I haven't
                # done so; rather I just take the first value
                output['data']['frame']['reset'][frameIndex] \
                    = not frameSignal[frameStarts[frameIndex]]  
                
                 # in aedat 2 format we don't have the four timestamps of aedat 3 format
                 # We expect to find all the same timestamps  
                 # nevertheless search for lowest and highest
                output['data']['frame']['timeStampStart'][frameIndex] \
                    = min(frameTs[frameStarts[frameIndex] : frameStarts[frameIndex + 1]])  
                output['data']['frame']['timeStampEnd'][frameIndex] \
                    = max(frameTs[frameStarts[frameIndex] : frameStarts[frameIndex + 1]])  
    
                tempXPosition = min(frameX[frameStarts[frameIndex] : frameStarts[frameIndex + 1]]) 
                output['data']['frame']['xPosition'][frameIndex] = tempXPosition 
                tempYPosition = min(frameY[frameStarts[frameIndex] : frameStarts[frameIndex + 1]]) 
                output['data']['frame']['yPosition'][frameIndex] = tempYPosition 
                output['data']['frame']['xLength'][frameIndex] \
                    = max(frameX[frameStarts[frameIndex] : frameStarts[frameIndex + 1]]) \
                        - output['data']['frame']['xPosition'][frameIndex] + 1 
                output['data']['frame']['yLength'][frameIndex] \
                    = max(frameY[frameStarts[frameIndex] : frameStarts[frameIndex + 1]]) \
                        - output['data']['frame']['yPosition'][frameIndex] + 1 
                # If we worked out which way the data is ramping in each
                # direction, and if we could exclude data loss, then we could
                # do some nice clean matrix transformations  but I'm just going
                # to iterate through the samples, putting them in the right
                # place in the array according to their address
                
                 # first create a temporary array - there is no concept of
                 # colour channels in aedat2
                tempSamples = np.zeros((output['data']['frame']['yLength'][frameIndex], \
                                    output['data']['frame']['xLength'][frameIndex]), dtype='uint16') 
                for sampleIndex in range(frameStarts[frameIndex], frameStarts[frameIndex + 1]):
                    tempSamples[frameY[sampleIndex] \
                                    - output['data']['frame']['yPosition'][frameIndex], \
                                frameX[sampleIndex] \
                                    - output['data']['frame']['xPosition'][frameIndex]] \
                        = frameSample[sampleIndex] 

                output['data']['frame']['samples'][frameIndex] = tempSamples 
    
            if 'subtractResetRead' in info and info['subtractResetRead'] \
                    and 'reset' in output['data']['frame']:
                # Make a second pass through the frames, subtracting reset
                # reads from signal reads
                frameCount = 0
                for frameIndex in range(0, numFrames):
                    if frameIndex % 10 == 9:
                        print 'Performing subtraction on frame ', frameIndex + 1, ' of ', numFrames
                    if output['data']['frame']['reset'][frameIndex]: 
                        resetFrame = output['data']['frame']['samples'][frameIndex] 
                        resetXPosition = output['data']['frame']['xPosition'][frameIndex] 
                        resetYPosition = output['data']['frame']['yPosition'][frameIndex] 
                        resetXLength = output['data']['frame']['xLength'][frameIndex] 
                        resetYLength = output['data']['frame']['yLength'][frameIndex]                     
                    else: 
                         # If a resetFrame has not yet been found, 
                         # push through the signal frame as is
                        if not 'resetFrame' in locals():
                            output['data']['frame']['samples'][frameCount] \
                                = output['data']['frame']['samples'][frameIndex] 
                        else:
                             # If the resetFrame and signalFrame are not the same size,    
                             # don't attempt subtraction 
                             # (there is probably a cleaner solution than this - could be improved)
                            if resetXPosition != output['data']['frame']['xPosition'][frameIndex] \
                                or resetYPosition != output['data']['frame']['yPosition'][frameIndex] \
                                or resetXLength != output['data']['frame']['xLength'][frameIndex] \
                                or resetYLength != output['data']['frame']['yLength'][frameIndex]:
                                output['data']['frame']['samples'][frameCount] \
                                    = output['data']['frame']['samples'][frameIndex] 
                            else:
                                 # Do the subtraction
                                output['data']['frame']['samples'][frameCount] \
                                    = resetFrame - output['data']['frame']['samples'][frameIndex] 
                                # This operation was on unsigned integers, set negatives to zero
                                output['data']['frame']['samples'][frameCount][output['data']['frame']['samples'][frameCount] > 32767] = 0
                             # Copy over the reset of the info
                            output['data']['frame']['xPosition'][frameCount] \
                                = output['data']['frame']['xPosition'][frameIndex] 
                            output['data']['frame']['yPosition'][frameCount] \
                                = output['data']['frame']['yPosition'][frameIndex] 
                            output['data']['frame']['xLength'][frameCount] \
                                = output['data']['frame']['xLength'][frameIndex] 
                            output['data']['frame']['yLength'][frameCount] \
                                = output['data']['frame']['yLength'][frameIndex] 
                            output['data']['frame']['timeStampStart'][frameCount] \
                                = output['data']['frame']['timeStampStart'][frameIndex]  
                            output['data']['frame']['timeStampEnd'][frameCount] \
                                = output['data']['frame']['timeStampEnd'][frameIndex]                              
                            frameCount = frameCount + 1
                 # Clip the arrays
                output['data']['frame']['xPosition'] \
                    = output['data']['frame']['xPosition'][0 : frameCount] 
                output['data']['frame']['yPosition'] \
                    = output['data']['frame']['yPosition'][0 : frameCount] 
                output['data']['frame']['xLength'] \
                    = output['data']['frame']['xLength'][0 : frameCount] 
                output['data']['frame']['yLength'] \
                    = output['data']['frame']['yLength'][0 : frameCount] 
                output['data']['frame']['timeStampStart'] \
                    = output['data']['frame']['timeStampStart'][0 : frameCount] 
                output['data']['frame']['timeStampEnd'] \
                    = output['data']['frame']['timeStampEnd'][0 : frameCount] 
                output['data']['frame']['samples'] \
                    = output['data']['frame']['samples'][0 : frameCount]
                del output['data']['frame']['reset']   # reset is no longer needed
        del frameLogical
    
    
        # IMU events
        # These come in blocks of 7, for the 7 different values produced in
        # a single sample; the following code recomposes these
        # 7 words are sent in series, these being 3 axes for accel, temperature, and 3 axes for gyro

        imuLogical = np.logical_and(apsOrImuLogical, ImuOrPolarityLogical)
        if ('dataTypes' not in info or 'imu6' in info['dataTypes']) \
                and any(imuLogical):
            print 'Processing IMU6 events ...'
            output['data']['imu6'] = {}
            output['data']['imu6']['timeStamp'] = allTs[imuLogical]

            if np.mod(np.count_nonzero(imuLogical), 7) > 0: 
                print 'The number of IMU samples is not divisible by 7, so IMU samples are not interpretable'
            else:
                output['data']['imu6']['timeStamp'] = allTs[imuLogical]
                output['data']['imu6']['timeStamp'] \
                    = output['data']['imu6']['timeStamp'][0 : : 7]
    
            #Conversion factors
            accelScale = 1.0/16384
            gyroScale = 1.0/131
            temperatureScale = 1.0/340
            temperatureOffset=35.0
    
            imuDataMask = int('0FFFF000', 16)
            imuDataShiftBits = 12
            rawData = np.right_shift(np.bitwise_and(allAddr[imuLogical], imuDataMask), imuDataShiftBits)
            # This is a uint32 which contains an int16. Need to convert to int16 before converting to float.             
            rawData = rawData.astype('int16')
            rawData = rawData.astype('float32')
                        
            output['data']['imu6']['accelX']        = rawData[0 : : 7] * accelScale    
            output['data']['imu6']['accelY']        = rawData[1 : : 7] * accelScale    
            output['data']['imu6']['accelZ']        = rawData[2 : : 7] * accelScale    
            output['data']['imu6']['temperature']   = rawData[3 : : 7] * temperatureScale + temperatureOffset   
            output['data']['imu6']['gyroX']         = rawData[4 : : 7] * gyroScale  
            output['data']['imu6']['gyroY']         = rawData[5 : : 7] * gyroScale
            output['data']['imu6']['gyroZ']         = rawData[6 : : 7] * gyroScale
        del imuLogical

    # If you want to do chip-specific address shifts or subtractions,
    # this would be the place to do it.

    print 'Augmenting info ...'
    output['info'] = info

    # calculate numEvents fields  also find first and last timeStamps
    output['info']['firstTimeStamp'] = np.infty
    output['info']['lastTimeStamp'] = 0

    if 'polarity' in output['data']:
        output['data']['polarity']['numEvents'] = \
            len(output['data']['polarity']['timeStamp'])
        if output['data']['polarity']['timeStamp'][0] < \
                output['info']['firstTimeStamp']:
            output['info']['firstTimeStamp'] = \
                output['data']['polarity']['timeStamp'][0]
        if output['data']['polarity']['timeStamp'][-1] > \
                output['info']['lastTimeStamp']:
            output['info']['lastTimeStamp'] = \
                output['data']['polarity']['timeStamp'][-1]

    return output
