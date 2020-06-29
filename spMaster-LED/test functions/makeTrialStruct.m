%% Test trial structure of cell arrays OR structure of structures
function [Trial,totNumPhases,numLEDPhases,numRobotPhases,LEDPhases,robotPhases] = makeTrialStruct(LED, robot,paramNames_LED,paramNames_robot)

numFilledInRows = sum(~cellfun(@isempty,LED),1);
numLEDPhases = numFilledInRows(1);
numParams = numel(numFilledInRows);
for i = 1:numLEDPhases
    for j = 1:numParams
        if ~isempty(LED{i,1}) && isempty(LED{i,j})
            LED{i,j} = 0;
        end
    end
end

numFilledInRows = sum(~cellfun(@isempty,robot),1);
numRobotPhases = numFilledInRows(1);
numParams = numel(numFilledInRows);
for i = 1:numRobotPhases
    for j = 1:numParams
        if ~isempty(robot{i,1}) && isempty(robot{i,j})
            robot{i,j} = 0;
        end
    end
end

LED = LED(1:numLEDPhases,:);
robot = robot(1:numRobotPhases,:);
LEDPhases = str2double(LED(:,1));
robotPhases = str2double(robot(:,1));
totNumPhases = numLEDPhases + numRobotPhases;

for i = totNumPhases:-1:1
    for j = 1:numLEDPhases
        if i == str2double(LED{j,1})
            Trial(i).phases = cell2struct(LED(j,:),paramNames_LED,2);
        end
    end
    for k = 1:numRobotPhases
        if i == str2double(robot{k,1})
            Trial(i).phases = cell2struct(robot(k,:),paramNames_robot,2);
        end
    end
end
