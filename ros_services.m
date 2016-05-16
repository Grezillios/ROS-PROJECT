%% Call and Provide ROS Services
%% Introduction
% ROS supports two main communication mechanisms: topics and services.
% Topics have publishers and subscribers and are used for sending and
% receiving messages (see <docid:robotics_examples.example-ROSPublishAndSubscribeExample>
% _Services_, on the other hand, implement a tighter coupling by allowing request-response 
% communication. A _service client_ sends a request message to a _service server_ 
% and waits for a response. The server will use the data in the request to
% construct a response message and sends it back to the client. Each
% service has a type that determines the structure of the request and
% response messages. Services also have a name that is unique in the ROS network.
%
% This service communication has the following characteristics:
%
% * A service request (or service call) is used for one-to-one
% communication. A single node will initiate the request and only one node
% will receive the request and send back a response.
% * A service client and a service server are tightly coupled when a
% service call is executed. The server has to exist at the time of
% the service call and once the request is sent, the client will block until a
% response is received.
%
% The concept of services is illustrated in the following image:
%
% <<services_concept.png>>
%
% This example shows you how to set up service servers to advertise a
% service to the ROS network. In addition, you will learn how to use
% service clients to call the server and receive a response.
%
% Prerequisites: <docid:robotics_examples.example-ROSGettingStartedExample>, 
% <docid:robotics_examples.example-ROSNetworkingExample>, 
% <docid:robotics_examples.example-ROSPublishAndSubscribeExample>

% Copyright 2014-2015 The MathWorks, Inc.


%% Create Service Server
% * Before examining service concepts, start the
% ROS master in MATLAB(R) and the sample ROS network. |exampleHelperROSCreateSampleNetwork| 
% will create some service servers to simulate a realistic ROS network.
%%
rosinit
exampleHelperROSCreateSampleNetwork
%%
% * Before creating a service server, see what service types are available
% for you to use.
%%
rostype.getServiceList
%%
% * Suppose you want to make a simple service server that displays _"A service 
% client is calling"_ when you call the service. Create the service
% using the |<docid:robotics_ref.bupf5_j_11 rossvcserver>| command. Specify the service
% name and the service message type. Also define the callback function
% as |exampleHelperROSEmptyCallback|. Callback functions for service servers 
% have a very specific signature. For details, see the
% documentation of |<docid:robotics_ref.bupf5_j_11 rossvcserver>|.
%%
testserver = rossvcserver('/test', rostype.std_srvs_Empty, @exampleHelperROSEmptyCallback)
%%
% * You can see your new service, |/test|, when you list all services 
% in the ROS network.
%%
rosservice list
%%
% * You can get more information about your service using
% |<docid:robotics_ref.bupf5_j_7 rosservice> info|. The global node is
% listed as node where the service server is reachable and you also
% see its |std_srvs/Empty| service type. 
%%
rosservice info /test


%% Create Service Client
% Use service clients to request information from a ROS service server. To
% create a client, use |<docid:robotics_ref.bupf5_j_10 rossvcclient>| with
% the service name as the argument.
%
% * Create a service client for the |/test| service that we just created.
%%
testclient = rossvcclient('/test')
%%
% * Create an empty request message for the service. 
% Use the |<docid:robotics_ref.bupf5_j_2 rosmessage>| function and pass the
% client as the first argument. This will create a service request function
% that has the message type that is specified by the service.
%%
testreq = rosmessage(testclient)
%%
% * When you want to get a response from the server, use the |<docid:robotics_ref.buqbgqj call>|
% function, which calls the service server and returns a response. 
% The service server you created before will return an empty response. In
% addition, it will call the |exampleHelperROSEmptyCallback| function and displays 
% the string _"A service client is calling"_. You can also define a |Timeout| 
% parameter, which indicates how long the client should wait for a
% response.
%%
testresp = call(testclient,testreq,'Timeout',3);
%%
% You will see the string that is printed in the callback function.


%% Create a Service for Adding Two Numbers
% Up to now, the service server has not done any meaningful work, but you  
% can use services for computations and data manipulation. Create a service 
% that adds two integers.
%
% * There is an existing service type, |roscpp_tutorials/TwoInts|, that we
% can use for this task. You can inspect the structure of the request and
% response messages by calling |rosmsg show|. The request contains two
% integers, |A| and |B|, and the response contains their addition in |Sum|.
%%
rosmsg show roscpp_tutorials/TwoIntsRequest
%%
rosmsg show roscpp_tutorials/TwoIntsResponse

%%
% * Create the service server with this message type and a callback function 
% that calculates the addition. For your convenience, the |exampleHelperROSSumCallback| 
% function already implements this calculation. Specify the function as a
% callback.
%%
sumserver = rossvcserver('/sum', rostype.roscpp_tutorials_TwoInts, @exampleHelperROSSumCallback)

%%
% * To call the service server, you have to create a service client. Note
% that this client can be created anywhere in the ROS network. For the
% purposes of this example, we will create a client for the |/sum| service
% in MATLAB.
%%
sumclient = rossvcclient('/sum')

%% 
% * Create the request message. You can define the two integers, |A|
% and |B|, which are added together when you use the |<docid:robotics_ref.buqbgqj call>| command.
%%
sumreq = rosmessage(sumclient);
sumreq.A = 2;
sumreq.B = 1
%%
% * The expectation is that the sum of these two numbers will be 3. To call the service, use the
% following command. The service response message will contain a |Sum|
% property, which stores the addition of |A| and |B|.
%%
sumresp = call(sumclient,sumreq,'Timeout',3)


%% Shut Down ROS Network
% * Remove the sample nodes and service servers from the ROS network.
%% 
exampleHelperROSShutDownSampleNetwork
%%
% * Shut down the ROS master and delete the global node.
%%
rosshutdown


%% Next Steps
% * Refer to <docid:robotics_examples.example-ROSMessagesExample> to explore how ROS messages are represented in MATLAB.
%%
displayEndOfDemoMessage(mfilename)
