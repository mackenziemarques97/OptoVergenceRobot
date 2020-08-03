clear;close all;
serialPort = 'COM4';
a = ExperimentClass_GUI_LEDboard(serialPort);
tic;
for i = 1:250
    writeline(a.connection, 'poop:');
    waitSignal = check(a);
    %a.sendPhaseParams('NW', 'blue', 12, .7);
    %a.turnOnLED(); 
end
toc / 250
a.endSerial()