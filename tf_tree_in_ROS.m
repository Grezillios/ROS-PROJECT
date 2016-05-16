%% Access the tf Transformation Tree in ROS
%% Introduction
% The tf system in ROS keeps track of multiple coordinate frames and 
% maintains the relationship between them in a tree structure. tf is
% distributed, so that the information about all coordinate frames is
% available to every node in the ROS network.
% MATLAB(R) allows you to access this transformation tree. This example
% familiarizes you with accessing the available coordinate frames,
% retrieving transformations between them, and transform points, vectors, 
% and other entities between any two coordinate frames. 
%
% Prerequisites: <docid:robotics_examples.example-ROSGettingStartedExample>, 
% <docid:robotics_examples.example-ROSNetworkingExample>

% Copyright 2014-2015 The MathWorks, Inc.


%% Start up
% * Initialize the ROS system.
%%
rosinit

%%
% To create a realistic environment for this example, use
% |exampleHelperROSStartTfPublisher| to broadcast several transformations. 
% The transformations represent a camera that is mounted on a robot. 
%
% There are three coordinate frames that are defined in this transformation
% tree:
%%
% * the robot base frame (|robot_base|)
% * the camera's mounting point (|mounting_point|)
% * the optical center of the camera (|camera_center|)
%%
% Two transforms are being published: 
% the transformation from the robot base to the camera's mounting point 
% and the transformation from the mounting point
% to the center of the camera.
%%
exampleHelperROSStartTfPublisher
%%
% A visual representation of the three coordinate frames looks as
% follows.
%
% <<tf_coordinate_frames.png>>
% 
% Here, the x, y, and z axes of each frame are represented by red, green, and blue
% lines respectively. The parent-child relationship between the coordinate frames is
% shown through a brown arrow pointing from the child to its parent frame.
%%
% * Create a new transformation tree 
% object with the |<docid:robotics_ref.bupf5_j_12 rostf>| function. You
% can use this object to access all available transformations and apply them 
% to different entities.
%%
tftree = rostf

%%
% Once the object is created, it starts receiving tf transformations and
% buffers them internally. You should keep the |tftree| variable in the
% workspace, so that it continues to receive data.
% 
% * Pause for a little bit to make sure that all transformations
% are received.
%%
pause(1);

%% 
% * You can see the names of all the available coordinate frames by
% accessing the |AvailableFrames| property.
%%
tftree.AvailableFrames

%%
% This should show the three coordinate frames that describe the relationship
% between the camera, its mounting point, and the robot.


%% Receive Transformations
% 
% Now that the transformations are available, you can inspect them. Any transformation 
% is described by a ROS |geometry_msgs/TransformStamped| message and has a 
% translational and rotational component.
%
% * Retrieve the transformation that describes the relationship between the
% mounting point and the camera center. Use the |<docid:robotics_ref.buqbijb getTransform>| function to do that.
%%
mountToCamera = getTransform(tftree, 'mounting_point', 'camera_center');
mountToCameraTranslation = mountToCamera.Transform.Translation
quat = mountToCamera.Transform.Rotation
mountToCameraRotationAngles = rad2deg(quat2eul([quat.W quat.X quat.Y quat.Z]))

%%
% Relative to the mounting point, the camera center is located 0.5 meters
% along the z-axis and is rotated by 90 degrees around the y-axis.
%
% * To inspect the relationship between the robot base and the camera's 
% mounting point, call |<docid:robotics_ref.buqbijb getTransform>| again.
%%
baseToMount = getTransform(tftree, 'robot_base', 'mounting_point');
baseToMountTranslation = baseToMount.Transform.Translation
baseToMountRotation = baseToMount.Transform.Rotation

%%
% The mounting point is located at 1 meter along the robot base's x-axis.


%% Apply Transformations
%
% Assume now that you have a 3D point that is defined in the
% |camera_center| coordinate frame and you want to calculate what the point
% coordinates in the |robot_base| frame are.
%
% * Use the |<docid:robotics_ref.buxiu5t-1 waitForTransform>| function to wait until the transformation
% between the |camera_center| and |robot_base| coordinate frames becomes
% available. This call blocks until the transform that takes data from
% |camera_center| to |robot_base| is valid and available in the transformation tree.
%%
waitForTransform(tftree, 'robot_base', 'camera_center');

%%
% * Now define a point at position |[3 1.5 0.2]| in the camera center's coordinate
% frame. You will subsequently transform this point into |robot_base| coordinates.
%%
pt = rosmessage('geometry_msgs/PointStamped');
pt.Header.FrameId = 'camera_center';
pt.Point.X = 3;
pt.Point.Y = 1.5;
pt.Point.Z = 0.2;

%%
% * You can transform the point coordinates by calling the |<docid:robotics_ref.buqbzo2 transform>| 
% function on the transformation tree object.
% Specify what the target coordinate frame of this transformation is. In
% this example, use |robot_base|.
%%
tfpt = transform(tftree, 'robot_base', pt)

%%
% The transformed point |tfpt| has the following 3D coordinates.
%%
tfpt.Point
%%
% Besides |PointStamped| messages, the |<docid:robotics_ref.buqbzo2 transform>| function allows you to 
% transform other entities like poses (|geometry_msgs/PoseStamped|),
% quaternions (|geometry_msgs/QuaternionStamped|), and point clouds
% (|sensor_msgs/PointCloud2|).
%
% * If you want to store a transformation, you can retrieve it with the
% |<docid:robotics_ref.buqbijb getTransform>| function.
%%
robotToCamera = getTransform(tftree, 'robot_base', 'camera_center')

%%
% This transformation can be used to transform coordinates in the
% |camera_center| frame into coordinates in the |robot_base| frame.
%%
robotToCamera.Transform.Translation
robotToCamera.Transform.Rotation


%% Send Transformations
% You can also broadcast a new transformation to the ROS network.
%
% Assume that you have a simple transformation that describes the offset of the
% |wheel| coordinate frame relative to the |robot_base| coordinate frame. The 
% wheel is mounted -0.2 meters along the y-axis and -0.3 along the z-axis.
% The wheel has a relative rotation of 30 degrees around the y-axis.
%
% * Create the corresponding |geometry_msgs/TransformStamped| message that
% describes this transformation. The source coordinate frame, |wheel|,
% is placed to the |ChildFrameId| property. The target coordinate frame,
% |robot_base|, is added to the |Header.FrameId| property.
%%
tfStampedMsg = rosmessage('geometry_msgs/TransformStamped');
tfStampedMsg.ChildFrameId = 'wheel';
tfStampedMsg.Header.FrameId = 'robot_base';

%%
% * The transformation itself is described in the |Transform| property. It
% contains a |Translation| and a |Rotation|. Fill in the values that are
% listed above.
%
% * The |Rotation| is described as a quaternion. To convert the 30 degree
% rotation around the y-axis to a quaternion, you can use the
% |<docid:robotics_ref.buog46n-1 axang2quat>| function. The y-axis is described
% by the |[0 1 0]| vector and 30 degrees can be converted to radians with
% the |deg2rad| function.
%%
tfStampedMsg.Transform.Translation.X = 0;
tfStampedMsg.Transform.Translation.Y = -0.2;
tfStampedMsg.Transform.Translation.Z = -0.3;

quatrot = axang2quat([0 1 0 deg2rad(30)])
tfStampedMsg.Transform.Rotation.W = quatrot(1);
tfStampedMsg.Transform.Rotation.X = quatrot(2);
tfStampedMsg.Transform.Rotation.Y = quatrot(3);
tfStampedMsg.Transform.Rotation.Z = quatrot(4);

%%
% * Use |<docid:robotics_ref.bupf5_j_13 rostime>| to retrieve the current system time and use that to
% timestamp the transformation. This lets the recipients know at which
% point in time this transformation was valid.
%%
tfStampedMsg.Header.Stamp = rostime('now');

%%
% * Use the |<docid:robotics_ref.buqby_x-1 sendTransform>| function to broadcast this transformation.
%%
sendTransform(tftree, tfStampedMsg)

%%
% The new |wheel| coordinate frame is now also in the list of available
% coordinate frames.
%%
tftree.AvailableFrames

%%
% The final visual representation of all four coordinate frames looks as
% follows.
%
% <<tf_coordinate_frames_with_wheel.png>>
% 
% You can see that the |wheel| coordinate frame has the translation and
% rotation that you specified in sending the transformation.


%% Stop Example Publisher and Shut Down ROS Network
% * Stop the example transformation publisher.
%% 
exampleHelperROSStopTfPublisher

%%
% * Shut down the ROS master and delete the global node.
%%
rosshutdown
%%
displayEndOfDemoMessage(mfilename)