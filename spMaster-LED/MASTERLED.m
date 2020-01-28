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

% Last Modified by GUIDE v2.5 14-Jan-2020 15:30:39

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
% End initialization code - DO NOT EDIT


% --- Executes just before MASTERGUI is made visible.
function MASTERLED_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MASTERGUI (see VARARGIN)

% Choose default command line output for MASTERGUI
handles.output = hObject;

% global ai; global dio;

[ai, dio] = krConnectDAQInf();

% handles = setfield(handles,'ai',ai);
% handles = setfield(handles,'dio',dio);
handles.ai = ai;
handles.dio = dio;

%Set function handles for inputs

% startJoy
% handles.getEyePosFunc = @peekJoyPos;
handles.deliverRewardFunc = @deliverRewardNotification;

handles.getEyePosFunc = @krPeekEyePos;
%handles.deliverRewardFunc = @krDeliverReward;
%global buffData buffTime

handles.masterFolder = 'C:\Users\SommerLab\Documents\spMaster-LED';
handles.experFolder = 'C:\Users\SommerLab\Documents\spMaster-LED\experiments';
handles.trialFolder = 'C:\Users\SommerLab\Documents\spMaster-LED\trials';

% change the current folder to trials folder
cd(handles.trialFolder);

trials = uigetdir;
Infolder = dir(trials);
trialList = [];
for i = 1:length(Infolder)
   if Infolder(i).isdir==0
       name = Infolder(i).name;
       name = name(1:end-4);
       trialList{end+1,1} = name;
   end
end
set(handles.SavedTrials,'String',trialList)

% change the current folder to experiments folder
cd(handles.experFolder);

experiments = uigetdir;
Infolder = dir(experiments);
experList = [];
for i = 1:length(Infolder)
   if Infolder(i).isdir==0
       expername = Infolder(i).name;
       expername = expername(1:end-4);
       experList{end+1,1} = expername;
   end
end
set(handles.SavedExperiments,'String',experList)

% change the current folder to spMaster-LED
cd(handles.masterFolder);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MASTERGUI wait for user response (see UIRESUME)
% uiwait(handles.mastergui);


% --- Outputs from this function are returned to the command line.
function varargout = MASTERLED_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in SavedTrials.
function SavedTrials_Callback(hObject, eventdata, handles)
% hObject    handle to SavedTrials (see GCBO)
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

data = mydata.TrialParams;

set(handles.TrialParam,'data',data)
set(handles.TrialName,'String',trisel)

% Hints: contents = cellstr(get(hObject,'String')) returns SavedTrials contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SavedTrials


% --- Executes during object creation, after setting all properties.
function SavedTrials_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SavedTrials (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function TrialParam_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TrialParam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object deletion, before destroying properties.
function TrialParam_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to TrialParam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when entered data in editable cell(s) in TrialParam.
function TrialParam_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to TrialParam (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

% I plan on writing code here to check for valid input, convert strings to 
%   relevant numerical values, etc

% safety check: Are the degrees entered by the user valid in the sense that
% they correspond to lcoations where an LED is present?
Data = str2double(get(handles.TrialParam,'String'));
cols = 2;
disp('hello')
for phase = 1:size(Data,cols)
    if ((Data{phase,3} < 0)||(Data{phase,3} > 20 && Data{phase,3} < 25)...
            ||(Data{phase,3} > 25 && Data{phase,3} < 30)||...
            (Data{phase,3} > 30 && Data{phase,3} < 35)||Data{phase,3} > 35)
        str = sprintf('Invalid degree entry in phase %d of last saved trial.', phase);
        msgbox(str);
    end
end



function TrialName_Callback(hObject, eventdata, handles)
% hObject    handle to TrialName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global TrialName
TrialName = get(hObject, 'String');
% Hints: get(hObject,'String') returns contents of TrialName as text
%        str2double(get(hObject,'String')) returns contents of TrialName as a double


% --- Executes during object creation, after setting all properties.
function TrialName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TrialName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SaveTrial.
function SaveTrial_Callback(hObject, eventdata, handles)
% hObject    handle to SaveTrial (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global TrialParams;
TrialParams = get(handles.TrialParam,'Data');
FileName   = get(handles.TrialName,'String');
File = strcat(FileName,".mat");

% Save the trial into the "trials" folder
% change the current folder to trials folder
cd(handles.trialFolder);
save(File, 'TrialParams')

% change the current folder to spMaster-LED
cd(handles.masterFolder);

trials = get(handles.SavedTrials,'String');
trials = [trials; cellstr(FileName)];
set(handles.SavedTrials,'String',trials)



% --- Executes on button press in Start.
function Start_Callback(hObject, eventdata, handles)
% hObject    handle to Start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% if(get(handles.SetTrialNumber,'Value') == 0)
%     set(handles.SetTrialNumber,'Value',100);
% end

% Update handles structure
guidata(hObject, handles);
contents = cellstr(get(handles.chooseOrder,'String'));
order = contents{get(handles.chooseOrder,'Value')};

exp2run = get(handles.ExperimentName,'String');
exp2run = strcat(exp2run,'.mat');

experimentLED(exp2run,order,handles);

% --- Executes on button press in End.
function End_Callback(hObject, eventdata, handles)
% hObject    handle to End (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in Reward.
function Reward_Callback(hObject, eventdata, handles)
% hObject    handle to Reward (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
krDeliverReward(handles.dio,1);


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


% --- Executes during object creation, after setting all properties.
function Start_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function Reward_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Reward (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


function ExperimentName_Callback(hObject, eventdata, handles)
% hObject    handle to ExperimentName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ExperimentName
ExperimentName = get(hObject, 'String');
% Hints: get(hObject,'String') returns contents of ExperimentName as text
%        str2double(get(hObject,'String')) returns contents of ExperimentName as a double


% --- Executes during object creation, after setting all properties.
function ExperimentName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ExperimentName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in SavedExperiments.
function SavedExperiments_Callback(hObject, eventdata, handles)
% hObject    handle to SavedExperiments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

experiments = get(hObject,'String');
indsel = get(hObject,'Value');
expsel = experiments{indsel};

% change the current folder to experiments folder
cd(handles.experFolder);

mydata = load(expsel);

% change the current folder to spMaster-LED
cd(handles.masterFolder);

data = mydata.ExperParams;

set(handles.ExperimentParam,'data',data)
set(handles.ExperimentName,'String',expsel)
% Hints: contents = cellstr(get(hObject,'String')) returns SavedExperiments contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SavedExperiments


% --- Executes during object creation, after setting all properties.
function SavedExperiments_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SavedExperiments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SaveExperiment.
function SaveExperiment_Callback(hObject, eventdata, handles)
% hObject    handle to SaveExperiment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ExperParams;
ExperParams = get(handles.ExperimentParam,'Data');
FileName   = get(handles.ExperimentName,'String');
File = strcat(FileName,".mat");

% Save the experiment into the "experiments" folder
% change the current folder to experiments folder
cd(handles.experFolder);

save(File, 'ExperParams')

% change the current folder to spMaster-LED
cd(handles.masterFolder);

experiments = get(handles.SavedExperiments,'String');
experiments = [experiments; cellstr(FileName)];
set(handles.SavedExperiments,'String',experiments)


% --- Executes on selection change in chooseOrder.
function chooseOrder_Callback(hObject, eventdata, handles)
% hObject    handle to chooseOrder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns chooseOrder contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chooseOrder


% --- Executes during object creation, after setting all properties.
function chooseOrder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chooseOrder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

set(hObject, 'String', {'Uniform', 'Block','Random'});


% --- Executes during object creation, after setting all properties.
function SaveTrial_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SaveTrial (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function SaveExperiment_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SaveExperiment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function End_CreateFcn(hObject, eventdata, handles)
% hObject    handle to End (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called