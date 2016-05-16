%% Connect to a ROS Network
%% Introduction
%
% A ROS network consists of a single _ROS master_ and multiple _ROS nodes_.
% The ROS master facilitates the communication in the ROS network by
% keeping track of all active ROS entities. Every node needs to register
% with the ROS master to be able to communicate with the rest of the
% network.
% MATLAB(R) can start the ROS master or the master
% can be launched outside of MATLAB (for example, on a different computer).
% All ROS nodes register with the master and declare the network
% address where they can be reached.
%
% When you work with ROS, you will typically follow these steps:
%
% * _Connect to a ROS network_. To connect to a ROS network, you can 
% create the ROS master in MATLAB or connect to an existing ROS master. In both cases,
% MATLAB will also create and register its own ROS node (called the
% MATLAB "global node") with the master. The |<docid:robotics_ref.bupf5_j_1
% rosinit>| function manages this process.
% * _Exchange Data_. Once connected, MATLAB exchanges data with other
% ROS nodes through publishers, subscribers, and services. 
% * _Disconnect from the ROS network_. Calling the 
% |<docid:robotics_ref.bupf5_j_8 rosshutdown>| function disconnects
% MATLAB from the ROS network. 
%
% This example shows you how to:
%
% * Create a ROS master in MATLAB
% * Connect to an external ROS master
%
% Prerequisites: <docid:robotics_examples.example-ROSGettingStartedExample>

% Copyright 2014-2015 The MathWorks, Inc.


%% Create a ROS Master in MATLAB
% * To create the ROS master in MATLAB, call |<docid:robotics_ref.bupf5_j_1 rosinit>|
% without any arguments. This will also create the "global node", which MATLAB will
% use to communicate with other nodes in the ROS network.
%%
rosinit
%%
% * ROS nodes that are external to MATLAB can now join the ROS network. They  
% can connect to the ROS master in MATLAB by using the hostname or IP address 
% of the MATLAB host computer.
% * You can shut down the ROS master and the global node by calling
% |<docid:robotics_ref.bupf5_j_8 rosshutdown>|.
%%
rosshutdown


%% Connect to an External ROS Master
% You can also use the |<docid:robotics_ref.bupf5_j_1 rosinit>| command to connect 
% to an external ROS master (for example running on a robot or a virtual machine). 
% You can specify the address of the master in two ways: by an IP address or 
% by a host name of the computer that runs the master.
%
% After each call to |<docid:robotics_ref.bupf5_j_1 rosinit>|, you 
% have to call |<docid:robotics_ref.bupf5_j_8 rosshutdown>| before calling
% |<docid:robotics_ref.bupf5_j_1 rosinit>| with a different syntax. For brevity, 
% these calls to |<docid:robotics_ref.bupf5_j_8 rosshutdown>| are omitted in the
% following sections.
%
% * In this example, use |master_host| as an example host name and
% |192.168.1.1| as an example IP address of the external ROS master.
% Adjust these addresses depending on where the external master resides in
% your network. Note that the following commands will fail if no master is
% found at the specified addresses.
%
%%
rosinit('192.168.1.1')
rosinit('master_host')
%%
% * Both calls to |<docid:robotics_ref.bupf5_j_1 rosinit>| assume that the master 
% will accept network connections on port 11311, with is the standard ROS master
% port.
% * If the master is running on a different port, you can specify it as a
% second argument. To connect to a ROS master running on host name |master_host|
% and port 12000, use the following command:
%%
rosinit('master_host', 12000)
%%
% * If you know the entire URI (Uniform Resource Identifier) of the master, 
% you can create the global node and connect to this master using the following syntax:
%%
rosinit('http://192.168.1.1:12000')


%% Node Host Specification
% In some cases, your computer may be connected to multiple networks and have 
% multiple IP addresses. See the following illustration as an
% example.
%
% <<node_host.png>>
%
% The computer on the bottom left runs MATLAB and is connected to two
% different networks. In one subnet, its IP address is |73.195.120.50| and
% in the other, its IP is |192.168.1.100|.
% This computer wants to connect to the ROS master on the TurtleBot(R) 
% computer at IP address |192.168.1.1|. As part of the registration with
% the master, the MATLAB global node has to specify the IP address 
% or host name where other ROS nodes can reach it. All the nodes on the TurtleBot 
% will use this address to send data to the global node in MATLAB.
%
% When |<docid:robotics_ref.bupf5_j_1 rosinit>| is invoked with the
% master's IP address, it will try to detect the network interface used
% to contact the master and use that as the IP address for the global node.
%
% If this automatic detection fails, you can explicitly specify the IP address or host
% name by using the |NodeHost| name-value pair in the 
% |<docid:robotics_ref.bupf5_j_1 rosinit>| call.
% All prior methods for calling |<docid:robotics_ref.bupf5_j_1 rosinit>| are still permissible with the
% addition of the |NodeHost| name-value pair. 
%
% * For the following commands,
% assume that you want to advertise your computer's IP address to the ROS 
% network as |192.168.1.100|.
%%
rosinit('192.168.1.1', 'NodeHost', '192.168.1.100')
rosinit('http://192.168.1.1:11311', 'NodeHost', '192.168.1.100')
rosinit('master_host', 'NodeHost', '192.168.1.100')
%% 
% * Once a node is registered in the ROS network, you can see the address
% that it advertises by using the command |<docid:robotics_ref.bupf5_j_4
% rosnode> info NODE|. NODE is the name of a node in the ROS network. You can 
% see the names of all registered nodes by calling |<docid:robotics_ref.bupf5_j_4
% rosnode> list|.


%% ROS Environment Variables
% In advanced use cases, you might want to specify the address of a ROS
% master and your advertised node address through standard ROS environment variables.
% The calling syntaxes that were explained in the previous sections should be 
% sufficient for the majority of your use cases.
%
% * If no arguments are provided to |<docid:robotics_ref.bupf5_j_1
% rosinit>|, the function will also check the values of
% standard ROS environment variables.
% These variables are |ROS_MASTER_URI|,
% |ROS_HOSTNAME|, and |ROS_IP|. You can see their current values using
% the |<docid:matlab_ref.f72-1120523 getenv>| command:
%%
getenv('ROS_MASTER_URI')
getenv('ROS_HOSTNAME')
getenv('ROS_IP')
%%
% * You can set these variables using the |<docid:matlab_ref.f76-1101530 setenv>| command. After setting
% the environment variables, call |<docid:robotics_ref.bupf5_j_1 rosinit>| with no arguments. 
% The address of the ROS master is specified by |ROS_MASTER_URI| and the
% global node's advertised address is given by |ROS_IP| or |ROS_HOSTNAME|.
% _If you specify additional arguments to |rosinit|, they will override the values
% in the environment variables._
%%
setenv('ROS_MASTER_URI','http://192.168.1.1:11311')
setenv('ROS_IP','192.168.1.100')
rosinit
%%
% * You do not have to set both |ROS_HOSTNAME| and |ROS_IP|. If both
% are set, |ROS_HOSTNAME| takes precedence.


%% Verify Connection
% For your ROS connection to work correctly, you must ensure
% that all nodes can communicate with the master and with each other. The
% individual nodes must communicate with the master to register
% subscribers, publishers, and services. They must also be able to
% communicate with one another to send and receive data. 
%
% Because the communication works in this way, it is possible to be able to send
% data and unable to receive it (or vice versa) if your ROS network is not set up
% correctly.
%
% Here is a diagram of the communication structure in a ROS network. There is 
% a single ROS master and two different nodes that register themselves with the
% master. Each node will contact the master to find the advertised address
% of the other node in the ROS network. Once each node knows the other node's
% address, a data exchange can be established without involvement of the
% master.
%
% <<node_communication.png>>


%% Next Steps
% * See <docid:robotics_examples.example-ROSPublishAndSubscribeExample> to explore
% publishers and subscribers in ROS.
%%
displayEndOfDemoMessage(mfilename)