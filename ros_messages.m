%% Work with Basic ROS Messages
%% Introduction
% Messages are the primary container for exchanging data in ROS. Topics (see 
% <docid:robotics_examples.example-ROSPublishAndSubscribeExample>) and services 
% (see <docid:robotics_examples.example-ROSServicesExample>)
% use messages to carry data between nodes.
%
% To identify its data structure, each message has a _message type_. For
% example, sensor data from a laser scanner is typically sent in a message of
% type |sensor_msgs/LaserScan|. Each message type identifies the data
% elements that are contained in a message. Every message type name is a
% combination of a package name, followed by a forward slash /, and a type name:
%
% <<message_type_structure.png>>
%
% MATLAB(R) supports many ROS message types that are commonly encountered 
% in robotics applications. In this example, you will examine some of the 
% ways to create, explore, and populate ROS messages in MATLAB.
%
% Prerequisites: <docid:robotics_examples.example-ROSGettingStartedExample>,
% <docid:robotics_examples.example-ROSNetworkingExample>

% Copyright 2014-2015 The MathWorks, Inc.


%% Find Message Types
% * Initialize the ROS master and global node.
%%
rosinit

%%
% * Use |exampleHelperROSCreateSampleNetwork| to populate the ROS network
% with three additional nodes and sample publishers and subscribers.
%%
exampleHelperROSCreateSampleNetwork

%%
% * There are various nodes on the network with a few topics
% and affiliated publishers and subscribers.
% * You can see the full list of available topics by calling |<docid:robotics_ref.bupf5_j_14 rostopic> list|.
% |/scan| is one of topics that is listed.
%%
rostopic list

%%
% * If you want to know more about the type of data that is sent through the
% |/scan| topic, use the |<docid:robotics_ref.bupf5_j_14 rostopic> info /scan| command to examine it.
% |/scan| has a message type of |sensor_msgs/LaserScan|.
%%
rostopic info /scan

%%
% The command output also tells you which nodes are publishing and
% subscribing to the topic. To learn about publishers and subscribers, see
% <docid:robotics_examples.example-ROSPublishAndSubscribeExample>.
%
% * To find out more about the topic's message type, create an
% empty message of the same type. Use the |<docid:robotics_ref.bupf5_j_2 rosmessage>|
% function.
%%
scandata = rosmessage('sensor_msgs/LaserScan')

%%
% The created message |scandata| has many properties associated with data
% typically received from a laser scanner. For example, the minimum sensing
% distance is stored in the |RangeMin| property and the maximum sensing
% distance in |RangeMax|.
%
% * If you do not want to use a string to define the message type, you can also
% use the |<docid:robotics_ref.bupf5_k rostype>| command, which allows for convenient access
% to a list of message types. |<docid:robotics_ref.bupf5_k rostype>| supports tab-completion and can 
% find message types that correspond to the preceding string.
%%
scantype = rostype.sensor_msgs_LaserScan

%%
% * Using this string, create an empty message of the same type as the previous
% message.
%%
scandata = rosmessage(scantype)

%% 
% * To see a complete list of all message types available
% for topics and services, use the |<docid:robotics_ref.bupf5_j_3 rosmsg> list| command:
%%
rosmsg list


%% Explore Message Structure and Get Message Data
% ROS messages are objects and the message data is stored in properties.
% MATLAB(R) features convenient ways to find and explore the contents of
% messages. 
%
% * If you subscribe to the |/pose| topic, you can receive and examine the
% messages that are sent.
%%
posesub = rossubscriber('/pose')

%%
% * Use |<docid:robotics_ref.buqbyro receive>| to acquire data from the subscriber. 
% Once a new message is received, the function will return it and store it
% in the |posedata| variable (the second argument is a time-out in seconds).
%%
posedata = receive(posesub, 10)

%%
% * The message has a type of |geometry_msgs/Twist|. There are two
% other fields in the message: |Linear| and |Angular|. You can see the
% values of these message fields by accessing them directly:
%%
posedata.Linear

%%
posedata.Angular

%%
% You can see that each of the values of these message fields is actually a message in itself. 
% The message type for these is |geometry_msgs/Vector3|.
% |geometry_msgs/Twist| is a composite message made up of
% two |geometry_msgs/Vector3| messages.
%
% * Data access for these nested messages works exactly the same as
% accessing the data in other messages. Access the |X| component of 
% the |Linear| message using this command:
%%
xpos = posedata.Linear.X

%%
% * If you want a quick summary of all the data contained in a message, you
% can call the |<docid:robotics_ref.buqb0sj showdetails>| function.
% |showdetails| works on messages of any type and will recursively display 
% all the message data properties.
%%
showdetails(posedata)

%%
% |<docid:robotics_ref.buqb0sj showdetails>| helps you during debugging and when you want to
% quickly explore the contents of a message.


%% Set Message Data
% * You can also set message property values. Create a message with type
% |geometry_msgs/Twist|.
%%
twist = rosmessage(rostype.geometry_msgs_Twist)

%%
% * The numeric properties of this message are initialized to "0" by default. 
% You can modify any of the properties of this message.
% Make the |Linear.Y| entry equal to 5.
%%
twist.Linear.Y = 5;

%%
% * You can view the message data to make sure that your change took effect.
%%
twist.Linear

%%
% Once a message is populated with your data, you can use it with publishers, subscribers, and
% services. See the <docid:robotics_examples.example-ROSPublishAndSubscribeExample>
% and <docid:robotics_examples.example-ROSServicesExample> examples.


%% Copy Messages
% There are two ways to copy the contents of a message:
%
% * You can create a _reference copy_ in which the copy and the original
% messages share the same data
% * You can create a _deep copy_ in which the copy and the original messages
% each have their own data.
%
% A reference copy is useful if you want to share message data between different
% functions or objects, whereas a deep copy is necessary if you want an
% independent copy of a message.
%
% * Make a _reference copy_ of a message by using the '=' sign. This creates a
% variable that references the same message contents as the original
% variable.
%%
twistCopyRef = twist

%%
% * Modify the |Linear.Z| field of |twistCopyRef|, and see that it changes the
% contents of |twist| as well:
%%
twistCopyRef.Linear.Z = 7;
%%
twist.Linear

%%
% * Make a _deep copy_ of |twist| so that you can change its
% contents without affecting the original data. Make a new message, |twistCopyDeep|, 
% using the |copy| function:
%%
twistCopyDeep = copy(twist)

%%
% * Modify the |Linear.X| property of |twistCopyDeep| and notice that the contents of
% |twist| remain unchanged.
%%
twistCopyDeep.Linear.X = 100;
%%
twistCopyDeep.Linear
%%
twist.Linear


%% Save and Load Messages
% You can save messages and store the contents for later use.
%
% * Get a new message from the subscriber:
%%
posedata = receive(posesub,10)

%%
% * Save the pose data to a .mat file using MATLAB's |<docid:matlab_ref.btox10b-1 save>| function.
%%
save('posedata.mat','posedata')

%%
% * Before loading the file back into the workspace, clear the |posedata|
% variable.
%%
clear posedata

%%
% * Now you can load the message data by calling the
% |<docid:matlab_ref.btm0etn-1 load>| function. This loads the |posedata|
% from above into the |messageData| structure. |posedata| is a data field of the struct.
%%
messageData = load('posedata.mat')

%%
% * Examine |messageData.posedata| to see the message contents.
%%
messageData.posedata

%%
% * You can now delete the MAT file with
%%
delete('posedata.mat')


%% Object Arrays in Messages
% Some messages from ROS are stored in <docid:matlab_oop.bsfenjx object arrays>. 
% These should be handled differently from typical data
% arrays.
%
% * In your workspace, the variable |tf| contains a sample message (the |exampleHelperROSCreateSampleNetwork| 
% script created the variable). In this
% case, it is a message of type |tf/tfMessage| used for coordinate transformations. 
%%
tf

%%
% |tf| has two fields: |MessageType| 
% contains a standard data array and |Transforms| contains an object
% array. There are 53 objects stored in |Transforms|, and all of them have
% the same structure.
%
% * Expand |tf| in |Transforms| to see the structure:
%%
tf.Transforms

%%
% * Each object in |Transforms| has four properties. Expand to see the
% |Transform| field of |Transforms|.
%%
tf.Transforms.Transform

%%
% * Notice that the output returns 53 individual answers, since each object
% is evaluated and returns the value of its |Transform| field. This format is
% not always useful, so you can convert it to a cell array with the
% following command:
%%
cellTransforms = {tf.Transforms.Transform}

%%
% This puts all 53 object entries in a cell array, which allows you to
% access them with indexing.
%
% * In addition, you can access object array elements the same way you
% access standard MATLAB vectors:
%%
tf.Transforms(5)

%%
% * You can access the properties of individual array elements:
%%
tf.Transforms(5).Transform.Translation

%%
% This exposes the translation component of the fifth transform in the
% list of 53.


%% Shut Down ROS Network
% * Remove the sample nodes, publishers, and subscribers from the ROS network.
%% 
exampleHelperROSShutDownSampleNetwork
%%
% * Shut down the ROS master and delete the global node.
%%
rosshutdown
%% 


%% Next Steps
% * See <docid:robotics_examples.example-ROSSpecializedMessagesExample> 
% for examples of handling images, point clouds, and laser scan messages.
% * For application examples, see the <docid:robotics_examples.example-GettingStartedWithGazeboExample> 
% or <docid:robotics_examples.example-GettingStartedWithRealTurtleBotExample> examples.
%%
displayEndOfDemoMessage(mfilename)
