classdef mobileRobotController < studentCompetitionApp
    %% mobileRobotController Is a simple class to display point clouds, and drive a mobile robot.
    % OBJ = mobileRobotController is a utility for displaying the point
    % cloud data from a a depth sensor, and provide twist messages over ROS.
    % Twist messages are expected to be of type 'geometry_msgs/Twist'. The
    % point cloud messages are expected to be of type
    % 'sensor_msgs/PointCloud2'.
    %
    % OBJ = mobileRobotController implements a kinectViewer object, and a
    % closedLoopTurtle object. The kinectViewer object handles gathering
    % and displaying pointcloud
    %
    % mobileRobotController Properties:
    %   rosIP - IP Address of a compatible ROS Master.
    %   mobileRobot - Instance of the closedLoopTurtle class.
    %   kinect - Instance of the kinectViewer class.
    %
    % mobileRobotController Methods:
    %   mobileRobotController - Builds an instance of the controller class.
    %
    % Copyright 2015 The MathWorks Inc.
    % Author: Rebecca Linton
    
    %% mobileRobotController public interface.
    properties(SetAccess = protected, GetAccess = public)
        
        rosIP = '192.168.242.128'; % Default IP address of a compatible ROS Master.
        mobileRobot % closedLoopTurtle object to handle robot velocity commands.
        kinect % kinectViewer object to handle the display of pointCloud2 data.
        
    end
    
    methods
        
        function app = mobileRobotController
            % Builds an instance of the mobileRobotController class.
            % App construction happens in the studentCompetitionApp
            % superclass constructor, and is implemented in the
            % app.mainCustomization method of this class.
            
            % Get the remote URLs used by studentCompetitionApp functions.
            app.fileExchangeUrl = mobileRobotController.getFileExchangeUrl();
            app.updateDownloadUrl = mobileRobotController.getUpdateDownloadUrl();
            
            % Set the figure and data to visible
            app.hFigure.Visible = 'on';
        end
        
    end
    
    %% Private class data.
    properties(Access = protected, Hidden)
        
        % Main display handles:
        hFigure             % Main window handle.
        hVisionAxis         % Axis handle for the activated vision sensor.
        popView             % uicontrol popupmenu object
        hButtonPanel        % Main button panel handle.
        hControlButtonPanel % Button panel for robot control buttons.
        
        % Handles to robot control ux objects:
        hForward            % Button handle for robot forward command.
        hReverse            % Button handle for robot reverse command.
        hClockwise          % Button handle for clockwise turn command.
        hCounterClockwise   % Button handle for counter-clockwise turn command.
        hStart              % Button handle for controller start action.
        hReset              % Button handle for controller stop action.
        upArrow = [];       % Matrix to hold CData for forward.
        downArrow = [];     % Matrix to hold CData for reverse.
        ccwArrow = [];      % Matrix to hold CData for rotations.
        
        % Keep it tidy
        cleanup
        
        % Simulator mangement properties.
        ResetSimClient;     % Not used.
        PausePhyClient;     % Not used.
        ResumePhyClient;    % Not used.
        
        % ROS running flag.
        Running = 'off';
        
    end
    
    %% Methods who's access must be public, but are not a part of the public user interface.
    methods(Access = public, Hidden)
        
        % Helper methods for closing the app.
        function deleteRobot(app)
            if isvalid(app) && isvalid(app.mobileRobot)
                delete(app.mobileRobot);
            end
        end
        
        function deleteKinect(app)
            if isvalid(app) && isvalid(app.kinect)
                delete(app.kinect);
            end
        end
        
        function deleteApp(app, fig)
            % DELETEAPP Main function to handle cleanup of the app.
            
            % Check if the destructor is called by the window or button
            % callback.
            if nargin > 1
                delete(fig);
            else
                delete(app.hFigure);
            end
            
            % Iterate through cleanup objects and call destructors.
            cellfun(@(field)delete(app.cleanup.(field)), ...
                fieldnames(app.cleanup));
        end
        
    end
    
    %% Overloaded methods from the studentCompetitionApp superclass. Methods must be public, but are not part of the pbulic user interface.
    methods(Access = public, Hidden)
        
        function mainCustomization(app)
            % MAINCUSTOMIZATION Handles the Main UX layout.
            
            % Get the screensize of the monitor that MATLAB is currently
            % displayed on.
            screenSize = get(groot, 'ScreenSize');
            
            % Generate the normalized app height relative to the screen.
            appHeight = ((9/16)*(0.5*screenSize(3)))/screenSize(4);
            
            % Set main figure window properties.
            %   Handle visibility is set to off to ensure the app does not
            %   interview with other MATLAB figures. Window is initially
            %   set to Visible, off to ensure the app is fully built before
            %   being displayed to the user.
            set(app.main.figure, 'MenuBar', 'none', ...
                'NumberTitle', 'off',...
                'Units', 'normalized',...
                'CloseRequestFcn', @(fig,~)app.deleteApp(fig), ...
                'Position', [0.1, 0.1, 0.5, appHeight], ...
                'Name', 'mobileRobotController', ...
                'Visible', 'off', ...
                'HandleVisibility', 'off', ...
                'HitTest', 'off', ...
                'KeyPressFcn', @(x,y)app.keyPadCallback(y));
            
            % Delete the title text from the studentCompetitionApp.
            delete(app.main.text.title);
            
            % Create the closedLoopTurtle object. Creating the object here
            % ensures that all objects are built before the window is
            % displayed.
            app.mobileRobot = closedLoopTurtle;
            app.cleanup.robot = onCleanup(@app.deleteRobot);
            
            % Create main app window.
            app.hFigure = app.main.figure;
            
            % Build the panel for vizualizing robot data.
            app.buildVisionPanel();
            
            % Build the button panels
            app.buildButtonPanel();
            
            % Build the menu bar.
            app.buildMenu();
        end
        
        function resizeMainWindow(app, ~, ~)
            % studentCompetitionApp superclass implements a resize function
            % while this app relies on normalized units. This function must
            % be overloaded to insure that the button CData properties are
            % correctly set.
            app.updateButtonImage(app.hForward);
            app.updateButtonImage(app.hReverse);
            app.updateButtonImage(app.hClockwise);
            app.updateButtonImage(app.hCounterClockwise);
        end
                
        function searchTag = getSearchTag(~)
            % This function returns the search tag that will be used by the
            % goToMATLABCentral function of the studentCompetitionApp
            % superclass. The tag specified will be used to filter content.
            searchTag = 'Robotics';
        end
               
    end
    
    %% ROS Configuration helper methods.
    methods(Access = private)
        
        function configureROS(app, ~, ~ )
            % CONFIGUREROS Handles the ROS configuration window.
            
            % Get ROS Master URI details.
            response = inputdlg({'ROS Master IP','ROS Master Port',...
                'MATLAB Global Node Name', 'Point Cloud Message Name', ...
                'Twist Message Name', 'Odom Message Name'},...
                'ROS Master URI',[1 16; 1 20; 1 26; 1 26; 1 26; 1 26], ...
                {app.rosIP, '11311', ...
                ['MATLAB_GLOBAL', num2str(randi(100,1))], ...
                '/camera/depth/points', ...
                '/mobile_base/commands/velocity', ...
                '/odom'});
            
            % TODO Do something with response when the cancel button is pressed
            % and it returns empty
            
            if strcmp(app.Running, 'on')
                app.mobileRobot.stopCtrl();
                app.cleanup.ros = [];
                app.Running = 'off';
            end
            
            % Start the MATLAB Global Node. Currently doesn't catch errors.
            rosinit(['http://', response{1}, ':', response{2}], 'NodeName', response{3});
            
            app.kinect.PointCloudTopicName = response{4};
            app.mobileRobot.velCmdMsgName = response{5};
            app.mobileRobot.poseMsgName = response{6};
            
            app.cleanup.ros = onCleanup(@rosshutdown);
            
            % Setup simulator services
            %
            % TODO protect these with a try/catch construct for running
            % only on live robot. Update VM and test.
            %             app.ResetSimClient = rossvcclient('gazebo/reset_simulation');
            %             app.cleanup.simReset = onCleanup(@rosshutdown);
            %             app.PausePhyClient = rossvcclient('gazebo/pause_physics');
            %             app.cleanup.physPause = onCleanup(@rosshutdown);
            %             app.ResumePhyClient = rossvcclient('gazebo/unpause_physics');
            %             app.cleanup.physStart = onCleanup(@rosshutdown);
            
            % Start the kinect viewer.
            app.kinect.startViewer();
            
            app.Running = 'on';
        end
        
        function resetSim(app)
            % RESETSIM Calls service to reset simulation.
            serviceMsg = rosmessage(app.ResetSimClient);
            call(app.ResetSimClient,serviceMsg);
        end
        
        function pauseSim(app)
            % PAUSESIM Calls service to pause simulation.
            serviceMsg = rosmessage(app.PausePhyClient);
            call(app.PausePhyClient,serviceMsg);
        end
        
        function resumeSim(app)
            % RESUMESIM Calls service to resume simulation after a pause.
            serviceMsg = rosmessage(app.ResumePhyClient);
            call(app.ResumePhyClient,serviceMsg);
        end
        
    end
    
    %% Class object's Callback methods
    methods(Access = private)
        
        function keyPadCallback(app, key)
            switch key.Key
                case 'uparrow'
                    app.hForward.Callback([],[]);
                case 'downarrow'
                    app.hReverse.Callback([],[]);
                case 'rightarrow'
                    app.hClockwise.Callback([],[]);
                case 'leftarrow'
                    app.hCounterClockwise.Callback([],[]);
            end
        end
        
        function updateButtonImage(app, button)
            tag = button.Tag;
            switch tag
                case 'Forward'
                    img = app.upArrow;
                case 'Reverse'
                    img = app.downArrow;
                case 'CCW'
                    img = app.ccwArrow;
                case 'CW'
                    img = app.ccwArrow(:,end:-1:1,:);
                otherwise
                    warning('Buttons may not appear appropriatly.');
            end
            
            button.Units = 'Pixels';
            pos = button.Position;
            imgDim = floor(min(pos(3:4))*.8);
            button.Units = 'Normalized';
            button.CData = imresize(img,[imgDim,imgDim]);
            
        end
        
        function ctrlButtonCallback(app, linDelta, angDelta)
            currentX = app.mobileRobot.x;
            currentY = app.mobileRobot.y;
            currentTheta = app.mobileRobot.theta;
            
            cT = cos(currentTheta);
            sT = sin(currentTheta);
            
            directionVector = [cT, -sT; ...
                sT, cT]*[1;0]+[currentX;currentY];
            unitDirVec = directionVector./norm(directionVector);
            
            positionUpdate = [currentX;currentY] + unitDirVec .* linDelta;
            
            app.mobileRobot.xDesired = positionUpdate(1);
            app.mobileRobot.yDesired = positionUpdate(2);
            
            app.mobileRobot.thetaDesired = currentTheta + angDelta;
        end
        
        function startButtonCallback(app)
            if strcmp(app.mobileRobot.Running, 'off') && ...
                    strcmp(app.Running, 'on')
                app.mobileRobot.startCtrl();
            end
        end
        
        function stopButtonCallback(app)
            if strcmp(app.mobileRobot.Running, 'on')
                app.mobileRobot.stopCtrl();
            end
        end
        
        function popCallback(app, uiHandle, ~)
            % POPCALLBACK Handles the pointcloud viewer's visualiztion.
            switch uiHandle.String{uiHandle.Value}
                case 'Top'
                    view(app.hVisionAxis, 2);
                case 'First Person'
                    view(app.hVisionAxis, 0,0);
                case 'Perspective'
                    view(app.hVisionAxis, 3)
            end
        end
        
        function resetGazeboButtonCallback(app)
            % RESETGAZEBOBUTTONCALLBACK Is currently not used. Gazebo
            % simulation does not reset 'properly'.
            app.mobileRobot.stopCtrl();
            app.pauseSim();
            app.resetSim();
            pause(10);
            app.mobileRobot.xDesired = 0;
            app.mobileRobot.yDesired = 0;
            app.mobileRobot.thetaDesired = 0;
            app.resumeSim();
        end
        
        function buildMenu(app)
            % BUILDMENU Constructs the App main menu. Augments menu built
            % by the studentCompetitionApp superclass.
            app.main.rosmenu = uimenu(app.main.figure, 'Label', 'ROS');
            uimenu(app.main.rosmenu,...
                'Label', 'ROS Configuration',...
                'Callback', @app.configureROS,...
                'Accelerator', 'r');
            uimenu(app.main.rosmenu,...
                'Label', 'VM Setup',...
                'Callback', @appSetup,...
                'Accelerator', 's');
        end
        
    end
    
    %% Static methods that are not a part of the public user interface.
    methods(Hidden, Static)
        
        function fileExchangeUrl = getFileExchangeUrl()
            % FILEEXCHANGEURL Returns the File Exchange Url for the current
            % App. This webpage will be read and parsed when checking for an
            % update to the App by the studentCompetitionApp superclass.
            fileExchangeUrl = 'http://www.mathworks.com/matlabcentral/fileexchange/';
        end
        
        function updateDownloadUrl = getUpdateDownloadUrl()
            % UPDATEDOWNLOADURL Returns the Url to download the latest
            % available App. The URL is handled by the
            % studentCompetitionApp superclass.
            updateDownloadUrl = 'http://www.mathworks.com/matlabcentral/fileexchange/';
        end
        
        function rootPath = genRootPath()
            % GETHROOTPATH Returns the rootpath of the App to pass to post
            % install helper functions outside the class.
            rootPath = fileparts(mfilename('fullpath'));
        end
        
    end
    
    %% GUI construction helper methods.
    methods(Access = private)
        
        function buildVisionPanel(app,~,~)
            
            app.popView = uicontrol(...
                'Parent', app.hFigure,...
                'Style', 'popupmenu',...
                'String', {'Perspective', 'First Person', 'Top'},...
                'Units', 'normalized',...
                'Position', [0.01, 0.90, 0.05, 0.075],...
                'Callback', @app.popCallback);
            
            app.hVisionAxis = axes('Parent', app.hFigure);
            
            app.kinect = kinectViewer('Parent', app.hVisionAxis);
            app.cleanup.kinect = onCleanup(@app.deleteKinect);
            
            set(app.hVisionAxis, ...
                'Units', 'normalized',...
                'Color', app.hFigure.Color,...
                'Position', [0.1, 0.15,  0.5, 0.8], ...
                'XLimMode', 'manual', ...
                'YLimMode', 'manual', ...
                'ZLimMode', 'manual', ...
                'XLim', [-5, 5], ...
                'XTick', [-5 -3 -1 0 1 3 5], ...
                'YLim', [0,10], ...
                'YTick', 0:2:10, ...
                'ZLim', [-0.4, 1], ...
                'ZTick', -0.4:0.2:1, ...
                'DataAspectRatio', [0.5, 0.5, 0.1]);
            
            xlabel(app.hVisionAxis, 'Camera-X [m]');
            ylabel(app.hVisionAxis, 'Camera-Z [m]');
            zlabel(app.hVisionAxis, 'Camera-Y [m]');
            
        end
        
        function buildButtonPanel(app,~,~)
            
            horzButtonSep = 0.45;
            buttonWidth = 0.3;
            buttonHeight = 0.15;
            ctrlPanelWidth = 0.8;
            ctrlPanelHeight = 0.45;
            
            app.upArrow = imread('upArrow.png');
            app.downArrow = imread('downArrow.png');
            app.ccwArrow = imread('ccw.png');
            
            %Build main panel
            app.hButtonPanel = uipanel('Parent', app.hFigure, ...
                'Title','Turtlebot', ...
                'FontSize',12, ...
                'Position',[ 0.65 0.05 0.325 0.9]);
            
            % Build app control panel
            app.hControlButtonPanel = uipanel('Parent', app.hButtonPanel, ...
                'Position',[ 0.1 0.55 0.8 0.45]);
            
            % Build the buttons.
            app.hForward = uicontrol('Style','pushbutton', ...
                'Units', 'normalized', ...
                'Position', [0.35 0.8 buttonWidth buttonHeight], ...
                'Tag', 'Forward', ...
                'Parent', app.hControlButtonPanel, ...
                'Callback', @(~,~)app.ctrlButtonCallback(1,0), ...
                'KeyPressFcn', @(x,y)app.keyPadCallback(y));
            app.updateButtonImage(app.hForward);
            
            app.hReverse = uicontrol('Style','pushbutton', ...
                'Units', 'normalized', ...
                'Position', [0.35 0.45 buttonWidth buttonHeight], ...
                'Tag', 'Reverse', ...
                'Parent', app.hControlButtonPanel, ...
                'Callback', @(~,~)app.ctrlButtonCallback(-1,0), ...
                'KeyPressFcn', @(x,y)app.keyPadCallback(y));
            app.updateButtonImage(app.hReverse);
            
            app.hClockwise = uicontrol('Style','pushbutton', ...
                'Units', 'normalized', ...
                'Position', [0.5750 0.625 buttonWidth buttonHeight], ...
                'Tag', 'CW', ...
                'Parent', app.hControlButtonPanel, ...
                'Callback', @(~,~)app.ctrlButtonCallback(0,-0.2), ...
                'KeyPressFcn', @(x,y)app.keyPadCallback(y));
            app.updateButtonImage(app.hClockwise);
            
            app.hCounterClockwise = uicontrol('Style','pushbutton', ...
                'Units', 'normalized', ...
                'Position', [0.1250 0.625 buttonWidth buttonHeight], ...
                'Tag', 'CCW', ...
                'Parent', app.hControlButtonPanel, ...
                'Callback', @(~,~)app.ctrlButtonCallback(0,0.2), ...
                'KeyPressFcn', @(x,y)app.keyPadCallback(y));
            app.updateButtonImage(app.hCounterClockwise);
            
            app.hStart = uicontrol('Style','pushbutton', ...
                'Units', 'normalized', ...
                'Position', [0.125+horzButtonSep, ...
                0.0278 buttonWidth buttonHeight], ...
                'String', 'Start Robot', ...
                'Parent', app.hControlButtonPanel, ...
                'Callback', @(~,~)app.startButtonCallback, ...
                'KeyPressFcn', @(x,y)app.keyPadCallback(y));
            
            app.hReset = uicontrol('Style','pushbutton', ...
                'Units', 'normalized', ...
                'Position', [0.125, ...
                0.0278 buttonWidth buttonHeight], ...
                'String', 'Stop Robot', ...
                'Parent', app.hControlButtonPanel, ...
                'Callback', @(~,~)app.stopButtonCallback, ...
                'KeyPressFcn', @(x,y)app.keyPadCallback(y));
            
            % Supperclass provided buttons.
            % Set Close button location
            set(app.main.buttons.close, ...
                'Parent', app.hButtonPanel, ...
                'Units', 'Normalized', ...
                'Position', [(0.025+2*horzButtonSep)*ctrlPanelWidth, ...
                0.0278, ...
                buttonWidth*ctrlPanelWidth, ...
                buttonHeight*ctrlPanelHeight], ...
                'Callback', @(~,~)app.deleteApp, ...
                'KeyPressFcn', @(x,y)app.keyPadCallback(y));
            set(app.main.buttons.faq, ...
                'Parent', app.hButtonPanel, ...
                'Units', 'Normalized', ...
                'Position', [(0.025+horzButtonSep)*ctrlPanelWidth, ...
                0.0278, ...
                buttonWidth*ctrlPanelWidth, ...
                buttonHeight*ctrlPanelHeight], ...
                'KeyPressFcn', @(x,y)app.keyPadCallback(y));
            set(app.main.buttons.help, ...
                'Parent', app.hButtonPanel, ...
                'Units', 'Normalized', ...
                'Position', [0.025*ctrlPanelWidth, ...
                0.0278, ...
                buttonWidth*ctrlPanelWidth, ...
                buttonHeight*ctrlPanelHeight], ...
                'Callback', @(~,~)doc('mobileRobotController'), ...
                'KeyPressFcn', @(x,y)app.keyPadCallback(y));
        end
    end
    
end