function varargout = MASTERLED(varargin)
% MASTERGUI MATLAB code for MASTERGUI.fig
%      MASTERGUI, by itself, creates a new MASTERGUI or raises the existing
%      singleton*.
%
%      H = MASTERGUI returns the handle to a new MASTERGUI or the handle to
%      the existing singleton*.
%
%      MASTERGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MASTERGUI.M with the given input arguments.
%
%      MASTERGUI('Property','Value',...) creates a new MASTERGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MASTER_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MASTER_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MASTERGUI

% Last Modified by GUIDE v2.5 27-Jul-2020 12:41:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MASTERLED_OpeningFcn, ...
                   'gui_OutputFcn',  @MASTERLED_OutputFcn, ...
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
% endExperiment_pushbutton initialization code - DO NOT EDIT


% --- Executes just before MASTERGUI is made visible.
function MASTERLED_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MASTERGUI (see VARARGIN)

% Choose default command line output for MASTERGUI
handles.output = hObject;

% Set function handles for inputs
% save TrialParams in handles in a cell array of doubles
handles.TrialParams_LED.Data = cellfun(@double,handles.TrialParams_LED.Data,'UniformOutput',false);
handles.TrialParams_robot.Data = cellfun(@double,handles.TrialParams_robot.Data,'UniformOutput',false);
% Make logical checkbox columns in parameter table for robot editable
% Replace 0 with []
handles.TrialParams_robot.Data(:,:) = {[]};

% save folder paths
% choose paths based on computer name
% if CCN computer than save with SommerLab rig computer specifics
% otherwise save with spcifics of Mackenzie's laptop
compName = getenv('COMPUTERNAME');
if strcmp(compName(1:3),'CCN')
    handles.masterFolder = 'C:\Users\SommerLab\Documents\Github\OptoVergenceRobot\spMaster-LED';
    handles.experFolder = 'C:\Users\SommerLab\Documents\Github\OptoVergenceRobot\spMaster-LED\experiments';
    handles.trialFolder = 'C:\Users\SommerLab\Documents\Github\OptoVergenceRobot\spMaster-LED\trials';
    handles.dataFolder = 'C:\Users\SommerLab\Documents\Github\OptoVergenceRobot\spMaster-LED\data';   
else
    handles.masterFolder = 'C:\Users\Mackenzie\Documents\Github\OptoVergenceRobot\spMaster-LED';
    handles.experFolder = 'C:\Users\Mackenzie\Documents\Github\OptoVergenceRobot\spMaster-LED\experiments';
    handles.trialFolder = 'C:\Users\Mackenzie\Documents\Github\OptoVergenceRobot\spMaster-LED\trials';
    handles.dataFolder = 'C:\Users\Mackenzie\Documents\Github\OptoVergenceRobot\spMaster-LED\data';
end
% change the current folder to trials folder
cd(handles.trialFolder);

% add saved trials to handles
trials = uigetdir;
handles.trialFolder = trials;
Infolder = dir(trials);
trialList = [];
for i = 1:length(Infolder)
   if Infolder(i).isdir==0
       name = Infolder(i).name;
       name = name(1:end-4);
       trialList{end+1,1} = name;
   end
end
set(handles.savedTrials_listbox,'String',trialList)

% change the current folder to experiments folder
cd(handles.experFolder);

% add saved experiments to handles
experiments = uigetdir;
handles.experFolder = experiments;
Infolder = dir(experiments);
experList = [];
for i = 1:length(Infolder)
   if Infolder(i).isdir==0
       expername = Infolder(i).name;
       expername = expername(1:end-4);
       experList{end+1,1} = expername;
   end
end
set(handles.savedExperiments_listbox,'String',experList)

% change the current folder to data folder
cd(handles.dataFolder);

% add data path to handles
data_main_dir = uigetdir;
handles.data_main_dir = data_main_dir;
cd(data_main_dir);
data_dir_prefix = datestr(datetime('now'),'yyyymmdd_');
i = 0;
while i < 100
   data_dir = [data_dir_prefix,num2str(i)];
   if ~exist(data_dir, 'dir')
       mkdir(data_dir)
       break;
   end
   i = i + 1;
end
if i == 100
    errordlg('ERROR: You have reached the maximum number of data folders allowed.','File Error');
end
handles.data_path = fullfile(data_main_dir,data_dir);

% connect to DAQ card, create session, listen for data
[ai, dio] = krConnectDAQInf(data_main_dir);

% save analog input and digital input/output objects to handles
handles.ai = ai;
handles.dio = dio;

handles.getEyePosFunc = @()(krPeekEyePos(data_main_dir));
handles.deliverRewardFunc = @krDeliverReward;

% change the current folder to spMaster-LED
cd(handles.masterFolder);

% Arduino system setup
% In Arduino sketch, when Arduino is connected to computer, go to Tools>Port
% to find COM port you are connected to. If necessary, update string stored
% in serialPort accordingly.
serialPort = 'COM4';
% create an object of the class to use it
% functions within class can be used in experimentLED and trialLED
a = ExperimentClass_GUI_LEDboard(serialPort); 
% save experiment class object to handles
handles.a_serialobj = a;
% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = MASTERLED_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in savedTrials_listbox.
function savedTrials_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to savedTrials_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

trials = get(hObject,'String');
indsel = get(hObject,'Value');
trisel = trials{indsel};

% change the current folder to trials folder
cd(handles.trialFolder);

mydata = load(trisel);

% change the current folder to spMaster-LED
cd(handles.masterFolder);

LEDdata = mydata.TrialParams_LED;
robotdata = mydata.TrialParams_robot;

set(handles.TrialParams_LED,'data',LEDdata)
set(handles.TrialParams_robot,'data',robotdata)
set(handles.trialName_editbox,'String',trisel)

% Hints: contents = cellstr(get(hObject,'String')) returns savedTrials_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from savedTrials_listbox


% --- Executes during object creation, after setting all properties.
function savedTrials_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to savedTrials_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object deletion, before destroying properties.
function savedTrials_listbox_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to savedTrials_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when entered data in editable cell(s) in TrialParams_LED.
function TrialParams_LED_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to TrialParams_LED (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

% % safety check: Are the degrees entered by the user valid in the sense that
% % they correspond to locations where an LED is present?

%save indices of last selected cell in LED Trial Design Table
handles.selectedCell(1) = eventdata.Indices(1);
handles.selectedCell(2) = eventdata.Indices(2);
%save source of last selected cell (either TrialParams_LED or
%TrialParams_robot)
%in this function source will be TrialParams_LED
handles.selectedCellSource = eventdata.Source.Tag;
% Update handles structure
guidata(hObject, handles);

%for the number of rows that contain parameters 
%iterate through and display error message if any of the entries for 
%LED degree meet the conditions

%save LED data in variable
LED = get(handles.TrialParams_LED,'Data');
%find column index for direction and visual angle/degree data
%this index is not hard-coded in the case that structure of trial table for
%LED data is changed
dirIdx = strcmp(handles.TrialParams_LED.ColumnName,'Direction');
degIdx = find(strcmp(handles.TrialParams_LED.ColumnName,'<html><center>Visual<br>Angle (째)<center><html>'));
%available degree entries for LEDs on LED board are
%0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,25,30
%For each direction on the LED board, there are also LEDs present at 35
%degrees from center; however, some of those LEDs are blocked by the frame
%of the robot.
%In the case of the west strip, that LED is used with the photodiode to
%keep close timing of any other LEDs being activated. 
availLEDs = [0:20 25:5:30];
%loop through number of rows in LED data table
for phase = 1:size(LED,1)
    %for any cells that contain NaN
    mask = cellfun(@(C) all(isnan(C)), LED);
    %make those cells empty
    LED(mask) = {[]};
    %save those changes in the cell array for LED tabel data
    set(handles.TrialParams_LED,'Data',LED);   
    %if "center" is selected as the direction for a phase
    if strcmp(LED(phase,dirIdx),'center')
        %automatically set the visual angle/degree to 0 
        LED(phase,degIdx) = num2cell(0);
        %load the change on the table
        set(handles.TrialParams_LED,'Data',LED);   
    end
    %while a visual angle/degree has not been entered for the current phase
    while isempty(LED{phase,degIdx})
        %wait
        pause;
    end
    %if the value entered for visual angle/degree of the current phase is
    %not one of the available LEDs
    if ~ismember(LED{phase,degIdx},availLEDs)   
        %display an error message
        str = sprintf('Invalid degree entry in phase %d of current trial. Possible visual angle entries are integer values of 0-20, 25, and 30.', phase);
        uiwait(msgbox(str,'Error','error'));
    end
end


% --- Executes when entered data in editable cell(s) in TrialParams_robot.
function TrialParams_robot_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to TrialParams_robot (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

%save indices of last selected cell in LED Trial Design Table
handles.selectedCell(1) = eventdata.Indices(1);
handles.selectedCell(2) = eventdata.Indices(2);
%save source of last selected cell (either TrialParams_LED or
%TrialParams_robot)
%in this function source will be TrialParams_robot
handles.selectedCellSource = eventdata.Source.Tag;
% Update handles structure
guidata(hObject, handles);

% If vergence angle and visual angle entered, then calculate 
% xCoord and zCoord and fill corresponding cells.
% If xCoord and zCoord entered, then calculate 
% vergence angle and visual angle and fill corresponding cells.
% store data from robot params table
robot = get(handles.TrialParams_robot,'Data');
VisAngIdx = strcmp(handles.TrialParams_robot.ColumnName,'<html><center>Visual<br>Angle (째)<center><html>');
VergAngIdx = strcmp(handles.TrialParams_robot.ColumnName,'<html><center>Vergence<br>Angle (째)<center><html>');
xCoordIdx = strcmp(handles.TrialParams_robot.ColumnName,'X Coordinate (cm)');
zCoordIdx = strcmp(handles.TrialParams_robot.ColumnName,'Z Coordinate (cm)');
LEDdurIdx = strcmp(handles.TrialParams_robot.ColumnName, '<html><center>LED<br>Duration (s)<center><html>');
interpupDist = str2double(handles.interpupDist_editbox.String);
Ihalf = interpupDist/2;
currRow = eventdata.Indices(1);
currCol = eventdata.Indices(2);

%if the current selected cell is in LED duration column and the value
%entered is ot numeric (i.e. is a char or a string)
if currCol == find(LEDdurIdx) && ~isnumeric(robot{currRow,currCol})
    %replace the non-numeric value to the double equivalent and save 
    robot{currRow,currCol} = str2double(robot{currRow,currCol});
    set(handles.TrialParams_robot,'Data',robot);   
end

%if the current selected cell is in the x coordinate or z coordinate
%columns
if currCol == find(xCoordIdx) || currCol == find(zCoordIdx)
    %while no value has been entered in those cells
    while isempty(robot{currRow,xCoordIdx})||isempty(robot{currRow,zCoordIdx})
        %wait
        pause;
    end
    %after values have been entered, convert the cells to doubles
    xCoord = cell2mat(robot(currRow,xCoordIdx));
    zCoord = cell2mat(robot(currRow,zCoordIdx));
    %calculate corresponding visual angle and vergence angle
    [VisAng,VergAng] = calcRobotPhaseAngs(xCoord,zCoord,Ihalf);
    %convert numeric values to cells before saving 
    robot(currRow,VisAngIdx) = num2cell(VisAng);
    robot(currRow,VergAngIdx) = num2cell(VergAng);
%if the current selected cell is in the visual angle or vergence angle
%column
elseif currCol == find(VisAngIdx) || currCol == find(VergAngIdx)
    %while no value has been entered in those cells
    while isempty(robot{currRow,VisAngIdx})||isempty(robot{currRow,VergAngIdx})
        %wait
        pause;
    end
    %after values have been entered, convert the cells to doubles
    VisAng = cell2mat(robot(currRow,VisAngIdx));
    VergAng = cell2mat(robot(currRow,VergAngIdx));
    %calculate corresponding xCoord and zCoord
    [xCoord,zCoord] = calcRobotPhaseCoords(VisAng,VergAng,Ihalf);
    %convert numeric values to cells before saving 
    robot(currRow,xCoordIdx) = num2cell(xCoord);
    robot(currRow,zCoordIdx) = num2cell(zCoord);
end

%set logical to track validity of entries to true
validCheck = true;
%if current cell selected is for xCoord, if the cell is not empty, and if
%the value falls outside the range of 0-134.62 
if currCol == find(xCoordIdx) && ~isempty(robot{currRow,xCoordIdx}) && (xCoord < 0 || xCoord > 134.62) 
    %display an error message
    str = sprintf('Calculated X-coordinate out of bounds. Invalid visual/vergence angle combination.');
    uiwait(msgbox(str,'Error','error'));
    %set validity logical to false
    validCheck = false;
end
%if current cell selected is for zCoord, if the cell is not empty, and if
%the value falls outside the range of 0-86.0425 
if currCol == find(zCoordIdx) && ~isempty(robot{currRow,zCoordIdx}) && (zCoord < 0 || zCoord > 86.0425)
    %display an error message
    str = sprintf('Calculated Z-coordinate out of bounds. Invalid visual/vergence angle combination.');
    uiwait(msgbox(str,'Error','error'));
    %set validity logical to false
    validCheck = false;
end

% THE FOLLOWING CODE IS COMMENTED OUT BUT COULD BE USEFUL FOR THE FUTURE IF
% VELOCITIES ARE ADDED TO THE ROBOT PARAMETERS TRIAL DESIGN TABLE
% % get column index of Vx from table column names
% % VxIdx = strcmp(handles.TrialParams_robot.ColumnName,'Vx (�/s)');
% % get column index of Vz
% % VzIdx = strcmp(handles.TrialParams_robot.ColumnName,'Vz (�/s)');
% % store  current row index of param table
% % currRow = eventdata.Indices(1);
% % if Vx or Vz entry in table is empty, then wait
% % while isempty(robot{currRow,VzIdx})||isempty(robot{currRow,VxIdx})
% %     pause;
% % end
% % when Vx and Vz entry filled, convert cells to matrices/numbers (since
% % cells as inputs incompatible with hypot function)
% % Vz = cell2mat(robot(currRow,VzIdx));
% % Vx = cell2mat(robot(currRow,VxIdx));
% % calculate overall velocity from the x and z components
% % Vel = hypot(Vx, Vz);
% % fill the calculated velocity robot cell array
%%robot(currRow,find(VxIdx)-1) = num2cell(Vel);
% display changes of data cell array on robot params table of main GUI

%if logical tracking validity is true
if validCheck
    %manifest the saved changes on the main GUI table
    set(handles.TrialParams_robot,'Data',robot);   
end


function trialName_editbox_Callback(hObject, eventdata, handles)
% hObject    handle to trialName_editbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global TrialName
TrialName = get(hObject, 'String');
% Hints: get(hObject,'String') returns contents of trialName_editbox as text
%        str2double(get(hObject,'String')) returns contents of trialName_editbox as a double


% --- Executes during object creation, after setting all properties.
function trialName_editbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trialName_editbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in saveTrial_pushbutton.
function saveTrial_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to saveTrial_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%for the number of rows that contain parameters 
%iterate through and display error message if any of the entries for 
%LED degree meet the conditions 
LED = get(handles.TrialParams_LED,'Data');
numLEDphases = sum(~cellfun(@isempty,LED(:,2)),1);
degIdx = find(strcmp(handles.TrialParams_LED.ColumnName,'<html><center>Visual<br>Angle (째)<center><html>'));
availLEDs = [0:20 25:5:30];
for phase = 1:numLEDphases
    if ~ismember(LED{phase,degIdx},availLEDs)    
        str = sprintf('Invalid degree entry in phase %d of current trial. Possible visual angle entries are integer values of 0-20, 25, and 30.', phase);
        uiwait(msgbox(str,'Error','error'));
    end
end
%access parameter date for LED board and vergence robot
TrialParams_LED = get(handles.TrialParams_LED,'Data');
TrialParams_robot = get(handles.TrialParams_robot,'Data');
%access filename for the trial
FileName   = get(handles.trialName_editbox,'String');
File = strcat(FileName,".mat");

% change the current folder to trials folder
cd(handles.trialFolder);
% Save the trial containing separate cell arrays for TrialParam_LED and TrialParam_robot
% into the "trials" folder in indicated file
save(File, 'TrialParams_LED', 'TrialParams_robot')

% change the current folder to spMaster-LED
cd(handles.masterFolder);

%update the trials list 
trials = get(handles.savedTrials_listbox,'String');
trials = [trials; cellstr(FileName)];
set(handles.savedTrials_listbox,'String',trials)

% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function saveTrial_pushbutton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to saveTrial_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in start_pushbutton.
function start_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to start_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Update handles structure
guidata(hObject, handles);

%if debug mode is activated (if checkbox is checked)
%use joy stick to simulate eye movements instead of eye coil phase detector
%readings
%print deliverreward_pushbutton delivery notification in command window instead of actually
%delivering deliverreward_pushbutton
if get(handles.debugging_checkbox,'Value')
    startJoy;
    handles.getEyePosFunc = @peekJoyPos;
    handles.deliverRewardFunc = @deliverRewardNotification;
end

%access selected order from drop-down list
contents = cellstr(get(handles.chooseOrder_choicelist,'String'));
order = contents{get(handles.chooseOrder_choicelist,'Value')};

%access filename for selected, pre-saved experiment
exp2run = get(handles.experimentName_editbox,'String');
exp2run = strcat(exp2run,'.mat');
% Update handles structure
guidata(hObject, handles);

% Run the experiment
experimentLED(exp2run,order,handles);


% --- Executes during object creation, after setting all properties.
function start_pushbutton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to start_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in endExperiment_pushbutton.
function endExperiment_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to endExperiment_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%save serial object 
a = handles.a_serialobj;
%clear the LED board
a.clearLEDs();
%end the serial connection between MATLAB and Arduino
a.endSerial();
clear
close all
%return to the command window
return 


% --- Executes during object creation, after setting all properties.
function endExperiment_pushbutton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to endExperiment_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in deliverReward_pushbutton.
function deliverReward_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to deliverReward_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%turn on, the turn off digital channel to deliver reinforcement
krDeliverReward(handles.dio,1);


% --- Executes during object creation, after setting all properties.
function deliverReward_pushbutton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to deliverReward_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on selection change in chooseFun2Run.
function chooseFun2Run_Callback(hObject, eventdata, handles)
% hObject    handle to chooseFun2Run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.chooseFun2Run, 'Value', get(hObject,'Value'));

% Hints: contents = cellstr(get(hObject,'String')) returns chooseFun2Run contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chooseFun2Run


% --- Executes during object creation, after setting all properties.
function chooseFun2Run_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chooseFun2Run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

set(hObject, 'String', {'Cal','DirReq','Fwd_Photo','Fwd_MScale',...
                         'Fwd_Sac','Fwd_Sac_MScale','FreeMap', 'FixTrain'});


function experimentName_editbox_Callback(hObject, eventdata, handles)
% hObject    handle to experimentName_editbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ExperimentName
ExperimentName = get(hObject, 'String');
% Hints: get(hObject,'String') returns contents of experimentName_editbox as text
%        str2double(get(hObject,'String')) returns contents of experimentName_editbox as a double


% --- Executes during object creation, after setting all properties.
function experimentName_editbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to experimentName_editbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in savedExperiments_listbox.
function savedExperiments_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to savedExperiments_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%when previously saved experiment is selected from the saved experiment
%list box, fill the experiment table with trial types
experiments = get(hObject,'String');
indsel = get(hObject,'Value');
expsel = experiments{indsel};

% change the current folder to experiments folder
cd(handles.experFolder);

mydata = load(expsel);

% change the current folder to spMaster-LED
cd(handles.masterFolder);

data = mydata.ExperParams;

set(handles.ExperimentParam_table,'data',data)
set(handles.experimentName_editbox,'String',expsel)
set(handles.chooseOrder_choicelist,'Value',mydata.trialOrder)
% Hints: contents = cellstr(get(hObject,'String')) returns savedExperiments_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from savedExperiments_listbox


% --- Executes during object creation, after setting all properties.
function savedExperiments_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to savedExperiments_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in saveExperiment_pushbutton.
function saveExperiment_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to saveExperiment_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ExperParams;
ExperParams = get(handles.ExperimentParam_table,'Data');
trialOrder = get(handles.chooseOrder_choicelist,'Value');

FileName = get(handles.experimentName_editbox,'String');
File = strcat(FileName,".mat");

% Save the experiment into the "experiments" folder
% change the current folder to experiments folder
cd(handles.experFolder);

save(File, 'ExperParams', 'trialOrder')

% change the current folder to spMaster-LED
cd(handles.masterFolder);

%update the saved experiments list
experiments = get(handles.savedExperiments_listbox,'String');
experiments = [experiments; cellstr(FileName)];
set(handles.savedExperiments_listbox,'String',experiments(:,1))


% --- Executes during object creation, after setting all properties.
function saveExperiment_pushbutton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to saveExperiment_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on selection change in chooseOrder_choicelist.
function chooseOrder_choicelist_Callback(hObject, eventdata, handles)
% hObject    handle to chooseOrder_choicelist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns chooseOrder_choicelist contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chooseOrder_choicelist


% --- Executes during object creation, after setting all properties.
function chooseOrder_choicelist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chooseOrder_choicelist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

set(hObject, 'String', {'Uniform', 'Block','Random'});


% --- Executes during object creation, after setting all properties.
function MASTERLEDfigure_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MASTERLEDfigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in debugging_checkbox.
function debugging_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to debugging_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of debugging_checkbox


% --- Executes on button press in robotReturnToOrigin_pushbutton.
function robotReturnToOrigin_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to robotReturnToOrigin_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
a = handles.a_serialobj;
a.returnRobot();

% --- Executes during object creation, after setting all properties.
function robotReturnToOrigin_pushbutton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to robotReturnToOrigin_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


function interpupDist_editbox_Callback(hObject, eventdata, handles)
% hObject    handle to interpupDist_editbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of interpupDist_editbox as text
%        str2double(get(hObject,'String')) returns contents of interpupDist_editbox as a double


% --- Executes during object creation, after setting all properties.
function interpupDist_editbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to interpupDist_editbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in robotFindDimensions_pushbutton.
function robotFindDimensions_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to robotFindDimensions_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
a = handles.a_serialobj;
a.findDimensions();


% --- Executes during object creation, after setting all properties.
function robotFindDimensions_pushbutton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to robotFindDimensions_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


function defaultITI_editbox_Callback(hObject, eventdata, handles)
% hObject    handle to defaultITI_editbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of defaultITI_editbox as text
%        str2double(get(hObject,'String')) returns contents of defaultITI_editbox as a double


% --- Executes during object creation, after setting all properties.
function defaultITI_editbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to defaultITI_editbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function timeout_editbox_Callback(hObject, eventdata, handles)
% hObject    handle to timeout_editbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of timeout_editbox as text
%        str2double(get(hObject,'String')) returns contents of timeout_editbox as a double


% --- Executes during object creation, after setting all properties.
function timeout_editbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to timeout_editbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in timeout_checkbox.
function timeout_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to timeout_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of timeout_checkbox

%if box is checked, remove grayed out editbox
if get(hObject,'Value')
    set(handles.timeout_editbox,'enable','on');
else
    set(handles.timeout_editbox,'enable','off');
end


% --- Executes during object creation, after setting all properties.
function timeout_checkbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to timeout_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in smoothPursuit_pushbutton.
function smoothPursuit_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to smoothPursuit_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
TrialParams_LED = get(handles.TrialParams_LED,'Data');
validCheck = true;
paramNames_LED = {'phaseNum','color','direction','visAng','duration','fixDur','ifReward','withNext','fixTol','numRew'};
trial = sortTrialParams(TrialParams_LED, paramNames_LED);
enteredPhases = vertcat(trial(1:end).phaseNum);
availLEDs = [0:20 25:5:30];
spStartIdx = find(diff(enteredPhases) > 1);
spEndIdx = spStartIdx + 1;
matchDeg = find(availLEDs == trial(spStartIdx).visAng);
degs = sort(availLEDs(2:matchDeg-1),'descend');
dirIdx = strcmp(handles.TrialParams_LED.ColumnName,'Direction');
TrialParams_LED(spEndIdx,:) = {[]};
if ~strcmp(trial(spStartIdx).direction, trial(spEndIdx).direction)
    TrialParams_LED(trial(spEndIdx).phaseNum,:) = struct2cell(trial(spEndIdx));
    if strcmp(trial(spStartIdx).direction, 'center')
        if validCheck
            for phase = spStartIdx+1:enteredPhases(spEndIdx)-1
                if diff([trial(spEndIdx).phaseNum, trial(spStartIdx).phaseNum]) ~= diff([trial(spEndIdx).visAng,trial(spStartIdx).visAng])
                    validCheck = false;
                    str = sprintf('Smooth Pursuit Error: Mismatch between final phase number and final visual angle.');
                    uiwait(msgbox(str,'Error','error'));
                    break
                end
                TrialParams_LED(phase,:) = {phase,TrialParams_LED{enteredPhases(spEndIdx),2},TrialParams_LED{enteredPhases(spEndIdx),dirIdx},availLEDs(phase-2),0.1,0,0,0,30,0};
            end
        end
    end
    for phase = spEndIdx:(enteredPhases(spEndIdx)-matchDeg)
        if (phase-numel(enteredPhases)+1) > numel(degs)
            validCheck = false;
            str = sprintf('Smooth Pursuit Error: Mismatch between final phase number and final visual angle.');
            uiwait(msgbox(str,'Error','error'));
            break
        end
        TrialParams_LED(phase,:) = {phase,TrialParams_LED{phase-1,2},TrialParams_LED{phase-1,dirIdx},degs(phase-numel(enteredPhases)+1),0.1,0,0,0,30,0};
    end
    zeroPhase = enteredPhases(spEndIdx)-matchDeg+1;
    TrialParams_LED(zeroPhase,:) = {zeroPhase,TrialParams_LED{zeroPhase-1,2},'center',0,0.1,0,0,0,30,0};
    if validCheck
        for phase = zeroPhase+1:enteredPhases(spEndIdx)-1
            if (phase-matchDeg-1) < 2
                validCheck = false;
                str = sprintf('Smooth Pursuit Error: Mismatch between final phase number and final visual angle.');
                uiwait(msgbox(str,'Error','error'));
                break
            end
            TrialParams_LED(phase,:) = {phase,TrialParams_LED{enteredPhases(spEndIdx),2},TrialParams_LED{enteredPhases(spEndIdx),dirIdx},availLEDs(phase-matchDeg-1),0.1,0,0,0,30,0};
        end
    end
elseif strcmp(trial(spStartIdx).direction, trial(spEndIdx).direction)
else
    validCheck = false;
    str = sprintf('Smooth Pursuit Error: Invalid direction entry.');
    uiwait(msgbox(str,'Error','error'));
end

if validCheck
    set(handles.TrialParams_LED,'Data',TrialParams_LED);
    FileName   = get(handles.trialName_editbox,'String');
    File = strcat(FileName,".mat");
    TrialParams_robot = cell(4,9);
    % Save the trial into the "trials" folder
    % change the current folder to trials folder
    cd(handles.trialFolder);
    save(File, 'TrialParams_LED', 'TrialParams_robot')
end


% --- Executes during object creation, after setting all properties.
function smoothPursuit_pushbutton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to smoothPursuit_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function TrialParams_LED_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TrialParams_LED (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes on button press in clearCellSelection_pushbutton.
function clearCellSelection_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to clearCellSelection_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%After button push, access table data from appropriate source, 
%either TrialParams_LED or TrialParams_robot
tableData = get(handles.(handles.selectedCellSource),'Data');
%set last selected cell to empty
tableData(handles.selectedCell(1),handles.selectedCell(2)) = {[]};
%manifest changes on the main GUI
set(handles.(handles.selectedCellSource),'Data',tableData); 


% --- Executes during object creation, after setting all properties.
function clearCellSelection_pushbutton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to clearCellSelection_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



% --- Executes on button press in clearAllCells_pushbutton.
function clearAllCells_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to clearAllCells_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%access data shown in tables
LED = get(handles.TrialParams_LED,'Data');
robot = get(handles.TrialParams_robot,'Data');
%set all cells to empty
LED(:) = {[]};
robot(:) = {[]};
%reset Trial Name 
handles.trialName_editbox.String = 'EDIT THIS TEXT';
%show changes
set(handles.TrialParams_LED,'Data',LED);
set(handles.TrialParams_robot,'Data',robot);


% --- Executes during object creation, after setting all properties.
function clearAllCells_pushbutton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to clearAllCells_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
