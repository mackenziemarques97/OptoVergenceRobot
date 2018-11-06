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
% a.smoothPursuit(54000,60,-60,20,1000);
% 
a.calibrate();

a.moveTo(25,25,100);

a.endSerial();