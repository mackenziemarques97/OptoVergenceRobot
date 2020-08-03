%% Sample code for testing methods defined in ExperiementClass handle class
%blink LED
clear;close all;
serialPort = 'COM4';
a = ExperimentClass_GUI_LEDboard(serialPort);
for i = 1:250
    a.sendLEDPhaseParams("center", "blue", 0);
    a.turnOnLED();
    pause(1);
    a.clearLEDs();
    pause(1);
end
a.endSerial();

%%
%turn on 2 LEDs at once
clear;close all;
serialPort = 'COM4';
a = ExperimentClass_GUI_LEDboard(serialPort);
a.sendLEDPhaseParams("center", "yellow", 0);
a.sendLEDPhaseParams("N", "green", 2);
a.turnOnLED();

