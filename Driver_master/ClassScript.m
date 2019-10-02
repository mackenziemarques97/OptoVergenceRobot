%% Test Design Script
%% System setup
system = computer(); %store computer-t4ype MATLAB is running on
if strcmp(system, "MACI64") %if computer is 64-bit macOS platform
    serialPort = '/dev/tty.usbmodem14201'; %format string stored in serialPort like is
else %otherwise
    serialPort = 'COM3'; %format like this
end
a = ExperimentClass_master(serialPort); %create an object of the class to use it

%% Command formats
% a.calibrate();
% a.moveTo(x-coordinate, y-coordinate, hold time);
% a.linearOscillate(xstart,ystart,xfinal,yfinal,delay,repetitions);
% a.arcMove(diameter,angInit,angFinal,speed/delay,numLines);
% a.speedModelFit(obj,delayi,delayf,ddelay,angleTrials);

%% Test specifications

a.linearOscillate(20,20,5,5,30,1);
a.arcMove(30,90,-90,20,36);
a.speedModelFit(15,70,5,12);

%a.calibrate();
%a.moveTo(0,30,100); 
%a.calibrate();
%a.moveTo(10,5,100); % x cm, y cm, hold ms
%a.speedModelFit(15,65,5,12);
% a.linearOscillate(10,10,60,25,30,2,100);
%a.moveTo(20,20,500);
%a.linearOscillate(0,0,20,20,30,2);

a.endSerial();