function trial(trialname,window,handles)
%% Load the trial data/convert to struct, initialize axes in aux
%cd /Users/Sarah Proctor/Desktop/master/trials       % for mac
cd C:\Users\SommerLab\Documents\spMaster\experiments    % for pc
load(trialname,'TrialParams');
%cd /Users/Sarah Proctor/Desktop/master
cd C:\Users\SommerLab\Documents\spMaster

names = {'shape','color','size','xLoc','yLoc','duration','fixDur','reward','withNext'};
trial = cell2struct(TrialParams,names,2);

ai = handles.ai;
dio = handles.dio;
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

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
axis([-(screenXpixels/2) (screenXpixels/2) -(screenYpixels/2) (screenYpixels/2)]); %axis limits

[eyePosX, eyePosY] = handles.getEyePosFunc(ai);
hFix = rectangle('Position', [0, 0 20 20],'FaceColor','blue'); %create square for target
hEye = rectangle('Position', [eyePosX, eyePosY 20 20],'FaceColor','red'); %create square for eye pos

    function updateViewingFigure()
        try
            set(hFix, 'Position', [trial(phase).xLoc trial(phase).yLoc 20 20]);
            set(hEye, 'Position', [eyePosX eyePosY 20 20]);
            
            drawnow
        catch
            disp('Unable to plot axes');
        end
    end

%% misc trial data setup
% start the trial --> screen
Screen(window, 'FillRect', black); Screen(window, 'Flip');
startTrial = tic;

%% Initialize finite state structure
numPhases = size(trial, 1);

phase = 1;
while phase < numPhases   
    [numrew, fixTol] = checkAux(auxiliary);
    
    if isempty(trial(phase).shape) %can change to duration
        break
    end
    
    success = false;  

    drawPhase(trial, phase);
         
    %is there more than one stimulus on screen 
    while trial(phase).withNext 
        phase = phase + 1;
        drawPhase(trial, phase);     
    end   
       
    Screen(window,'Flip');

    % check for fixation
    fix = false; % assume no fixation to start
    fixTic = tic;
    while toc(fixTic) < trial(phase).duration
        pause(0.001)
        try
            [eyePosX, eyePosY] = handles.getEyePosFunc(ai);
        catch
            disp('missed eye position acquisition')
        end
        
        updateViewingFigure();
        
        if abs(eyePosX - trial(phase).xLoc) < fixTol && abs(eyePosY - trial(phase).yLoc) < fixTol
            fix = true;
            break
        end
    end
    % check for sustained fixation
    keepFix = false;
    if fix
        keepFixTic = tic;
        while toc(keepFixTic) < trial(phase).fixDur 
            pause(0.001)
            try
                [eyePosX, eyePosY] = handles.getEyePosFunc(ai);
            catch
                disp('Missed data')
            end

            updateViewingFigure();

            if abs(eyePosX - trial(phase).xLoc) < fixTol && abs(eyePosY - trial(phase).yLoc) < fixTol
                keepFix = true;
            else
                keepFix = false;
                break
            end
        end
    end
    % deliver reward only if fixation was maintained AND this phase is
    %   to deliver reward
    if keepFix && trial(phase).reward
        handles.deliverRewardFunc(dio, numrew)
        pause(2) % determine pause length between trials
        success = true;
    end

end

end

