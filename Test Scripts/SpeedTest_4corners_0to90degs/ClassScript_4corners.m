%% Test Design Script
%% System setup
system = computer(); %store computer-type MATLAB is running on
if strcmp(system, "MACI64") %if computer is 64-bit macOS platform
    serialPort = '/dev/tty.usbmodem14201'; %format string stored in serialPort like is
else %otherwise
    serialPort = 'COM3'; %format like this
end
a = ExperimentClass_master4corners(serialPort); %create an object of the class to use it

%% Command formats
% a.speedModelFit(obj,delayi,delayf,ddelay,angleTrials);

%% Test specifications

%a.speedModelFit(15,65,5,12); %move at delays of 15 to 65 us, incrementing
%by 5 us each loop, do this at 12 different angles between 0 and 45 degs,
%45 and 90 degs

a.speedModelFit(15,60,5,7); 

a.endSerial();