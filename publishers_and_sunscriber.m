%% Exchange Data with ROS Publishers and Subscribers

%% Introduction
% The primary mechanism for ROS nodes to exchange data is to send and receive 
% _messages_. Messages are transmitted on a _topic_ and each topic has a unique
% name in the ROS network. If a node wants to share information, it will
% use a _publisher_ to send data to a topic. A node that wants to receive that
% information will use a _subscriber_ to that same topic. Besides its unique name, 
% each topic also has a _message type_, which determines the types of messages 
% that are allowed to be transmitted. 
%
% This publisher/subscriber communication has the following characteristics:
%
% * Topics are used for many-to-many communication. Many publishers can
% send messages to the same topic and many subscribers can receive them.
% * Publisher and subscribers are decoupled through topics and 
% can be created and destroyed in any order. A message can be published to 
% a topic even if there are no active subscribers.
%
% The concept of topics, publishers, and subscribers is illustrated in the
% following image:
%
% <<publish_subscribe_concept.png>>
%
% This example shows how to publish and subscribe to topics in a ROS
% network. It also shows how to:
%
% * Wait until a new message is received, or
% * Use callbacks to process new messages in the background
%
% Prerequisites: <docid:robotics_examples.example-ROSGettingStartedExample>, 
% <docid:robotics_examples.example-ROSNetworkingExample>

% Copyright 2014-2015 The MathWorks, Inc.


%% Subscribe and Wait for Messages
% * Start the ROS master in MATLAB(R), and create a sample ROS network with
% several publishers and subscribers.
%%
rosinit
exampleHelperROSCreateSampleNetwork
%%
% * Use |<docid:robotics_ref.bupf5_j_14 rostopic> list| to see which topics
% are available. Assume you want to subscribe to the |/scan| topic.
%%
rostopic list
%%
% * Use |rostopic info| to check if any nodes are publishing to the |/scan|
% topic. The command below shows that |node_3| is publishing to it.
%%
rostopic info /scan
%%
% * Use |<docid:robotics_ref.bupf5_j_9 rossubscriber>| to subscribe to the
% |/scan| topic. If the topic already exists in the ROS network (as is the
% case here), |rossubscriber| detects its message type automatically, so
% you do not need to specify it.
%%
laser = rossubscriber('/scan')
%%
% * Use |<docid:robotics_ref.buqbyro receive>| to wait for a new message
% (the second argument is a time-out in seconds). The output |scandata|
% contains the received message data.
%%
scandata = receive(laser,10)
%%
% * Some message types have convenient visualizers associated with them. 
% For the LaserScan message, |<docid:robotics_ref.buqbjtl plot>| plots the scan data. The |MaximumRange|
% name-value pair specifies the maximum plot range.
%%
figure
plot(scandata,'MaximumRange',7)


%% Subscribe using Callback Functions
% Instead of using |<docid:robotics_ref.buqbyro receive>| to get data,
% you can specify a function to be called when a new message is received.
% This allows other MATLAB code to execute while the subscriber is waiting
% for new messages. Callbacks are essential if you want to use
% multiple subscribers.
%
% * Subscribe to the |/pose| topic, using the callback function
% |exampleHelperROSPoseCallback|. One way of sharing data between your main
% workspace and the callback function is to use global variables. Also define
% two global variables |pos| and |orient|.
%%
robotpose = rossubscriber('/pose',@exampleHelperROSPoseCallback)
global pos
global orient
%%
% * The global variables |pos| and |orient| are assigned in the
%  |exampleHelperROSPoseCallback| function when new message data is
%  received on the |/pose| topic.
% * Wait for a few seconds to make sure that the subscriber can receive
% messages. The most current position and orientation data will always be
% stored in the |pos| and |orient| variables.
%%
pause(2) 
pos
orient
%%
% If you type in |pos| and |orient| a few times in the command line you
% can see that the values are continuously updated.
%
% * Stop the pose subscriber by clearing the subscriber variable
%%
clear robotpose
%%
% _Note_: There are other ways to extract information from callback
% functions besides using globals. For example, you can pass a handle object
% as additional argument to the callback function. See the <docid:creating_plots.bt_h1z8
% Callback Definition> documentation for more information about defining
% callback functions.


%% Publish Messages
%
% * Create a publisher that sends ROS string messages to the |/chatter|
% topic (see <docid:robotics_examples.example-ROSMessagesExample>).
%%
chatterpub = rospublisher('/chatter', rostype.std_msgs_String)
pause(2) % Wait to ensure publisher is registered
%%
% * Create and populate a ROS message to send to the |/chatter| topic.
%%
chattermsg = rosmessage(chatterpub);
chattermsg.Data = 'hello world'
%%
% * Use |rostopic list| to verify that the |/chatter| topic is available
% in the ROS network.
%%
rostopic list
%%
% * Define a subscriber for the |/chatter| topic. 
% |exampleHelperROSChatterCallback| is called when a new message is
% received, and displays the string content in the message.
%%
chattersub = rossubscriber('/chatter', @exampleHelperROSChatterCallback)
%%
% * Publish a message to the |/chatter| topic. Observe that the string is
% displayed by the subscriber callback.
%%
send(chatterpub,chattermsg)
pause(2)
%%
% The |exampleHelperROSChatterCallback|
% function was called as soon as you published the string message.


%% Shut Down ROS Network
% * Remove the sample nodes, publishers, and subscribers from the ROS
% network. Also clear the global variables |pos| and |orient|
%% 
exampleHelperROSShutDownSampleNetwork
clear global pos orient 
%%
% * Shut down the ROS master and delete the global node.
%%
rosshutdown


%% Next Steps
% * To learn more about how ROS messages are handled in MATLAB, see
% <docid:robotics_examples.example-ROSMessagesExample> and
% <docid:robotics_examples.example-ROSSpecializedMessagesExample>
% * To explore ROS services, refer to <docid:robotics_examples.example-ROSServicesExample>.
%%
displayEndOfDemoMessage(mfilename)
