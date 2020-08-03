function trial = sortTrialParams(TrialParams, paramNames)
%Inputs: TrialParams is a cell array containing string and numerical
%values, coumns contain different parameters, each row contains all the
%information for a single phase
%paramNames is a cell array of character arrays naming each column of the
%TrialParams cell array

%get number of filled in rows (trial phases) in TrialParams
numFilledInRows = sum(~cellfun(@isempty,TrialParams),1);
numPhases = numFilledInRows(1); %number of rows with the phase filled in
numParams = numel(numFilledInRows); %total number of params (columns)
%if first element in a row exists and a subsequent element is empty
%then replace empty element with 0
%this is intended to correct any logical errors with params determined by
%checkboxes
for i = 1:numPhases
    if ischar(TrialParams{i,1})
        TrialParams{i,1} = str2double(TrialParams(i,1));
    end
    for j = 1:numParams
        if ~isempty(TrialParams{i,1}) && isempty(TrialParams{i,j})
            TrialParams{i,j} = 0;
        end
    end
end
%only include number of rows that have a phase number specified
TrialParams = TrialParams(1:numPhases, :);
%create a structure 
trial = cell2struct(TrialParams,paramNames,2);