system = computer();
if strcmp(system, "MACI64")
    serialPort = '/dev/tty.usbmodem14201';
else
    serialPort = 'COM5';
end
a = ExperimentClass_09_21_18(serialPort);

% a.linearOscillate(10,10,60,25,30,2,100);
% 
% a.moveTo(90,45,500);
% 
% a.calibrate();
% 
%a.smoothPursuit(8000,90,-90,20,500);
% 
%a.calibrate();

%a.moveTo(10,5,100); % x cm, y cm, hold ms
a.speedModelFit(20,80,5,12); %speedModelFit:20:80:5:12

a.endSerial();