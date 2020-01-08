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
% a.calibrate();
% a.speedModelFit(15,65,5,12);

% a.moveTo(63,63,10);
% a.calibrate();
% a.moveTo(63,0,15);
% a.calibrate();
% a.moveTo(0,63,10);

% a.moveTo(69,35,30);
% a.linearOscillate(20,60,100,20,30,1);
% a.oneLED("SE", "blue", 10, 4);
% a.oneLED("center","red",0,3);
% a.moveTo(100,60,30);
a.saccade(1, "SW", "red", 5, 3, "NE", "green", 20, 1);
a.saccade(1, "W", "green", 5, 3, "E", "blue", 2, 2);
% a.calibrate();
% a.arcMove(65,90,-90,20,50);
% a.saccade(2, "SW", "green", 5, 3, "S", "blue", 20, 1);
a.smoothPursuit("N", "blue", 1, 35);

% a.speedModelFit(15,70,5,12);
%a.calibrate(); 
%a.moveTo(0,30,100); 
%a.calibrate();
%a.moveTo(10,5,100); % x cm, y cm, hold ms
%a.speedModelFit(15,65,5,12);
% a.linearOscillate(10,10,60,25,30,2,100);
%a.moveTo(20,20,500);
%a.linearOscillate(0,0,20,20,30,2);

a.endSerial();