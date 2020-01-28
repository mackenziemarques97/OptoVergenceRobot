function trialLED(trialname,handles)
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

names = {'direction','color','degree','duration','fixDur','reward','withNext'};
trial = cell2struct(TrialParams,names,2);

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
hFix = rectangle('Position', [0 0 1 1],'FaceColor','blue'); %create square for target
hEye = rectangle('Position', [eyePosX eyePosY 1 1],'FaceColor','red'); %create square for eye pos

    function updateViewingFigure()
        try
            set(hFix, 'Position', [trial(phase).xCoord trial(phase).yCoord 1 1]);
            set(hEye, 'Position', [eyePosX eyePosY 1 1]);
            
            drawnow
        catch
            disp('Unable to plot axes');
        end
    end

% start the trial --> screen
%INITIALIZE TRIAL BY SETTING ALL LEDS TO BLACK?
%%
% Arduino system setup
%In Arduino sketch, when Arduino is connected to computer, go to Tools>Port
%to find COM port you are connected to. If necessary, update string stored
%in serialPort accordingly.
serialPort = 'COM6';
a = ExperimentClass_GUI_LEDboard(serialPort); %create an object of the class to use it
%%

a.clearLEDs();
startTrial = tic;

%% Initialize finite state structure
numPhases = size(trial, 1);
phase = 1;
while phase < numPhases   
    
    eyeCheckPhaseIndex = phase;
        
    %convert direction and degree to x and y coordinates on auxiliary axis
    if strcmp(trial(phase).direction, 'N')
        trial(phase).xCoord = 0;
        trial(phase).yCoord = trial(phase).degree;
    elseif strcmp(trial(phase).direction, 'S')
        trial(phase).xCoord = 0;
        trial(phase).yCoord = -trial(phase).degree;
    elseif strcmp(trial(phase).direction, 'E')
        trial(phase).xCoord = trial(phase).degree;
        trial(phase).yCoord = 0;
    elseif strcmp(trial(phase).direction, 'W')
        trial(phase).xCoord = -trial(phase).degree;
        trial(phase).yCoord = 0;
    elseif strcmp(trial(phase).direction, 'NW')
        trial(phase).xCoord = -trial(phase).degree * cosd(45);
        trial(phase).yCoord = trial(phase).degree * sind(45);
    elseif strcmp(trial(phase).direction, 'NE')
        trial(phase).xCoord = trial(phase).degree * cosd(45);
        trial(phase).yCoord = trial(phase).degree * sind(45);
    elseif strcmp(trial(phase).direction, 'SW')
        trial(phase).xCoord = -trial(phase).degree * cosd(45);
        trial(phase).yCoord = -trial(phase).degree * sind(45);
    elseif strcmp(trial(phase).direction, 'SE')
        trial(phase).xCoord = trial(phase).degree * cosd(45);
        trial(phase).yCoord = -trial(phase).degree * sind(45);
    end
    
    [numrew, fixTol] = checkAux(auxiliary);
    
    if isempty(trial(phase).duration) %can change to duration
        break
    end
    
    success = false;
      
    a.sendPhaseParams(convertCharsToStrings(trial(phase).direction), convertCharsToStrings(trial(phase).color), trial(phase).degree, trial(phase).duration); %WRITE FOR ARDUINO
    
    %is there more than one stimulus on screen
    while trial(phase).withNext
        phase = phase + 1;
        a.sendPhaseParams(convertCharsToStrings(trial(phase).direction), convertCharsToStrings(trial(phase).color), trial(phase).degree, trial(phase).duration); %WRITE FOR ARDUINO
    end
    
    fprintf('phase is %d', phase);
    trialShowTic = tic;
    a.turnOnLED(); %SWITCH TO ARDUINO COMMAND
    
    %THINK OF WAY TO VERIFY THAT LED CAME ON?
    
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
        
        updateViewingFigure();
        
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

            updateViewingFigure();

            if abs(eyePosX - trial(eyeCheckPhaseIndex).xCoord) < fixTol && abs(eyePosY - trial(eyeCheckPhaseIndex).yCoord) < fixTol
                keepFix = true;
            else
                keepFix = false;
                break
            end
        end
    end
    a.clearLEDs();
    y = toc(trialShowTic)
    
    % deliver reward only if fixation was maintained AND this phase is
    %   to deliver reward
    if keepFix && trial(eyeCheckPhaseIndex).reward
        handles.deliverRewardFunc(dio, numrew)
        pause(2) % determine pause length between trials
        success = true;
    end
    
    phase = phase + 1;
end

a.endSerial(); %end serial connection with Arduino

end