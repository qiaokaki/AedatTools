# -*- coding: utf-8 -*-

# Params

import sys
sys.path.append('/usr/local/lib/python2.7/site-packages')
sys.path.append('/opt/ros/kinetic/lib/python2.7/dist-packages')
sys.path.append('/home/sim/catkin_ws/devel/lib/python2.7/dist-packages')



import numpy as np
import cv2

import rosbag
from dvs_msgs.msg import Event, EventArray
#from geometry_msgs.msg import PoseStamped
#from sensor_msgs.msg import CameraInfo
#from sensor_msgs.msg import Image
from cv_bridge import CvBridge, CvBridgeError
import os.path as ospath
import rospy
import scipy.io as sio


def MakeEvent(x, y, ts, pol):
    e = Event()
    e.x = x
    e.y = y
    e.ts = ts
    e.polarity = pol
    return e

def ExportToRosbag(aedat):
    
    # bag file name and path will be the same as origin .aedat file, unless overruled
    bagFilePath = ospath.splitext(aedat['info']['filePath'])[0] + '.bag'
    
    # Open bag
    bag = rosbag.Bag(bagFilePath, 'w')

#%% Images

    bridge = CvBridge()
    
    for frameIndex in range(0, aedat['data']['frame']['numFrames']):
        img = aedat['data']['frame']['samples'][frameIndex]
        # The sample is really 10 bits, but held in a uint16; 
        # convert to uint8, dropping the least significant 2 bits
        img = img.astype('uint8')
        # To do: make compatible with aedat3 imports, with different timestamp fields
        timeStamp = rospy.Time(secs=aedat['data']['frame']['timeStampStart'][frameIndex]/1000000.0)
        img_msg = bridge.cv2_to_imgmsg(img, 'mono8')
        img_msg.header.stamp = timeStamp
        bag.write(topic='/dvs/image_raw', msg=img_msg, t=timeStamp)
    
    #%% Events
    i = 0
    
    num_events_per_array = 25000
    
    with open('output/events.txt') as fp:
        for line in fp:
            
            #if i > 200000:
            #    break        
            
            if i % num_events_per_array == 0:
    
                if i > 0:
                    print 'Writing event array message', i, 'with', len(events), 'events'
                    event_array = EventArray()
                    event_array.header.stamp = ts
                    event_array.width = 346
                    event_array.height = 260
                    event_array.events = events
                    bag.write(topic='/dvs/events', msg=event_array, t=ts)            
                
                #print 'Creating new event array message'
                events = []
            
            line = line.rstrip('\n')
            line = line.rstrip(' ')
            t, x, y, pol = line.split(' ')
            t, x, y, pol = int(t), int(x), int(y), int(pol)
            ts = rospy.Time(secs=float(t)/1000000.0)
            i += 1
            ev = make_event(x, y, ts, pol > 0)
            events.append(ev)
    
    bag.close()