function experimentLED(experiment, order, handles)
%% BASICS: initialize psychtoolbox, DAQ card and joystick 
%DAQ card initialized during GUI start-up. Handles imported here.


%% Initialize experiment structure/trial order

% save path locations for reuse
masterFolder = 'C:\Users\SommerLab\Documents\spMaster-LED';
experFolder = 'C:\Users\SommerLab\Documents\spMaster-LED\experiments';
% change current folder to experiments folder
cd(experFolder)
% load experiment structure/trial order
load(experiment,'ExperParams');
% change current folder to spMaster-LED
cd(masterFolder)

% get number of each trial type and total number of trials
ncells = ExperParams(:,2);

ntrials = cell2mat(ncells);
ntrials = str2num(ntrials);
totalTrials = sum(ntrials);
ntypes = length(ntrials);

% Arduino system setup
%In Arduino sketch, when Arduino is connected to computer, go to Tools>Port
%to find COM port you are connected to. If necessary, update string stored
%in serialPort accordingly.
serialPort = 'COM4';
%create an object of the class to use it
%functions within class can be used in experimentLED and trialLED
a = ExperimentClass_GUI_LEDboard(serialPort); %create an object of the class to use it

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
for ii = 1:totalTrials
    currentTrial = trialOrder{ii};
    currentTrial = strcat(currentTrial,'.mat');
    trialLED(currentTrial,handles,a) % calls trial.m with the current trial parameters
end

a.endSerial(); % at the end of each experiment, end serial connection with Arduino
end

