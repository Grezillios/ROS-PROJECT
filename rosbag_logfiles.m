%% Work with rosbag Logfiles
%% Introduction
% A _rosbag_ or bag is a file format in ROS for storing message data.
% These bags are often created by subscribing to one or more ROS
% topics, and storing the received message data in an efficient file
% structure. MATLAB(R) can read these rosbag files and help with
% filtering and extracting message data. See <docid:robotics_ug.buryi14-1 
% ROS Log Files (rosbags)> for more information about rosbag support in
% MATLAB.
%
% In this example, you will load a rosbag and learn how to select and retrieve
% the contained messages.
%
% Prerequisites: <docid:robotics_examples.example-ROSMessagesExample>

% Copyright 2014-2015 The MathWorks, Inc.


%% Load a rosbag
% * Load an example file using the |<docid:robotics_ref.bupf5_j rosbag>| command.
% Specify the path to the bag file either as an absolute or
% relative path:
%%
filepath = fullfile(fileparts(which('ROSWorkingWithRosbagsExample')), 'data', 'ex_multiple_topics.bag');
bag = rosbag(filepath)

%% 
% The object returned from the |<docid:robotics_ref.bupf5_j rosbag>| call is a
% |BagSelection| object, which is a
% representation of all the messages in the rosbag.
%
% The object display shows details about how many messages are contained
% in the file (|NumMessages|) and the time when the first (|StartTime|) and
% the last (|EndTime|) message were recorded.
%
% *  Evaluate the |AvailableTopics| property to see more information about
% the topics and message types that are recorded in the bag:
%%
bag.AvailableTopics

%%
% The |AvailableTopics| table contains the sorted list of topics that are
% included in the rosbag. The table stores the number
% of messages, the message type, and the message definition for the topic. For more
% information on the MATLAB table data type and what operations you can perform 
% on it, see the documentation for |<docid:matlab_doccenter.btzmn1p Tables>|.
%
% Initially the rosbag is only indexed by MATLAB and no actual
% message data is read.
%
% You might want to filter and narrow the selection of messages as much as
% possible based on this index before any messages are loaded into MATLAB
% memory.


%% Select Messages
% Before you retrieve any message data, you must select a set of messages 
% based on criteria such as time stamp, topic name, and message type.
%
% * You can examine all the messages in the current selection with:
%%
bag.MessageList

%% 
% The |MessageList| table contains one row for each message in the bag
% (there are over 30,000 rows for the bag in this example).
% The rows are sorted by the time stamp the first column that represents
% the time (in seconds) when this message was recorded.
%
% * Since the list is very large, you can also display a selection of rows
% with the familiar row and column selection syntax:
%%
bag.MessageList(500:505,:)

%%
% Use the |<docid:robotics_ref.buqnyj9 select>| function to narrow the selection of messages. 
% The |<docid:robotics_ref.buqnyj9 select>| function operates on the |bag| object.
%
% You can filter the message list by time, topic name, message
% type, or any combination of the three.
% 
% * To select all messages that were published on the |/odom|
% topic, use the following |<docid:robotics_ref.buqnyj9 select>| command:
%%
bagselect1 = select(bag, 'Topic', '/odom')

%%
% Calls to the |<docid:robotics_ref.buqnyj9 select>| function return another
% |BagSelection| object, which can be used to 
% make further selections or retrieve message data. All selection objects
% are independent of each other, so you can clear them from the workspace
% once you are done.
%
% * You can make a different selection that combines two criteria. To get
% the list of messages that were recorded within the first 30 seconds of
% the rosbag and published on the |/odom| topic, enter the following command:
%%
start = bag.StartTime
bagselect2 = select(bag, 'Time', [start start + 30], 'Topic', '/odom')

%%
% * Use the last selection to narrow down the time window even further:
%%
bagselect3 = select(bagselect2, 'Time', [205 206])

%%
% The selection in this last step operated on the existing |bagselect2|
% selection and returned a new |bagselect3| object.
%
% * If you want to save a set of selection options,
% store the selection elements in a cell array and then
% re-use it later as an input to the |<docid:robotics_ref.buqnyj9 select>| function:
%%
selectOptions = {'Time', [start, start+1; start+5, start+6], 'MessageType', {'sensor_msgs/LaserScan', 'nav_msgs/Odometry'}};
bagselect4 = select(bag, selectOptions{:})


%% Read Selected Message Data
% After you narrow your message selection,
% you might want to read the actual message data into MATLAB. Depending on the
% size of your selection, this can take a long time and consume a lot of
% your computer's memory.
% 
% * To retrieve the messages in you selection as a cell array, use the
% |<docid:robotics_ref.buqn04a readMessages>| function:
%%
msgs = readMessages(bagselect3);
size(msgs)

%%
% The resulting cell array contains as many elements as indicated in the
% |NumMessages| property of the selection object.
% 
% * In reading message data, you can also be more selective and only
% retrieve messages at specific indices. Here is an example of retrieving
% 4 messages:
%%
msgs = readMessages(bagselect3, [1 2 3 7])
msgs{2}

%%
% Each message in the cell array is a standard MATLAB ROS message object.
% For more information on messages, see the <docid:robotics_examples.example-ROSMessagesExample>
% example.


%% Extract Message Data as Time Series 
% Sometimes you are not interested in the complete messages, but only in
% specific properties that are common to all the messages in a selection.
% In this case, it is helpful to retrieve the message data as a time series
% instead. A time series is a data vector that is sampled over time and
% represents the time evolution of one or more dynamic properties. For more
% information on the MATLAB time series support, see the documentation for
% |<docid:matlab_doccenter.time-series-objects Time Series>|.
%
% In the case of ROS messages within a rosbag, a time series
% can help to express the change in particular message
% elements through time. You can extract this information through
% the |<docid:robotics_ref.buqn12a timeseries>| function. This is memory-efficient, since the complete
% messages do not have to be stored in memory.
%
% * Use the same selection, but use the |<docid:robotics_ref.buqn12a timeseries>| function to only
% extract the properties for x-position and z-axis angular velocity:
%%
ts = timeseries(bagselect3, 'Pose.Pose.Position.X', 'Twist.Twist.Angular.Z')

%%
% The return of this call is a |<docid:matlab_ref.ref_q0yv4hj7h timeseries>| 
% object that can be used for further analysis or processing.
% 
% Note that this method of extracting data is only supported if the current 
% selection contains a single topic with a single message type.
% 
% * To see the data contained within the time series, access the |Data|
% property:
%%
ts.Data

%%
% * There are many other possible ways to work with the time series data.
% Calculate the mean of the data columns:
%%
mean(ts)

%%
% * You can also plot the data of the time series:
%%
figure
plot(ts, 'LineWidth', 3)

%%
displayEndOfDemoMessage(mfilename)