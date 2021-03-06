function varargout = auxiliary(varargin)
% AUXGUI MATLAB code for auxgui.fig
%      AUXGUI, by itself, creates a new AUXGUI or raises the existing
%      singleton*.
%
%      H = AUXGUI returns the handle to a new AUXGUI or the handle to
%      the existing singleton*.
%
%      AUXGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in AUXGUI.M with the given input arguments.
%
%      AUXGUI('Property','Value',...) creates a new AUXGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before auxiliary_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to auxiliary_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help auxgui

% Last Modified by GUIDE v2.5 24-Apr-2020 15:18:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @auxiliary_OpeningFcn, ...
                   'gui_OutputFcn',  @auxiliary_OutputFcn, ...
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


% --- Executes just before auxgui is made visible.
function auxiliary_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to auxgui (see VARARGIN)

% Choose default command line output for auxgui
handles.output = hObject;

% access object "a" that contains serial connection and save it in handles
% of auxiliary GUI
mainGUI = findobj('Tag','MASTERLEDfigure');
handles.a_serialobj = getappdata(mainGUI,'a');

% Update handles structure
guidata(hObject, handles);


% UIWAIT makes auxgui wait for user response (see UIRESUME)
% uiwait(handles.auxgui);


% --- Outputs from this function are returned to the command line.
function varargout = auxiliary_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function RewardValue_Callback(hObject, eventdata, handles)
% hObject    handle to RewardValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RewardValue as text
%        str2double(get(hObject,'String')) returns contents of RewardValue as a double


% --- Executes during object creation, after setting all properties.
function RewardValue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RewardValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in RewardUp.
function RewardUp_Callback(hObject, eventdata, handles)
% hObject    handle to RewardUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
currentRew = str2num(get(handles.RewardValue,'String'));
newRew = currentRew + 1;
newRew = num2str(newRew);
set(handles.RewardValue,'String',newRew)

% --- Executes on button press in RewardDown.
function RewardDown_Callback(hObject, eventdata, handles)
% hObject    handle to RewardDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
currentRew = str2num(get(handles.RewardValue,'String'));
newRew = currentRew - 1;
newRew = num2str(newRew);
set(handles.RewardValue,'String',newRew)


function FixTol_Callback(hObject, eventdata, handles)
% hObject    handle to FixTol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FixTol as text
%        str2double(get(hObject,'String')) returns contents of FixTol as a double


% --- Executes during object creation, after setting all properties.
function FixTol_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FixTol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ToleranceUp.
function ToleranceUp_Callback(hObject, eventdata, handles)
% hObject    handle to ToleranceUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
currentTol = str2num(get(handles.FixTol,'String'));
newTol = currentTol + 1;
newTol = num2str(newTol);
set(handles.FixTol,'String',newTol)

% --- Executes on button press in ToleranceDown.
function ToleranceDown_Callback(hObject, eventdata, handles)
% hObject    handle to ToleranceDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
currentTol = str2num(get(handles.FixTol,'String'));
newTol = currentTol - 1;
newTol = num2str(newTol);
set(handles.FixTol,'String',newTol)


% --- Executes on button press in viewRastersButton.
function viewRastersButton_Callback(hObject, eventdata, handles)
% hObject    handle to viewRastersButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
viewRasters();


% --- Executes on button press in endExperimentButton.
function endExperimentButton_Callback(hObject, eventdata, handles)
% hObject    handle to endExperimentButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
a = handles.a_serialobj;
a.clearLEDs();
a.endSerial();
clear
close all

% --- Executes on selection change in EventAligment_popupmenu.
function EventAligment_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to EventAligment_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns EventAligment_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from EventAligment_popupmenu


% --- Executes during object creation, after setting all properties.
function EventAligment_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EventAligment_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: EventAligment_popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
