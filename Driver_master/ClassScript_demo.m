%% Test Design Script
%% System setup
system = computer(); %store computer-type MATLAB is running on
%In Arduino sketch, when Arduino is connected to computer, go to Tools>Port
%to find COM port you are connected to. If necessary, update string stored
%in serialPort accordingly.
if strcmp(system, "MACI64") %if computer is 64-bit macOS platform
    serialPort = '/dev/tty.usbmodem1421'; %format string stored in serialPort like is
else %otherwise
    serialPort = 'COM4'; %format like this
end
a = ExperimentClass_master(serialPort); %create an object of the class to use it

%% Command formats
% a.calibrate();
% a.moveTo(x-coordinate, y-coordinate, hold time);
% a.linearOscillate(xstart,ystart,xfinal,yfinal,delay,repetitions);
% a.arcMove(diameter,angInit,angFinal,speed/delay,numLines);
% a.speedModelFit(obj,delayi,delayf,ddelay,angleTrials);

%% Test specifications
a.calibrate();
a.arcMove(65,90,-90,20,100);
a.linearOscillate(65,0,65,60,30,2);
a.linearOscillate(40,5,80,50,30,2);
a.calibrate();

a.endSerial();