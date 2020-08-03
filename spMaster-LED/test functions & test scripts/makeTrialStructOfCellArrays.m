%% Test trial structure of cell arrays OR structure of structures
function Trial = makeTrialStructOfCellArrays(LED, robot)

numFilledInRows = sum(~cellfun(@isempty,LED),1);
numPhaseLED = numFilledInRows(1);
numParams = numel(numFilledInRows);
for i = 1:numPhaseLED
    for j = 1:numParams
        if ~isempty(LED{i,1}) && isempty(LED{i,j})
            LED{i,j} = 0;
        end
    end
end

numFilledInRows = sum(~cellfun(@isempty,robot),1);
numPhaseRobot = numFilledInRows(1);
numParams = numel(numFilledInRows);
for i = 1:numPhaseRobot
    for j = 1:numParams
        if ~isempty(robot{i,1}) && isempty(robot{i,j})
            robot{i,j} = 0;
        end
    end
end

totNumPhases = numPhaseLED + numPhaseRobot;

for i = totNumPhases:-1:1
    for j = 1:numPhaseLED
        if i == str2double(LED{j,1})
            Trial(i).phases = LED(numPhaseLED,:); 
        end
    end
    for k = 1:numPhaseRobot
        if i == str2double(robot{k,1})
            Trial(i).phases = robot(numPhaseRobot,:); 
        end
    end
end
