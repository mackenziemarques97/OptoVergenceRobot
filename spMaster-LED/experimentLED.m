function experimentLED(experiment, order, handles)
%% Initialize experiment structure/trial order
% load experiment structure/trial order
load(fullfile(handles.experFolder,experiment),'ExperParams');
% create object outside of handles
a = handles.a_serialobj;

% get number of each trial type and total number of trials
ncells = ExperParams(:,2);

ntrials = cell2mat(ncells);
ntrials = str2num(ntrials);
totalTrials = sum(ntrials);
ntypes = length(ntrials);

%% Create a vector totalTrials long containing the trial order
trialOrder = [];
base = [];

% create uniform distribution (i.e. [type1, type2, type3, type1, type2, type3, ...])
if strcmp(order,'Uniform')
    for i = 1:ntypes
        base = [base, ExperParams(i,1)];
    end
    for i = 1:totalTrials/ntypes
        trialOrder = [trialOrder,base];
    end
end

% OR create block distribution (i.e. [type1, type1, type2, type2, type3, type3])
if strcmp(order,'Block')
    for i = 1:ntypes
        for k = 1:ntrials(i)
            trialOrder = [trialOrder,ExperParams(i,1)];
        end
    end
end

% OR create random distribution
if strcmp(order,'Random')
    for i = 1:ntypes
        for k = 1:ntrials(i)
            trialOrder = [trialOrder,ExperParams(i,1)];
        end
    end
    trialOrder = trialOrder(randperm(length(trialOrder)));
end

%% Run through the experiment
trial_num_format = ['%0',num2str(floor(eps + log(totalTrials) / log(10)) + 1),'d'];
experimentData.experimentParameters = ExperParams;
experimentData.order = order;
trialByTrialData(totalTrials) = struct();
for trialCount = 1:totalTrials
    currentTrialName = trialOrder{trialCount};
    handles.trial_prefix = [experiment(1:end-4),'_',sprintf(trial_num_format,trialCount),'_',currentTrialName,'_'];
    currentTrialName = strcat(currentTrialName,'.mat');
    [experimentData,trialByTrialData] = trialLED(currentTrialName,handles,experimentData,trialByTrialData,trialCount,totalTrials); % calls trial.m with the current trial parameters
    pause(str2double(handles.defaultITI_editbox.String));
end
% at the end of each experiment, end serial connection with Arduino
uiwait(msgbox('Experiment Finished'));
a.endSerial(); 
clear
close all
end

