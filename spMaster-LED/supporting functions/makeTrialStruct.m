%% Test trial structure of cell arrays OR structure of structures
function [Trial,totNumPhases,numLEDPhases,numRobotPhases,LEDPhases,robotPhases] = makeTrialStruct(LED, robot,paramNames_LED,paramNames_robot)
% Inputs: cell arrays containing numeric and string variables of the trial
% parameters for the LED board and vergence robot, cell arrays of character
% vectors for structure field names
% Outputs: Trial - structure of structures, each secondary structure is for
% each phase with fields that correspind to paramNames
% totNumPhases - number of total phases in a trial
% numLEDPhases,numRobotPhases - number of LED/Robot phases
% LEDphases,robotPhases - list of phase numbers that are for LED
% board/robot
numFilledInRows = sum(~cellfun(@isempty,LED),1);
numLEDPhases = numFilledInRows(1);
numParams = numel(numFilledInRows);
LEDPhases = zeros(size(LED(:,1)));
% loop through all rows/LED phases
for i = 1:numLEDPhases
    % if entry in first column is not a double
    if ~isa(LED{i,1},'double')
        % convert from string to double and save phase number in list of
        % LED phases
        LEDPhases(i) = str2double(LED(i,1));
    % otherwise
    else
        % save phase number in list of LED phases
        LEDPhases(i) = LED{i,1};
    end
    % loop through each column/parameter
    for j = 1:numParams
        % if the phase number entry is not empty and the current
        % phase/parameter cell is empty
        if ~isempty(LED{i,1}) && isempty(LED{i,j})
            % then fill that phase/paramter cell with a 0
            LED{i,j} = 0;
        end
    end
end
% same approach as was conducted above for LED board but with robot
% parameters
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
% save only the number of rows as there are phases, the rest of the cells in
% the cell array would be empty
LED = LED(1:numLEDPhases,:);
robot = robot(1:numRobotPhases,:);
% save list of robot phases, convert from string to double
robotPhases = str2double(robot(:,1));
totNumPhases = numLEDPhases + numRobotPhases;
%to avoid initializing size of Trial structure that could change between
%trials, start with the last phase nad increment by -1 to the first phase
for i = totNumPhases:-1:1
    for j = 1:numLEDPhases
        % if the current LED phase matches the current overall phase
        if i == LEDPhases(j)
            % save in structure with fields named paramNames that
            % correspond to 2nd dimension of LED
            Trial(i).phases = cell2struct(LED(j,:),paramNames_LED,2);
        end
    end
    for k = 1:numRobotPhases
        if i == str2double(robot{k,1})
            Trial(i).phases = cell2struct(robot(k,:),paramNames_robot,2);
        end
    end
end
end
