# -*- coding: utf-8 -*-

import numpy as np
import cv2

import rosbag
from dvs_msgs.msg import Event, EventArray
from geometry_msgs.msg import PoseStamped
from sensor_msgs.msg import CameraInfo
from sensor_msgs.msg import Image
from cv_bridge import CvBridge, CvBridgeError
import os.path
import rospy

def make_pose_msg(position, orientation, timestamp):
    pose_msg = PoseStamped()
    pose_msg.header.stamp = timestamp
    pose_msg.header.frame_id = 'train'
    pose_msg.pose.position.x = position[0]
    pose_msg.pose.position.y = position[1]
    pose_msg.pose.position.z = position[2]
    pose_msg.pose.orientation.x = orientation[0]
    pose_msg.pose.orientation.y = orientation[1]
    pose_msg.pose.orientation.z = orientation[2]
    pose_msg.pose.orientation.w = orientation[3]
    return pose_msg    


def make_event(x, y, ts, pol):
    e = Event()
    e.x = x
    e.y = y
    e.ts = ts
    e.polarity = pol
    return e
    


# Open bag
bag = rosbag.Bag('output/SmallSectionFromCam1Lower.bag', 'w')

#%% Odometry
odometry = np.loadtxt('output/odometry.txt')
for stamp_x in odometry:
    stamp, x = stamp_x
    t = rospy.Time(secs=stamp/1000000.)
    #print t.to_sec()
    pos = [x/1000.0, 0., 0.]
    quat = [0., 0., 0., 1.]
    bag.write(topic='/dvs/pose', msg=make_pose_msg(pos, quat, t), t=t)   

#%% Images

bridge = CvBridge()

images = np.loadtxt('output/images.txt')

for idx_t in images:
    idx, t = idx_t
    idx = int(idx)
    img= cv2.imread('output/images/{:02}.png'.format(idx), 0)
    
    ts = rospy.Time(secs=t/1000000.0)
    img_msg = bridge.cv2_to_imgmsg(img, 'mono8')
    img_msg.header.stamp = ts
            
    bag.write(topic='/dvs/image_raw', msg=img_msg, t=ts)

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