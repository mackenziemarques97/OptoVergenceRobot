function trialLED(trialname,handles,a) %function inputs: savename of trial,
%handles, object of Arduino experiment class

%% Load the trial data/convert to struct, initialize axes in aux
% save path locations to variables for reuse 
masterFolder = 'C:\Users\SommerLab\Documents\spMaster-LED';
trialFolder = 'C:\Users\SommerLab\Documents\spMaster-LED\trials';

% change the current folder to trials folder
cd(trialFolder)
% load the trial parameters/data
load(trialname,'TrialParams');
% change the current folder to spMaster-LED
cd(masterFolder)

%get number of filled in rows (trial phases) in TrialParams
numFilledInRows = sum(~cellfun(@isempty,TrialParams),1);
numPhases = numFilledInRows(1); %number of rows with the direction filled in
numParams = numel(numFilledInRows); %total number of params (columns)
%if first element in a row exists and a subsequent element is empty
%then replace empty element with 0
%this is intended to correct any logical errors with params determined by
%checkboxes
for i = 1:numPhases
    for j = 1:numParams
        if ~isempty(TrialParams{i,1}) && isempty(TrialParams{i,j})
            TrialParams{i,j} = 0;
        end
    end
end
TrialParams = TrialParams(1:numPhases, :);

names = {'direction','color','degree','duration','fixDur','reward','withNext'};
trial = cell2struct(TrialParams,names,2);

for phaseNum = 1:numPhases
    if ~isempty(trial(phaseNum).direction)
        %convert direction and degree to x and y coordinates on auxiliary axis
        [trial(phaseNum).xCoord, trial(phaseNum).yCoord] = getPhaseCoords(trial, phaseNum); 
    end
end

ai = handles.ai;
dio = handles.dio;

auxiliary();

h = findobj(auxiliary,'Tag','Position');
auxAxes = guidata(h);
auxAxes = auxAxes.Position;
% auxAxes = get(auxAxes,'Position');

%% get updated values from auxiliary gui
    function [numrew, fixTol] = checkAux(auxiliary)
        
        h = findobj(auxiliary,'Tag','RewardValue');
        numrew = guidata(h);
        numrew = numrew.RewardValue;
        numrew = str2num(get(numrew,'String'));
        
        h = findobj(auxiliary,'Tag','FixTol');
        fixTol = guidata(h);
        fixTol = fixTol.FixTol;
        fixTol = str2num(get(fixTol,'String'));
        
    end

%% initialize viewing figure axes in auxiliary gui

axes(auxAxes);cla; %get axes from GUI
[eyePosX, eyePosY] = handles.getEyePosFunc(ai);
hFix = rectangle('Position', [0 0 1 1],'FaceColor', 'blue'); %create first rectangle
hEye = rectangle('Position', [eyePosX eyePosY 1 1],'FaceColor','red'); %create square for eye pos

    function updateViewingFigure(isWithNext)
        try
            set(hFix, 'Position', [trial(eyeCheckPhaseIndex).xCoord trial(eyeCheckPhaseIndex).yCoord 1 1]); 
            set(hEye, 'Position', [eyePosX eyePosY 1 1]);           
            if isWithNext == 1
                for ii = 1:size(viewingFigureRectangles, 2)
                    set(viewingFigureRectangles(ii), 'Position', [viewingFigureCoords(ii, 1) viewingFigureCoords(ii, 2) 1 1]);
                end
            end
            drawnow
        catch
            disp('Unable to plot axes');
        end
    end

% start the trial --> screen

a.clearLEDs(); %initalize trial by setting all LEDs to black

%% Initialize finite state structure
numPhases = size(trial, 1);
phase = 1;
while phase <= numPhases 
    if exist('viewingFigureRectangles','var')
       delete(viewingFigureRectangles);
    end
    
    eyeCheckPhaseIndex = phase;
              
    [numrew, fixTol] = checkAux(auxiliary);
    
    if isempty(trial(phase).duration) %can change to duration
        break
    end
    
    success = false;
      
    a.sendPhaseParams(convertCharsToStrings(trial(phase).direction), convertCharsToStrings(trial(phase).color), trial(phase).degree, trial(phase).duration); %WRITE FOR ARDUINO
        
    %is there more than one stimulus on screen
    viewingFigureIndex = 1;
    while trial(phase).withNext
        phase = phase + 1;
        viewingFigureRectangles(viewingFigureIndex) = rectangle('Position', [0 0 1 1],'FaceColor','green');
        viewingFigureCoords(viewingFigureIndex, :) = [trial(phase).xCoord, trial(phase).yCoord];
        viewingFigureIndex = viewingFigureIndex + 1;
        a.sendPhaseParams(convertCharsToStrings(trial(phase).direction), convertCharsToStrings(trial(phase).color), trial(phase).degree, trial(phase).duration); %WRITE FOR ARDUINO
    end
    
    a.turnOnLED(); 
        
    % check for fixation
    fix = false; % assume no fixation to start
    fixTic = tic;
    while toc(fixTic) < trial(eyeCheckPhaseIndex).duration
        pause(0.001)
        try
            [eyePosX, eyePosY] = handles.getEyePosFunc(ai);
        catch
            disp('missed eye position acquisition')
        end
        
        if exist('viewingFigureRectangles','var')           
            updateViewingFigure(1);
        else
            updateViewingFigure(0);
        end
         
        
        if abs(eyePosX - trial(eyeCheckPhaseIndex).xCoord) < fixTol && abs(eyePosY - trial(eyeCheckPhaseIndex).yCoord) < fixTol
            fix = true;
            break
        end
    end
    % check for sustained fixation
    keepFix = false;
    if fix
        keepFixTic = tic;
        while toc(keepFixTic) < trial(eyeCheckPhaseIndex).fixDur 
            pause(0.001)
            try
                [eyePosX, eyePosY] = handles.getEyePosFunc(ai);
            catch
                disp('Missed data')
            end

            if exist('viewingFigureRectangles','var')
                updateViewingFigure(1);
            else
                updateViewingFigure(0);
            end

            if abs(eyePosX - trial(eyeCheckPhaseIndex).xCoord) < fixTol && abs(eyePosY - trial(eyeCheckPhaseIndex).yCoord) < fixTol
                keepFix = true;
            else
                keepFix = false;
                break
            end
        end
    end
    a.clearLEDs();
    
    % deliver reward only if fixation was maintained AND this phase is
    %   to deliver reward
    if keepFix && trial(eyeCheckPhaseIndex).reward
        handles.deliverRewardFunc(dio, numrew)
        pause(0.002) % determine pause length between trials
        success = true;
    end
    
    phase = phase + 1;
end
end