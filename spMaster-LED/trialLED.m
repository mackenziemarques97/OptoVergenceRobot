function [experimentData,trialByTrialData] = trialLED(currentTrialName,handles,experimentData,trialByTrialData,trialCount,totTrials)
    global fw viewingFigureIndex viewingFigureColor
    viewingFigureIndex = 0;
    viewingFigureColor = {};
    %% Load the trial data/convert to struct, initialize axes in aux 
    % load the trial parameters/data
    load(fullfile(handles.trialFolder,currentTrialName),'TrialParams_LED','TrialParams_robot');
    a = handles.a_serialobj;
    % set field names for LED and robot parameters in trial structures
    paramNames_LED = {'phaseNum','color','direction','visAng','duration','fixDur','ifReward','withNext','fixTol','numRew'};
    paramNames_robot = {'phaseNum','color','xCoord','zCoord','vergAng','visAng','moveDur','LEDdur','ifReward','withNext'};
    % use supporting function to access and sort parameters saved in master GUI
    % tables for controlling LEDs and robot into structure
    [Trial,totNumPhases,numLEDPhases,numRobotPhases,LEDPhases,robotPhases] = makeTrialStruct(TrialParams_LED,TrialParams_robot,paramNames_LED,paramNames_robot);
    
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
    end
    timeout = get(handles.timeout_checkbox,'Value');
    
    ai = handles.ai;
    dio = handles.dio;
    
    % save the object "a" that contains serial connection in app data
    % to be able to access it in auxiliary GUI
    mainGUI = findobj('Tag','MASTERLEDfigure');

    setappdata(mainGUI,'a',handles.a_serialobj)
    setappdata(mainGUI,'TrialParams_LED',TrialParams_LED)
    setappdata(mainGUI,'TrialParams_robot',TrialParams_robot)
    
    %run auxiliary GUI for tracking 2D eye movements for LED board
    auxiliary();

    h = findobj(auxiliary,'Tag','Position');
    auxAxes = guidata(h);
    auxAxes = auxAxes.Position;
    %% get updated values from auxiliary gui
        function [numrew, fixTol] = checkAux(auxiliary,Trial,phase)

            h = findobj(auxiliary,'Tag','RewardValue');
            %access handles from auxiliary GUI
            auxHandles = guidata(h);
            %if a new reward value has been added by aux GUI and if that
            %value is not the same as the currently saved one
            if isfield(auxHandles,'newRew') && str2double(auxHandles.newRew)~=Trial(phase).phases.numRew
                %update currently saved reward value
                Trial(phase).phases.numRew = str2double(auxHandles.newRew);
                %update value shown on main GUI table
                TrialParams_LED = auxHandles.TrialParams_LED;
                %update save file with changes
                save(fullfile(handles.trialFolder,currentTrialName),'TrialParams_LED','TrialParams_robot')
            end
            %show changes on aux GUI
            set(auxHandles.RewardValue,'String',Trial(phase).phases.numRew)
            %save value for output
            numrew = Trial(phase).phases.numRew;
            %if a new fix tolerance value has been added by aux GUI and if that
            %value is not the same as the currently saved one
            if isfield(auxHandles,'newTol') && auxHandles.newTol~=Trial(phase).phases.fixTol
                %update currently saved reward value
                Trial(phase).phases.fixTol = str2double(auxHandles.newTol);
                %update value shown on main GUI table
                TrialParams_LED = auxHandles.TrialParams_LED;
                %update save file with changes
                save(fullfile(handles.trialFolder,currentTrialName),'TrialParams_LED','TrialParams_robot')
            end
            %show changes on aux GUI
            set(auxHandles.FixTol,'String',Trial(phase).phases.fixTol)
            %save value for output
            fixTol = Trial(phase).phases.fixTol;
        end
    %% initialize viewing figure axes in auxiliary gui
    %access axes from GUI and clear them
    axes(auxAxes);cla; 
    %get eye position
    [eyePosX, eyePosY] = handles.getEyePosFunc();
    %create marker on auxiliary GUI to track eye position
    hEye = rectangle('Position', [eyePosX-0.5 eyePosY-0.5 1 1],'FaceColor','green','Curvature',[1 1]); %create square for eye pos

        function updateViewingFigure()
            try
                %initialize eye position marker to the center
                set(hEye, 'Position', [eyePosX-0.5 eyePosY-0.5 1 1]); 
                %update position based on phase coordinates and withNext
                %state
                for ii = 1:viewingFigureIndex
                    set(viewingFigureRectangles(ii), 'Position', [viewingFigureCoords(ii, 1)-0.5 viewingFigureCoords(ii, 2)-0.5 1 1],'FaceColor',viewingFigureColor{ii});
                end
                %show changes
                drawnow
            catch
                disp('Unable to plot axes');
            end
        end
    
    %initalize trial by setting all LEDs to black
    a.clearLEDs();
    %update fileID for saving data
    fw_prev = fw;
    fw = fopen(fullfile(handles.data_main_dir,'Data.bin'),'w');
    fclose(fw_prev);
    pause(.010);

    %% Initialize finite state structure
    phase = 1;
    %while the current phase is less than the total number of phases
    while phase <= totNumPhases
        %create index to keep track of phase where eyePos is checked
        %this is relevant for trials with withNext phases
        eyeCheckPhaseIndex = phase;
       
        %loop through LED phases
        for i = 1:numLEDPhases
            %if the current phase is an LED phase and phase to check eyePos
            if phase == LEDPhases(i) && phase == eyeCheckPhaseIndex
                %check aux GUI for reward number and fixation tolerance
                [numrew, fixTol] = checkAux(auxiliary,Trial,phase);
                %inialize success logical to false
                success = false;
                %save trial parameters/information
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
                
                %if there is more than one stimulus on screen
                viewingFigureIndex = 1;
                
                viewingFigureRectangles(viewingFigureIndex) = rectangle('Position', [-0.5 -0.5 1 1],'FaceColor','none','EdgeColor','none');
                viewingFigureCoords(viewingFigureIndex, :) = [Trial(phase).phases.xCoord, Trial(phase).phases.yCoord];
                viewingFigureColor{viewingFigureIndex} = Trial(phase).phases.color;
                %send LED board parameters to Arduino
                a.sendLEDPhaseParams(convertCharsToStrings(Trial(phase).phases.direction), convertCharsToStrings(Trial(phase).phases.color), Trial(phase).phases.visAng); %WRITE FOR ARDUINO
                %if the current phase is withNext
                while Trial(phase).phases.withNext
                    phase = phase + 1;
                    viewingFigureIndex = viewingFigureIndex + 1;
                    viewingFigureRectangles(viewingFigureIndex) = rectangle('Position', [-0.5 -0.5 1 1],'FaceColor','none','EdgeColor','none');
                    viewingFigureCoords(viewingFigureIndex, :) = [Trial(phase).phases.xCoord, Trial(phase).phases.yCoord];
                    viewingFigureColor{viewingFigureIndex} = Trial(phase).phases.color;
                    a.sendLEDPhaseParams(convertCharsToStrings(Trial(phase).phases.direction), convertCharsToStrings(Trial(phase).phases.color), Trial(phase).phases.visAng); %WRITE FOR ARDUINO
                end
                %signal Arduino to turn on LEDs
                a.turnOnLED();
                % check for fixation
                % assume no fixation to start
                fix = false; 
                %start fixation timer
                fixTic = tic;
                while toc(fixTic) < Trial(eyeCheckPhaseIndex).phases.duration
                    pause(0.001)
                    [eyePosX, eyePosY] = handles.getEyePosFunc();
                    updateViewingFigure();
                    %if eye position is within fixation tolerance window
                    if abs(eyePosX - Trial(eyeCheckPhaseIndex).phases.xCoord) < fixTol && abs(eyePosY - Trial(eyeCheckPhaseIndex).phases.yCoord) < fixTol
                        %fixation achieved
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
                delete(viewingFigureRectangles);
                viewingFigureIndex = 0;
                updateViewingFigure()
                pause(0.002)
                if ~keepFix && timeout
                    pause(str2double(handles.timeout_editbox.String))
                end
            end 
        end
        %loop through robot phases
        for i = 1:numRobotPhases
            if phase == robotPhases(i)
                %NEED TO USE EYE POS TO DETERMINE SUCCESS/FAIL CONDITIONS
                success = false;
                a.sendRobotPhaseParams(convertCharsToStrings(Trial(phase).phases.color),Trial(phase).phases.xCoord_uSteps,Trial(phase).phases.zCoord_uSteps,Trial(phase).phases.moveDur,Trial(phase).phases.LEDdur,phase,robotPhases(1),robotPhases(end),trialCount,1,totTrials)
                if Trial(phase).phases.LEDdur == 0 && ~strcmp(Trial(phase).phases.color,'none') && phase == robotPhases(end) && trialCount == totTrials
                    a.turnOffRobotLED(Trial(phase).phases.color);
                end
                keepFix = true;
            end
        end

        % deliver reward only if fixation was maintained AND this phase is
        % marked to deliver reward
        %if fixation not maintained for desired amount of time
        if ~keepFix
            %break from trial
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