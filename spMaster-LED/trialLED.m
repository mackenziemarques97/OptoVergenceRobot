function [experimentData,trialByTrialData] = trialLED(currentTrialName,handles,experimentData,trialByTrialData,trialCount) %function inputs: savename of trial,
    %handles, object of Arduino experiment class
    global fw viewingFigureIndex viewingFigureColor
    viewingFigureIndex = 0;
    viewingFigureColor = {};
    %% Load the trial data/convert to struct, initialize axes in aux 
    % load the trial parameters/data
    load(fullfile(handles.trialFolder,currentTrialName),'TrialParams');
    a = handles.a_serialobj;
    
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

    names = {'direction','color','degree','duration','fixDur','ifReward','withNext'};
    trial = cell2struct(TrialParams,names,2);

    for phaseNum = 1:numPhases
        if ~isempty(trial(phaseNum).direction)
            %convert direction and degree to x and y coordinates on auxiliary axis
            [trial(phaseNum).xCoord, trial(phaseNum).yCoord] = getPhaseCoords(trial, phaseNum); 
        end
    end

    ai = handles.ai;
    dio = handles.dio;
    
    % save the object "a" that contains serial connection in app data
    % to be able to access it in auxiliary GUI
    mainGUI = findobj('Tag','MASTERLEDfigure');
    setappdata(mainGUI,'a',handles.a_serialobj)
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
    [eyePosX, eyePosY] = handles.getEyePosFunc();
    hEye = rectangle('Position', [eyePosX-0.5 eyePosY-0.5 1 1],'FaceColor','green','Curvature',[1 1]); %create square for eye pos

        function updateViewingFigure()
            try
                set(hEye, 'Position', [eyePosX-0.5 eyePosY-0.5 1 1]);  
                for ii = 1:viewingFigureIndex
                    set(viewingFigureRectangles(ii), 'Position', [viewingFigureCoords(ii, 1)-0.5 viewingFigureCoords(ii, 2)-0.5 1 1],'FaceColor',viewingFigureColor{ii});
                end
                drawnow
            catch
                disp('Unable to plot axes');
            end
        end

    % start the trial --> screen
    
    a.clearLEDs(); %initalize trial by setting all LEDs to black
    fw_prev = fw;
    fw = fopen(fullfile(handles.data_main_dir,'Data.bin'),'w');
    fclose(fw_prev);
    pause(.010);

    %% Initialize finite state structure
    numPhases = size(trial, 1);
    phase = 1;
    while phase <= numPhases

        eyeCheckPhaseIndex = phase;
        
        [numrew, fixTol] = checkAux(auxiliary);

        if isempty(trial(phase).duration)
            break
        end

        success = false;

        %is there more than one stimulus on screen
        viewingFigureIndex = 1;
        
        viewingFigureRectangles(viewingFigureIndex) = rectangle('Position', [-0.5 -0.5 1 1],'FaceColor','none','EdgeColor','none');
        viewingFigureCoords(viewingFigureIndex, :) = [trial(phase).xCoord, trial(phase).yCoord];
        viewingFigureColor{viewingFigureIndex} = trial(phase).color;
        a.sendPhaseParams(convertCharsToStrings(trial(phase).direction), convertCharsToStrings(trial(phase).color), trial(phase).degree); %WRITE FOR ARDUINO
        while trial(phase).withNext
            phase = phase + 1;
            viewingFigureIndex = viewingFigureIndex + 1;
            viewingFigureRectangles(viewingFigureIndex) = rectangle('Position', [-0.5 -0.5 1 1],'FaceColor','none','EdgeColor','none');
            viewingFigureCoords(viewingFigureIndex, :) = [trial(phase).xCoord, trial(phase).yCoord];
            viewingFigureColor{viewingFigureIndex} = trial(phase).color;
            a.sendPhaseParams(convertCharsToStrings(trial(phase).direction), convertCharsToStrings(trial(phase).color), trial(phase).degree); %WRITE FOR ARDUINO
        end
        
        a.turnOnLED(); 
        % check for fixation
        fix = false; % assume no fixation to start
        fixTic = tic;
        while toc(fixTic) < trial(eyeCheckPhaseIndex).duration
            pause(0.001)
            [eyePosX, eyePosY] = handles.getEyePosFunc();
            updateViewingFigure();
            if abs(eyePosX - trial(eyeCheckPhaseIndex).xCoord) < fixTol && abs(eyePosY - trial(eyeCheckPhaseIndex).yCoord) < fixTol
                fix = true;
                break
            end
        end
        % check for sustained fixation
        keepFix = false;
        if fix
            keepFix = true;
            keepFixTic = tic;
            while toc(keepFixTic) < trial(eyeCheckPhaseIndex).fixDur
                pause(0.002)
                [eyePosX, eyePosY] = handles.getEyePosFunc();
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
        delete(viewingFigureRectangles);
        viewingFigureIndex = 0;
        updateViewingFigure()
        pause(0.002)

        % deliver reward only if fixation was maintained AND this phase is
        % to deliver reward
        if ~keepFix && trial(eyeCheckPhaseIndex).ifReward
            break            
        end
        if keepFix && trial(eyeCheckPhaseIndex).ifReward
            for r = 1:numrew
            handles.deliverRewardFunc(dio)
            interRewardTic = tic;
                while toc(interRewardTic) < 0.100
                [eyePosX, eyePosY] = handles.getEyePosFunc();
                updateViewingFigure()
                pause(0.002)
                end
            end
        success = true;
        end
        %Save experiment data
        if trial(eyeCheckPhaseIndex).withNext==1
            for phaseCount = eyeCheckPhaseIndex:eyeCheckPhaseIndex+1;     
                trialByTrialData(trialCount).direction{phaseCount} = trial(phaseCount).direction;
                trialByTrialData(trialCount).color{phaseCount} = trial(phaseCount).color;    
                trialByTrialData(trialCount).degree{phaseCount} = trial(phaseCount).degree; 
                trialByTrialData(trialCount).phaseTargetLoc{phaseCount} = [trial(phaseCount).xCoord, trial(phaseCount).yCoord];
                trialByTrialData(trialCount).duration{phaseCount} = trial(phaseCount).duration;
                trialByTrialData(trialCount).fixDur{phaseCount} = trial(phaseCount).fixDur;
                trialByTrialData(trialCount).ifReward{phaseCount} = trial(phaseCount).ifReward;
                trialByTrialData(trialCount).withNext{phaseCount} = trial(phaseCount).withNext; 
                trialByTrialData(trialCount).rewardAmount{phaseCount} = numrew;
                trialByTrialData(trialCount).fixationTolerance{phaseCount} = fixTol;
                trialByTrialData(trialCount).ifSuccess{phaseCount} = success;
            end
        else
            trialByTrialData(trialCount).direction{phase} = trial(phase).direction;
            trialByTrialData(trialCount).color{phase} = trial(phase).color;    
            trialByTrialData(trialCount).degree{phase} = trial(phase).degree; 
            trialByTrialData(trialCount).phaseTargetLoc{phase} = [trial(phase).xCoord, trial(phase).yCoord];
            trialByTrialData(trialCount).duration{phase} = trial(phase).duration;
            trialByTrialData(trialCount).fixDur{phase} = trial(phase).fixDur;
            trialByTrialData(trialCount).ifReward{phase} = trial(phase).ifReward;
            trialByTrialData(trialCount).withNext{phase} = trial(phase).withNext; 
            trialByTrialData(trialCount).rewardAmount{phase} = numrew;
            trialByTrialData(trialCount).fixationTolerance{phase} = fixTol;
            trialByTrialData(trialCount).ifSuccess{phase} = success;  
        end
        phase = phase + 1;       
    end
    
    %Save off DAQ card data
    %Throw warning for overwriting
    filename = fullfile(handles.data_path,[handles.trial_prefix,'DAQ.mat']);
    if isfile(filename)
       warning(['Overwriting file at ',filename]);
    end
    data = krGetTrialSpikes(handles.data_main_dir);
    save(filename,'data')
    cd(handles.data_path);
    save('trialByTrialData','trialByTrialData');
    save('experimentData','experimentData');
end