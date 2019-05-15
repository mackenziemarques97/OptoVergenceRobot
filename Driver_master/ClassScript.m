system = computer();
if strcmp(system, "MACI64")
    serialPort = '/dev/tty.usbmodem14201';
else
    serialPort = 'COM5';
end
a = ExperimentClass_master(serialPort);

%a.speedModelFit(10,50,10,10);
% a.linearOscillate(10,10,60,25,30,2,100);
% 
%a.moveTo(20,20,500);

%a.linearOscillate(0,0,20,20,30,2);
% 
x = 1;
while x == 1
a.arcMove(30,90,-90,30,27);
end
% 
%a.calibrate();

%a.moveTo(10,5,100); % x cm, y cm, hold ms

a.endSerial();