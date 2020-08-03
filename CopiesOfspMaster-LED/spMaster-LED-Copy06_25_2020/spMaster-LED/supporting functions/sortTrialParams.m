function trial = sortTrialParams(TrialParams, paramNames)
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
trial = cell2struct(TrialParams,paramNames,2);