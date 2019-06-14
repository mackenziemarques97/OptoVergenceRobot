%% Test Design Script
%% System setup
system = computer();
if strcmp(system, "MACI64")
    serialPort = '/dev/tty.usbmodem14201';
else
    serialPort = 'COM8';
end
a = ExperimentClass_master(serialPort);

%% Command formats
% a.calibrate();
% a.moveTo(x-coordinate, y-coordinate, hold time);
% a.linearOscillate(xstart,ystart,xfinal,yfinal,speed,repetitions);
% a.arcMove(diameter,angInit,angFinal,speed/delay,numLines);
% a.speedModelFit(obj,delayi,delayf,ddelay,angleTrials);

%% Test specifications

a.calibrate();
a.moveTo(50,50,100);
a.linearOscillate(10,10,50,50,30,3);
a.calibrate();
a.arcMove(50,90,-90,20,36);

%a.calibrate();
%a.moveTo(0,30,100); 
%a.calibrate();
%a.moveTo(10,5,100); % x cm, y cm, hold ms
%a.speedModelFit(15,65,5,12);
% a.linearOscillate(10,10,60,25,30,2,100);
%a.moveTo(20,20,500);
%a.linearOscillate(0,0,20,20,30,2);

a.endSerial();