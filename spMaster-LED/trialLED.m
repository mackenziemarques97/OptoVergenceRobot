function [experimentData,trialByTrialData] = trialLED(currentTrialName,handles,experimentData,trialByTrialData,trialCount)
    global fw viewingFigureIndex viewingFigureColor
    viewingFigureIndex = 0;
    viewingFigureColor = {};
    %% Load the trial data/convert to struct, initialize axes in aux 
    % load the trial parameters/data
    load(fullfile(handles.trialFolder,currentTrialName),'TrialParams_LED','TrialParams_robot');
    a = handles.a_serialobj;
    % set field names for LED and robot parameters in trial structures
    paramNames_LED = {'phaseNum','color','direction','visAng','duration','fixDur','ifReward','withNext'};
    paramNames_robot = {'phaseNum','color','xCoord','zCoord','vergAng','visAng','duration','ifReward','withNext'};
    % use supporting function to access and sort parameters saved in master GUI
    % tables for controlling LEDs and robot into structures
%   trialLED = sortTrialParams(TrialParams_LED,paramNames_LED);
%   trialRobot = sortTrialParams(TrialParams_robot,paramNames_robot);
    [Trial,totNumPhases,numLEDPhases,numRobotPhases,LEDPhases,robotPhases] = makeTrialStruct(TrialParams_LED,TrialParams_robot,paramNames_LED,paramNames_robot);
    
    % identify total number of phases, number of LED wall phases, and
    % number of robot phases
%     numPhases = numel(vertcat(trialLED(:).phaseNum,trialRobot(:).phaseNum));
%     numLEDPhases = numel(vertcat(trialLED(:).phaseNum));
%     numRobotPhases = numel(vertcat(trialRobot(:).phaseNum));
    %LED Wall Coordinate Location Calculation for each Phase
    % loop through each LED phase and assign x and y coordinates for each
    % lit-up LED; save coords as additional fields in trialLED structure
    for i = 1:numLEDPhases
        %convert direction and degree to x and y coordinates on auxiliary axis
        phaseNum = LEDPhases(i);
        [Trial(phaseNum).phases.xCoord, Trial(phaseNum).phases.yCoord] = getLEDPhaseCoords(Trial, phaseNum); 
    end
    % Robot Location Calculation for each Phase
    % loop through each robot phase and calculate Dx and Dz in cm from the
    % vergence angle and interpupillary distance inputs on the main GUI;
    % save distances as additional fields in trialRobot structure
    Circ = 2*pi*0.65; % cm
    stepsPerRev = 200;
    uStepsPerStep = 16;
    for i = 1:numRobotPhases
        phaseNum = robotPhases(i);
        Trial(phaseNum).phases.xCoord_uSteps = (Trial(phaseNum).phases.xCoord/Circ)*stepsPerRev*uStepsPerStep;
        Trial(phaseNum).phases.zCoord_uSteps = (Trial(phaseNum).phases.zCoord/Circ)*stepsPerRev*uStepsPerStep;
        %       vergAng = trialRobot(phaseNum).vergAng;
%       visAng = trialRobot(phaseNum).visAng;            
%       xCoord = trialRobot(phaseNum).xCoord;
%       zCoord = trialRobot(phaseNum).zCoord;
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
    phase = 1;
    while phase <= totNumPhases

        eyeCheckPhaseIndex = phase;
       
        %%CHECK IF PHASE IS LED BOARD OR ROBOT 
        for i = 1:numLEDPhases
            if phase == LEDPhases(i) && phase == eyeCheckPhaseIndex
                [numrew, fixTol] = checkAux(auxiliary);
                
                success = false;
                
                if Trial(eyeCheckPhaseIndex).phases.withNext
                    for phaseCount = eyeCheckPhaseIndex:eyeCheckPhaseIndex+1
                        trialByTrialData(trialCount).direction{phaseCount} = Trial(phaseCount).phases.direction;
                        trialByTrialData(trialCount).color{phaseCount} = Trial(phaseCount).phases.color;
                        trialByTrialData(trialCount).degree{phaseCount} = Trial(phaseCount).phases.visAng;
                        trialByTrialData(trialCount).phaseTargetLoc{phaseCount} = [Trial(phaseCount).phases.xCoord, Trial(phaseCount).phases.yCoord];
                        trialByTrialData(trialCount).duration{phaseCount} = Trial(phaseCount).phases.duration;
                        trialByTrialData(trialCount).fixDur{phaseCount} = Trial(phaseCount).phases.fixDur;
                        trialByTrialData(trialCount).ifReward{phaseCount} = Trial(phaseCount).phases.ifReward;
                        trialByTrialData(trialCount).withNext{phaseCount} = Trial(phaseCount).phases.withNext;
                        trialByTrialData(trialCount).rewardAmount{phaseCount} = numrew;
                        trialByTrialData(trialCount).fixationTolerance{phaseCount} = fixTol;
                        trialByTrialData(trialCount).ifSuccess{phaseCount} = success;
                    end
                else
                    trialByTrialData(trialCount).direction{phase} = Trial(phase).phases.direction;
                    trialByTrialData(trialCount).color{phase} = Trial(phase).phases.color;
                    trialByTrialData(trialCount).degree{phase} = Trial(phase).phases.visAng;
                    trialByTrialData(trialCount).phaseTargetLoc{phase} = [Trial(phase).phases.xCoord, Trial(phase).phases.yCoord];
                    trialByTrialData(trialCount).duration{phase} = Trial(phase).phases.duration;
                    trialByTrialData(trialCount).fixDur{phase} = Trial(phase).phases.fixDur;
                    trialByTrialData(trialCount).ifReward{phase} = Trial(phase).phases.ifReward;
                    trialByTrialData(trialCount).withNext{phase} = Trial(phase).phases.withNext;
                    trialByTrialData(trialCount).rewardAmount{phase} = numrew;
                    trialByTrialData(trialCount).fixationTolerance{phase} = fixTol;
                    trialByTrialData(trialCount).ifSuccess{phase} = success;
                end
                
                %is there more than one stimulus on screen
                viewingFigureIndex = 1;
                
                viewingFigureRectangles(viewingFigureIndex) = rectangle('Position', [-0.5 -0.5 1 1],'FaceColor','none','EdgeColor','none');
                viewingFigureCoords(viewingFigureIndex, :) = [Trial(phase).phases.xCoord, Trial(phase).phases.yCoord];
                viewingFigureColor{viewingFigureIndex} = Trial(phase).phases.color;
                
                a.sendLEDPhaseParams(convertCharsToStrings(Trial(phase).phases.direction), convertCharsToStrings(Trial(phase).phases.color), Trial(phase).phases.visAng); %WRITE FOR ARDUINO
                while Trial(phase).phases.withNext
                    %withNextTracker = 1;
                    phase = phase + 1;
                    viewingFigureIndex = viewingFigureIndex + 1;
                    viewingFigureRectangles(viewingFigureIndex) = rectangle('Position', [-0.5 -0.5 1 1],'FaceColor','none','EdgeColor','none');
                    viewingFigureCoords(viewingFigureIndex, :) = [Trial(phase).phases.xCoord, Trial(phase).phases.yCoord];
                    viewingFigureColor{viewingFigureIndex} = Trial(phase).phases.color;
                    a.sendLEDPhaseParams(convertCharsToStrings(Trial(phase).phases.direction), convertCharsToStrings(Trial(phase).phases.color), Trial(phase).phases.visAng); %WRITE FOR ARDUINO
                end
                tstart(trialCount) = tic 
                a.turnOnLED();
                % check for fixation
                fix = false; % assume no fixation to start
                fixTic = tic;
                while toc(fixTic) < Trial(eyeCheckPhaseIndex).phases.duration
                    pause(0.001)
                    [eyePosX, eyePosY] = handles.getEyePosFunc();
                    updateViewingFigure();
                    if abs(eyePosX - Trial(eyeCheckPhaseIndex).phases.xCoord) < fixTol && abs(eyePosY - Trial(eyeCheckPhaseIndex).phases.yCoord) < fixTol
                        fix = true;
                        break
                    end
                end
                % check for sustained fixation
                keepFix = false;
                if fix
                    keepFix = true;
                    keepFixTic = tic;
                    while toc(keepFixTic) < Trial(eyeCheckPhaseIndex).phases.fixDur
                        pause(0.002)
                        [eyePosX, eyePosY] = handles.getEyePosFunc();
                        updateViewingFigure();
                        if abs(eyePosX - Trial(eyeCheckPhaseIndex).phases.xCoord) < fixTol && abs(eyePosY - Trial(eyeCheckPhaseIndex).phases.yCoord) < fixTol
                            keepFix = true;
                        else
                            keepFix = false;
                            break
                        end
                    end
                end
                a.clearLEDs();
                tend = toc(tstart(trialCount))
                delete(viewingFigureRectangles);
                viewingFigureIndex = 0;
                updateViewingFigure()
                pause(0.002)
            end 
        end
        for i = 1:numRobotPhases
            if phase == robotPhases(i)
                success = false;
                %expIdx = find(strcmp(currentTrialName(1:end-4),experimentData.experimentParameters));
                %if trialCount
                a.sendRobotPhaseParams(convertCharsToStrings(Trial(phase).phases.color),Trial(phase).phases.xCoord_uSteps,Trial(phase).phases.zCoord_uSteps,Trial(phase).phases.duration,phase,robotPhases(1),robotPhases(end));
                keepFix = false;
            end
        end

        % deliver reward only if fixation was maintained AND this phase is
        % to deliver reward
        if ~keepFix && Trial(eyeCheckPhaseIndex).phases.ifReward
            break            
        end
        if keepFix && Trial(eyeCheckPhaseIndex).phases.ifReward
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
        if Trial(eyeCheckPhaseIndex).phases.withNext==1
            for phaseCount = eyeCheckPhaseIndex:eyeCheckPhaseIndex+1     
                trialByTrialData(trialCount).ifSuccess{phaseCount} = success;
            end
        else 
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