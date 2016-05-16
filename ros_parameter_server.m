%% Access the ROS Parameter Server
%% Introduction
%
% This example explores how to add and retrieve parameters on the ROS 
% parameter server. The parameter server usually runs on the same device
% that launches the ROS master.
% The parameters are accessible globally over the
% ROS network and can be used to store static data such as 
% configuration parameters. Supported data types include strings, integers, 
% doubles, logicals and cell arrays. 
%
% Prerequisites: <docid:robotics_examples.example-ROSGettingStartedExample>, 
% <docid:robotics_examples.example-ROSNetworkingExample>

% Copyright 2014-2015 The MathWorks, Inc.


%% Create Parameter Tree
% * Start the ROS master and parameter server in MATLAB(R).
%%
rosinit
%%
% * Create a parameter tree object to interact with the parameter server.
% The parameter tree allows you to interact with the parameter server and
% provides functions such as |<docid:robotics_ref.buqbz_6-1 set>|, |<docid:robotics_ref.buqbhwv get>|, |<docid:robotics_ref.buqbhap del>|, |<docid:robotics_ref.buqbjb5 has>| and |<docid:robotics_ref.buqbz2o-1 search>|.
% Since we started a new parameter server in this example, no parameters
% are currently stored there.
%%
ptree = rosparam


%% Add New Parameters 
% To set a parameter for the robot IP address, use the parameter name |ROBOT_IP|.
%
% * Check if a parameter with the same name already exists. Use the |<docid:robotics_ref.buqbjb5 has>| function.
%%
has(ptree,'ROBOT_IP')
%%
% |<docid:robotics_ref.buqbjb5 has>| returns 0 (false) as the output. This means
% that currently the |ROBOT_IP| name could not be found on the parameter server.
%
% * Add some parameters indicating a robot's IP address to the parameter
% server. Use the |<docid:robotics_ref.buqbz_6-1 set>| function for this purpose.
%%
set(ptree,'ROBOT_IP','192.168.1.1');
set(ptree, '/myrobot/ROBOT_IP','192.168.1.100');
%%
% The |ROBOT_IP| parameters are now available to all nodes connected
% to this ROS master. You can specify parameters within a namespace.
% For example, the |/myrobot/ROBOT_IP| parameter is within the |/myrobot|
% namespace in this example.
%
% * Set more parameters with different data types.
%%
set(ptree,'MAX_SPEED',1.5);
%%
% * Use a cell array as an input to the |set| function.
% Set a parameter that has the goal coordinates {x, y, z} for the robot.
%%
set(ptree,'goal',{5.0,2.0,0.0});
%%
% * Set additional parameters to populate the parameter server.
%%
set(ptree, '/myrobot/ROBOT_NAME','TURTLE');
set(ptree, '/myrobot/MAX_SPEED',1.5);
set(ptree, '/newrobot/ROBOT_NAME','NEW_TURTLE');



%% Get Parameter Values
% * Suppose you want to get the robot's IP address from the |ROBOT_IP| parameter
% because you want to use this IP address to connect to this robot. There
% are two parameters with |ROBOT_IP| name in it, but you only want the IP
% address of |myrobot|. You can retrieve this parameter value using 
% the |<docid:robotics_ref.buqbhwv get>| function:
%%
robotIP = get(ptree, '/myrobot/ROBOT_IP')


%% Get List of All Parameters
% * To get the entire list of parameters stored on the
% parameter server, inspect the |AvailableParameters|
% property. The list will contain all the parameters that you added in
% previous sections.
%%
plist = ptree.AvailableParameters


%% Modify Existing Parameters
% You can also use the |<docid:robotics_ref.buqbz_6-1 set>| function to change 
% parameter values. Note that the modification of a parameter is
% irreversible, since the parameter server will simply overwrite the
% parameter with the new value. You can verify if a parameter already
% exists by using the |<docid:robotics_ref.buqbjb5 has>| function.
%
% * Modify the MAX_SPEED parameter:
%%
set(ptree, 'MAX_SPEED', 1.0);
%%
% * The modified value can have a different data type from a previously 
% assigned value. For example, the value of the MAX_SPEED parameter is currently of 
% type double. Set a string value for the MAX_SPEED parameter:
%%
set(ptree, 'MAX_SPEED', 'none');


%% Delete Parameters
% You can delete the parameter from the parameter server using the |<docid:robotics_ref.buqbhap del>| function. 
%
% * Delete the |goal| parameter.
%%
del(ptree, 'goal');
%%
% * Check if the |goal| parameter has been deleted.
% Use the |<docid:robotics_ref.buqbjb5 has>| function.
%%
has(ptree, 'goal')
%%
% The output is 0 (false), which means the parameter
% was deleted from the parameter server.


%% Search Parameters
% * Search for all the parameters that contain |'myrobot'| using the
% |<docid:robotics_ref.buqbz2o-1 search>| command:
%%
results = search(ptree, 'myrobot')


%% Shut Down ROS Network
% * Shut down the ROS master and delete the global node.
%%
rosshutdown


%% Next Steps
% * For application examples, see the <docid:robotics_examples.example-GettingStartedWithGazeboExample>
% or <docid:robotics_examples.example-GettingStartedWithRealTurtleBotExample> examples.
%%
displayEndOfDemoMessage(mfilename)