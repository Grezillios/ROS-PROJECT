function varargout = turtlebot_teleop(varargin)
% TURTLEBOT_TELEOP MATLAB code for turtlebot_teleop.fig
%      TURTLEBOT_TELEOP, by itself, creates a new TURTLEBOT_TELEOP or raises the existing
%      singleton*.
%
%      H = TURTLEBOT_TELEOP returns the handle to a new TURTLEBOT_TELEOP or the handle to
%      the existing singleton*.
%
%      TURTLEBOT_TELEOP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TURTLEBOT_TELEOP.M with the given input arguments.
%
%      TURTLEBOT_TELEOP('Property','Value',...) creates a new TURTLEBOT_TELEOP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before turtlebot_teleop_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to turtlebot_teleop_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help turtlebot_teleop

% Last Modified by GUIDE v2.5 14-May-2016 13:21:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @turtlebot_teleop_OpeningFcn, ...
                   'gui_OutputFcn',  @turtlebot_teleop_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before turtlebot_teleop is made visible.
function turtlebot_teleop_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to turtlebot_teleop (see VARARGIN)
imm = imread('teleop.png');
axes(handles.axes1), imshow(imm);
% Choose default command line output for turtlebot_teleop
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes turtlebot_teleop wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = turtlebot_teleop_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ipaddress
ipaddress = inputdlg('Enter the IP Address :');
ipaddress = cell2mat(ipaddress); 
msgbox('IP entered Sucessfully')

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ipaddress
rosinit(ipaddress)
msgbox('Initialise ROS Sucessfully')

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Subscribe to the odometry and laser scan topics and make sure that you can
% receive messages on these topics
%%
global odom1 laserSub1 
handles.odomSub = rossubscriber('/odom', 'BufferSize', 25);

odom1 = handles.odomSub;
receive(handles.odomSub,3);
handles.laserSub = rossubscriber('/scan', 'BufferSize', 5);
laserSub1 = handles.laserSub ;
receive(handles.laserSub,3);
msgbox('Subscribers Initialise Sucessfully')
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%  Create a publisher for controlling the robot velocity
global velPub1 
handles.velPub = rospublisher('/mobile_base/commands/velocity');
velPub1 = handles.velPub;
msgbox('Publishers Initialise Sucessfully')
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dos('C:\Program Files (x86)\VMware\VMware Player\vmplayer')
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Control the Robot
% Run the |exampleHelperTurtleBotKeyboardControl| function, which allows you to control the TurtleBot with
% the keyboard.
%%
 exampleHelperTurtleBotKeyboardControl(handles);
%turlebot_teleop1
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
rosshutdown
msgbox('ROS shutdown Sucessfully')
