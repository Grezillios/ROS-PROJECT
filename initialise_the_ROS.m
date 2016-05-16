%% Get Started with ROS
%% Introduction
%
% Robot Operating System (ROS) is a communication interface that enables
% different parts of a robot system to discover, send, and receive data.
% MATLAB(R) support for ROS is a library of functions that
% allows you to exchange data with ROS-enabled physical robots, or robot
% simulators such as Gazebo(R).
%
% This example introduces how to:
%
% * Set up ROS within MATLAB
% * Get information about capabilities in a ROS network
% * Get information about ROS messages

% Copyright 2014-2015 The MathWorks, Inc.


%% ROS Terminology
%
% * A _ROS network_ comprises different parts of a robot system (such as a
% planner or a camera interface) that communicate over ROS. The network can
% be distributed over several machines.
%
% * A _ROS master_ coordinates the different parts of a ROS network. It
% is identified by a _Master URI_ (Uniform Resource Identifier) that
% specifies the hostname or IP address of the machine where the master is
% running.
%
% * A _ROS node_ is an entity that contains a collection of related ROS
% capabilities (such as publishers, subscribers and services). A ROS
% network can have many ROS nodes.
%
% * _Publishers_, _subscribers_, and _services_ are different kinds of ROS
% entities that process data. They exchange data using _messages_.
%
% * A publisher sends messages to a specific _topic_ (such as
% "odometry"), and subscribers to that topic receive those messages.
% There can be multiple publishers and subscribers associated with a single
% topic.
%
% For more information, see <docid:robotics_gs.bumviaw-1> and the
% <http://wiki.ros.org/ROS/Concepts Concepts> section on the ROS website.


%% Initialize ROS Network
% * Use |<docid:robotics_ref.bupf5_j_1 rosinit>| to initialize ROS. By
% default, |rosinit| creates a ROS master in MATLAB and starts a
% "global node" that is connected to the master. The "global node" is
% automatically used by other ROS functions. 
%%
rosinit
%%
% * Use |<docid:robotics_ref.bupf5_j_4 rosnode> list| to see all nodes in the
% ROS network. Note that the only available node is the global
% node created by |rosinit|.
%%
rosnode list
%%
% * Use |exampleHelperROSCreateSampleNetwork| to populate the ROS network
% with three additional nodes and sample publishers and subscribers.
%%
exampleHelperROSCreateSampleNetwork
%%
% * Use |rosnode list| again, and observe that there are three new nodes (|node_1|, |node_2| and |node_3|).
%%
rosnode list
%%
% A visual representation of the current state of the ROS network is shown below. 
% Use it as a reference when you explore this sample network in the remainder 
% of the example.
%
% The MATLAB global node is disconnected since it currently does not have any publishers, 
% subscribers or services.
%
% <<sample_ros_network.png>>


%% Topics
% * Use |<docid:robotics_ref.bupf5_j_14 rostopic> list| to see available topics in the ROS network.
% Observe that there are three active topics: |/pose|, |/rosout|, and
% |/scan|. |rosout| is a default logging topic that is always present in the
% ROS network. The other two topics were created as part of the sample
% network.
%%
rostopic list
%%
% * Use |<docid:robotics_ref.bupf5_j_14 rostopic> info| to get specific
% information about a specific topic. The command below shows that
% |/node_1| publishes (sends messages to) the |/pose| topic, and |/node_2|
% subscribes (receives messages from) that topic (see
% <docid:robotics_examples.example-ROSPublishAndSubscribeExample> for more
% information).
%%
rostopic info /pose
%%
% * Use |<docid:robotics_ref.bupf5_j_4 rosnode> info| to get information about a specific node. 
% The command below show that |node_1| publishes to |/pose| and |/rosout|
% topics, and subscribes to the |/scan| topic.
%%
rosnode info /node_1


%% Services
% ROS Services provide a mechanism for "procedure calls" across the ROS
% network. A _service client_ sends a request message to a _service server_,
% which processes the information in the request and returns with a response
% message (see <docid:robotics_examples.example-ROSServicesExample>).
%
% * Use |<docid:robotics_ref.bupf5_j_7 rosservice> list| to see 
% all available service servers in the ROS network. The command below shows
% that two services (|/add| and |/reply|) are available.
%%
rosservice list
%%
% * Use |<docid:robotics_ref.bupf5_j_7 rosservice> info| to get information
% about a specific service.
%%
rosservice info /add


%% Messages
% Publishers, subscribers, and services use ROS messages to exchange
% information. Each ROS message has an associated _message type_ that
% defines the datatypes and layout of information in that message
% (See <docid:robotics_examples.example-ROSMessagesExample>).
%
% * Use |<docid:robotics_ref.bupf5_j_14 rostopic> type| to see the message
% type used by a topic. The command below shows that the |/pose| topic uses 
% messages of type |geometry_msgs/Twist|.
%%
rostopic type /pose
%%
% * Use |<docid:robotics_ref.bupf5_j_3 rosmsg> show| to view the properties
% of a message type. The |geometry_msgs/Twist| message type has two
% properties, |Linear| and |Angular|. Each property is a message of
% type |geometry_msgs/Vector3|, which in turn has three properties of type
% |double|.
%%
rosmsg show geometry_msgs/Twist
%%
rosmsg show geometry_msgs/Vector3
%%
% * Use |<docid:robotics_ref.bupf5_j_3 rosmsg> list| to see the full list
% of message types available in MATLAB.
%%
rosmsg list


%% Shut Down ROS Network
% * Use |exampleHelperROSShutDownSampleNetwork| to remove the sample nodes,
% publishers, and subscribers from the ROS network. This command is only
% needed if the sample network was created earlier using
% |exampleHelperROSStartSampleNetwork|.
%% 
exampleHelperROSShutDownSampleNetwork
%%
% * Use |<docid:robotics_ref.bupf5_j_8 rosshutdown>| to shut down the ROS
% network in MATLAB. This shuts down the ROS master that was started by
% |rosinit| and deletes the global node. It is recommended to use
% |rosshutdown| once you are done working with the ROS network.
%%
rosshutdown


%% Next Steps
% * <docid:robotics_examples.example-ROSNetworkingExample>
%%
displayEndOfDemoMessage(mfilename)
