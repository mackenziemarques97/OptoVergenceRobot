function viewTask(handles)
    %% get 
    t = handles.t; %tcp/ip handle
    TERMINATOR_DOUBLE = 9999;
    task = get(handles.taskSelect, 'Value');

    %% get axes from GUI and set limits
    cla;
    axes(handles.EyePos); 
    axis([(-1920/2) (1920/2) (-1080/2) (1080/2)]); %axes limits set to the resolution of the screen
    if task == 1 || task == 2 || task == 3 %1 = direction, 2 = amplitude, 3 = memory
        hEye = rectangle('Position', [5, 5, 20, 20],'FaceColor','red');
        hFix = rectangle('Position', [0, 0, 20, 20],'FaceColor','blue'); %x,y,w,h
        hTarg = rectangle('Position', [0, 0, 20, 20],'FaceColor','black');
    elseif task == 4 %4 = ssd
        hEye = rectangle('Position', [0, 0 20 20],'FaceColor','red');
        hFix = rectangle('Position', [20, 20 20 20],'FaceColor','blue'); %x,y,w,h
        hTarg = rectangle('Position', [0, 0 20 20], 'Curvature', [1 1], 'FaceColor','black'); %circle for probe
    end
    
    %% update viewing figure
    trialNum = 1; 
    while get(handles.Start, 'Value') == 1 %while start button is on 
        while(t.BytesAvailable < 9) 
            pause(0.002)
        end       
        
        %read data depending on task
        if task == 1 || task == 2 || task == 3 %1 = direction, 2 = amplitude, 3 = memory
            data = fread(t, 9, 'double'); %[xFix yFix xTarg yTarg xEye yEye trialcounter nTrials terminator];
            if(data(9) < TERMINATOR_DOUBLE)
                disp('Exception - no data found')
                break
            end
        elseif task == 4 %4 = ssd
            data = fread(t, 11, 'double'); %[xFix yFix xTarg yTarg xEye yEye trialcounter nTrials priorVal noiseVal terminator];
            if(data(11) < TERMINATOR_DOUBLE)
                disp('Exception - no data found')
                break
            end
        end 
        
        %get axis position values from received data
        xLocFix = data(1);
        yLocFix = data(2);
        xTargLoc = data(3);
        yTargLoc = data(4);
        xEyePos = data(5);
        yEyePos = data(6);
        nTrials = data(8);
        
        %set current trial number to GUI
        currTrial = data(7);
        set(handles.CurrTrial,'String',num2str(currTrial));

        %plot to axes based on task
        if task == 1 || task == 2 || task == 3 %1 = direction, 2 = amplitude, 3 = memory
            set(hFix, 'Position', [xLocFix yLocFix 20 20]); %fixation square
            set(hTarg, 'Position', [xTargLoc yTargLoc 20 20]); %target square
            set(hEye, 'Position', [xEyePos, yEyePos, 20 20]); %eye position square
        elseif task == 4 %4 = ssd
            color = data(9);
            probeSigma = data(10);
            %fixation/target square
            if color == 1 %baseline 
                squareColor = [0 0 0];
            elseif color == 2 %low prior
                squareColor = [1 165/255 0]; %orange
            elseif color == 3 %high prior          
                squareColor = [0 0 1]; %orange
            end
            set(hFix, 'Position', [xLocFix yLocFix 25 25], 'FaceColor', squareColor);
            
            %probe circle           
            set(hTarg, 'Position', [xTargLoc yTargLoc probeSigma probeSigma]);
            
            %eye position square
             set(hEye, 'Position', [xEyePos, yEyePos, 25 25]);
        end 

        %%
        isClear = get(handles.ClearRast, 'Value');
        if get(handles.viewRasters, 'Value') %if viewing rasters        
            if ~exist('rasterFig') || ~exist('sdfFig')
                [rasterFig, sdfFig, sdfLimit] = createFig(task, nTrials);
            end
            if task == 1 %dir
                rasterFolderName = strcat('Z:\Raster files\Skwiz\Dir\', date);
                cd(rasterFolderName)
                d = dir;
            elseif task == 2 %amp
                rasterFolderName = strcat('Z:\Raster files\Skwiz\Amp\', date);
                cd(rasterFolderName)
                d = dir;
            elseif task == 3 %mem
                rasterFolderName = strcat('Z:\Raster files\Skwiz\Mem\', date);
                cd(rasterFolderName)
                d = dir;
            elseif task == 4 %ssd
                rasterFolderName = strcat('Z:\Raster files\Skwiz\SSD\', date);
                cd(rasterFolderName)
                trialParamsFile = [rasterFolderName, '\trialParams_', date];
                load(trialParamsFile, 'trialParams')
                d = dir;
            end
            
            if task == 1 %dir
                if isfile(strcat('rasterData_', num2str(trialNum+1), '.mat'))
                    fname = strcat('rasterData_', num2str(trialNum), '.mat');
                    load(fname, 'rasterData')
                    sessionDataFile = d(3).name;
                    load(sessionDataFile, 'sessionData')
                    if sessionData.successTrials(trialNum) == 1
                        targLocInd = sessionData.targNumStore(trialNum);
                        [rasterFig, sdfFig, sdfLimit] = dirRaster(nTrials, rasterData, targLocInd, isClear, rasterFig, sdfFig, sdfLimit);
                    end
                    trialNum = trialNum + 1;
                end
            elseif task == 2 %amp
                if isfile(strcat('rasterData_', num2str(trialNum+1), '.mat'))
                    fname = strcat('rasterData_', num2str(trialNum), '.mat');
                    load(fname, 'rasterData')
                    sessionDataFile = d(3).name;
                    load(sessionDataFile, 'sessionData')
                    if sessionData.successTrials(trialNum) == 1
                        targAmp = sqrt((sessionData.targAmpStore(trialNum, 1)^2)+(sessionData.targAmpStore(trialNum, 2)^2));
                        [rasterFig, sdfFig, sdfLimit] = ampRaster(nTrials, rasterData, targAmp, isClear, rasterFig, sdfFig, sdfLimit);
                    end
                    trialNum = trialNum + 1;
                end
            elseif task == 3 %mem
                if isfile(strcat('rasterData_', num2str(trialNum+1), '.mat'))
                    fname = strcat('rasterData_', num2str(trialNum), '.mat');
                    load(fname, 'rasterData')
                    sessionDataFile = d(3).name;
                    load(sessionDataFile, 'sessionData')
                    if sessionData.successTrials(trialNum) == 1
                        targLoc = sessionData.targLocStore(trialNum, :);
                        [rasterFig, sdfFig, sdfLimit] = memRaster(nTrials, rasterData, targLoc(1), targLoc(2), isClear, rasterFig, sdfFig, sdfLimit);
                    end
                    trialNum = trialNum + 1;
                end
            elseif task == 4 %ssd
                if isfile(strcat('rasterData_', num2str(trialNum+1), '.mat'))
                    fname = strcat('rasterData_', num2str(trialNum), '.mat');
                    load(fname, 'rasterData')           
                    probeSigma = trialParams.probeSigma(trialNum);
                    color = trialParams.color(trialNum);
                   % if sessionData.successTrials(trialNum) == 1
                        [rasterFig, sdfFig, sdfLimit] = ssdRaster(nTrials, rasterData, probeSigma, color, isClear, rasterFig, sdfFig, 1, sdfLimit);
                    %end
                    trialNum = trialNum + 1;
                end
            end
            
            if isClear == 1
                set(handles.ClearRast, 'Value', 0)
            end
        end
    end %end of "while start on" loop   
end